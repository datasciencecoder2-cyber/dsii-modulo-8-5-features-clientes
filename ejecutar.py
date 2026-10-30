"""Ejecuta la practica del Modulo 8.5 sin paquetes externos.

Crea una base SQLite temporal en memoria, carga los datos ficticios
pero NO guarda un archivo binario en el repositorio.
"""
from pathlib import Path
import sqlite3

BASE = Path(__file__).resolve().parent
CONSULTAS = sorted((BASE / "consultas").glob("[0-9][0-9]_*.sql"))


def crear_conexion():
    con = sqlite3.connect(":memory:")
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA foreign_keys = ON")
    con.executescript((BASE / "datos" / "00_esquema_y_datos.sql").read_text(encoding="utf-8"))
    return con


def ejecutar_consulta(con, ruta):
    sql = Path(ruta).read_text(encoding="utf-8")
    return [dict(fila) for fila in con.execute(sql).fetchall()]


def main():
    with crear_conexion() as con:
        for archivo in CONSULTAS:
            registros = ejecutar_consulta(con, archivo)
            print(f"\n{archivo.name}: {len(registros)} filas")
            for registro in registros:
                print(registro)
    print("\nVALIDACIONES DE EJECUCION: OK")


if __name__ == "__main__":
    main()
