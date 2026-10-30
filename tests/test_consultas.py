"""Pruebas de integridad y exactitud para modulo 8.5 (SQLite stdlib)."""
import unittest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from ejecutar import crear_conexion, ejecutar_consulta, BASE, CONSULTAS


class TestFeaturesClientes(unittest.TestCase):
    def setUp(self):
        self.con = crear_conexion()

    def tearDown(self):
        self.con.close()

    def consultar(self, numero):
        consulta = next(p for p in CONSULTAS if p.name.startswith(f'{numero:02d}_'))
        return ejecutar_consulta(self.con, consulta)

    def test_01_estructura_y_integridad_referencial(self):
        self.assertEqual(self.con.execute('SELECT COUNT(*) FROM clientes').fetchone()[0], 12)
        self.assertEqual(self.con.execute('SELECT COUNT(*) FROM pedidos').fetchone()[0], 37)
        self.assertEqual(self.con.execute('SELECT COUNT(*) FROM detalles_pedido').fetchone()[0], 39)
        self.assertEqual(self.con.execute('PRAGMA foreign_key_check').fetchall(), [])

    def test_02_ltv_preserva_todos_los_clientes(self):
        self.assertEqual(len(self.consultar(1)), 12)

    def test_03_ltv_clientes_sin_compras_igual_cero(self):
        d = {r['cliente_id']: r for r in self.consultar(1)}
        for cliente_id in (4,7,12):
            self.assertEqual(d[cliente_id]['cantidad_compras'], 0)
            self.assertEqual(d[cliente_id]['gasto_total'], 0)

    def test_04_conteo_distinct_no_duplica_pedidos_multilinea(self):
        d = {r['cliente_id']: r for r in self.consultar(1)}
        self.assertEqual(d[1]['cantidad_compras'], 4)
        self.assertEqual(d[5]['cantidad_compras'], 4)
        self.assertEqual(d[1]['gasto_total'], 300)

    def test_05_agrupacion_por_categoria_preserva_clientes(self):
        self.assertEqual(len(self.consultar(2)), 12)

    def test_06_features_categoria_ana_y_elena(self):
        d = {r['cliente_id']: r for r in self.consultar(2)}
        self.assertEqual((d[1]['gasto_alimentos'], d[1]['gasto_tecnologia']), (110,190))
        self.assertEqual((d[5]['gasto_alimentos'], d[5]['gasto_tecnologia']), (100,200))

    def test_07_reconciliacion_categorias_con_total(self):
        for r in self.consultar(2):
            self.assertEqual(r['gasto_alimentos']+r['gasto_tecnologia'],r['gasto_total'])

    def test_08_segmentacion_estricta_por_compras_y_ticket(self):
        ids = {r['cliente_id'] for r in self.consultar(3)}
        self.assertEqual(ids, {1,5,6,8,10})
        self.assertNotIn(3,ids)  # Solo 3 compras
        self.assertNotIn(11,ids) # Ticket igual a 50, no >50
        self.assertNotIn(2,ids)  # Cinco pedidos pero ticket 48

    def test_09_ticket_promedio_es_por_pedido(self):
        d = {r['cliente_id']: r for r in self.consultar(3)}
        self.assertEqual(d[1]['ticket_promedio'], 75)
        self.assertEqual(d[5]['ticket_promedio'], 75)

    def test_10_ranking_misma_poblacion_filtrada(self):
        self.assertEqual({r['cliente_id'] for r in self.consultar(3)},
                         {r['cliente_id'] for r in self.consultar(4)})

    def test_11_ranking_reinicia_por_ciudad(self):
        d = {r['cliente_id']:r for r in self.consultar(4)}
        self.assertEqual((d[1]['ranking_en_ciudad'],d[5]['ranking_en_ciudad'],d[8]['ranking_en_ciudad']), (1,1,1))
        self.assertEqual(d[10]['ranking_en_ciudad'],2)

    def test_12_empate_comparte_posicion(self):
        d = {r['cliente_id']:r for r in self.consultar(4)}
        self.assertEqual(d[5]['ranking_en_ciudad'],d[6]['ranking_en_ciudad'])

    def test_13_categoria_extra_no_contamina_features(self):
        self.con.execute("INSERT INTO pedidos VALUES (999,12,'2026-02-01')")
        self.con.execute('INSERT INTO detalles_pedido VALUES (999,999,5,2,30)')
        d = {r['cliente_id']:r for r in self.consultar(2)}
        self.assertEqual((d[12]['gasto_alimentos'],d[12]['gasto_tecnologia'],d[12]['gasto_total']), (0,0,60))

    def test_14_no_hay_sumas_duplicadas_tras_cuatro_joins(self):
        total_real = self.con.execute('SELECT SUM(cantidad * precio_unitario) FROM detalles_pedido').fetchone()[0]
        total_features = sum(r['gasto_total'] for r in self.consultar(2))
        self.assertAlmostEqual(total_real,total_features)

    def test_15_cada_cliente_es_una_sola_fila(self):
        for n in (1,2,3,4):
            rows = self.consultar(n)
            ids = [r['cliente_id'] for r in rows]
            self.assertEqual(len(ids), len(set(ids)))


if __name__ == '__main__':
    unittest.main()
