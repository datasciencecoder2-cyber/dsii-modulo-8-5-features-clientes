-- MODULO 8.5 | CONSULTAS COMPLETAS
-- Ejecutar despues de datos/00_esquema_y_datos.sql
-- Cada SELECT es independiente y responde a un objetivo diferente.

-- CONSULTA 1. LTV observado: gasto de cada cliente (incluidos los que no compraron).
-- LEFT JOIN desde clientes preserva los 12 clientes. COALESCE convierte NULL a cero.
-- Se suma cada linea del detalle exactamente una vez: cantidad * precio cobrado.
-- COUNT(DISTINCT pedido_id) impide contar un mismo pedido varias veces.
SELECT
    c.cliente_id,
    c.nombre,
    c.ciudad,
    COUNT(DISTINCT p.pedido_id) AS cantidad_compras,
    COALESCE(ROUND(SUM(d.cantidad * d.precio_unitario), 2), 0) AS gasto_total
FROM clientes AS c
LEFT JOIN pedidos AS p
    ON p.cliente_id = c.cliente_id
LEFT JOIN detalles_pedido AS d
    ON d.pedido_id = p.pedido_id
GROUP BY c.cliente_id, c.nombre, c.ciudad
ORDER BY c.cliente_id;

-- CONSULTA 2. Features por categoria, SIN subconsultas para las features.
-- Se unen las cuatro tablas y se usa agregacion condicional CASE WHEN.
-- Otros tipos (p. ej. Papeleria) no se atribuyen a Alimentos ni Tecnologia.
-- LEFT JOIN conserva a clientes que no compraron, con importes en cero.
SELECT
    c.cliente_id,
    c.nombre,
    c.ciudad,
    COALESCE(ROUND(SUM(CASE WHEN pr.categoria = 'Alimentos'
        THEN d.cantidad * d.precio_unitario ELSE 0 END), 2), 0) AS gasto_alimentos,
    COALESCE(ROUND(SUM(CASE WHEN pr.categoria = 'Tecnologia'
        THEN d.cantidad * d.precio_unitario ELSE 0 END), 2), 0) AS gasto_tecnologia,
    COALESCE(ROUND(SUM(d.cantidad * d.precio_unitario), 2), 0) AS gasto_total
FROM clientes AS c
LEFT JOIN pedidos AS p ON p.cliente_id = c.cliente_id
LEFT JOIN detalles_pedido AS d ON d.pedido_id = p.pedido_id
LEFT JOIN productos AS pr ON pr.producto_id = d.producto_id
GROUP BY c.cliente_id, c.nombre, c.ciudad
ORDER BY c.cliente_id;

-- CONSULTA 3. Clientes activos: MAS de tres pedidos y ticket promedio > 50.
-- El promedio es gasto total / cantidad de pedidos distintos, NO promedio
-- de renglones de detalle; se evita inflar el numero de compras.
-- HAVING filtra los grupos tras calcular las agregaciones.
SELECT
    c.cliente_id,
    c.nombre,
    c.ciudad,
    COUNT(DISTINCT p.pedido_id) AS cantidad_compras,
    COALESCE(ROUND(SUM(d.cantidad * d.precio_unitario), 2), 0) AS gasto_total,
    ROUND(
        COALESCE(SUM(d.cantidad * d.precio_unitario), 0) * 1.0
        / NULLIF(COUNT(DISTINCT p.pedido_id), 0), 2
    ) AS ticket_promedio
FROM clientes AS c
LEFT JOIN pedidos AS p ON p.cliente_id = c.cliente_id
LEFT JOIN detalles_pedido AS d ON d.pedido_id = p.pedido_id
GROUP BY c.cliente_id, c.nombre, c.ciudad
HAVING COUNT(DISTINCT p.pedido_id) > 3
   AND COALESCE(SUM(d.cantidad * d.precio_unitario), 0) * 1.0
       / NULLIF(COUNT(DISTINCT p.pedido_id), 0) > 50
ORDER BY c.ciudad, gasto_total DESC, c.cliente_id;

-- CONSULTA 4. Tabla maestra de features + ranking urbano.
-- Primera etapa: se crea UNA fila por cliente mediante GROUP BY; las
-- features por categoria se construyen con SUM(CASE WHEN...), sin
-- subconsultas de agregacion condicionada.
-- Segunda etapa: DENSE_RANK() compara a TODOS los clientes de la ciudad.
-- Tercera etapa: se presentan SOLO los activos; el ranking ya fue calculado
-- sobre toda la poblacion, de manera consistente con el pedido de negocio.
WITH features_cliente AS (
    SELECT
        c.cliente_id,
        c.nombre,
        c.ciudad,
        COUNT(DISTINCT p.pedido_id) AS cantidad_compras,
        COALESCE(ROUND(SUM(d.cantidad * d.precio_unitario), 2), 0) AS gasto_total,
        COALESCE(ROUND(SUM(CASE WHEN pr.categoria = 'Alimentos'
            THEN d.cantidad * d.precio_unitario ELSE 0 END), 2), 0) AS gasto_alimentos,
        COALESCE(ROUND(SUM(CASE WHEN pr.categoria = 'Tecnologia'
            THEN d.cantidad * d.precio_unitario ELSE 0 END), 2), 0) AS gasto_tecnologia,
        ROUND(
            COALESCE(SUM(d.cantidad * d.precio_unitario), 0) * 1.0
            / NULLIF(COUNT(DISTINCT p.pedido_id), 0), 2
        ) AS ticket_promedio
    FROM clientes AS c
    LEFT JOIN pedidos AS p ON p.cliente_id = c.cliente_id
    LEFT JOIN detalles_pedido AS d ON d.pedido_id = p.pedido_id
    LEFT JOIN productos AS pr ON pr.producto_id = d.producto_id
    GROUP BY c.cliente_id, c.nombre, c.ciudad
),
ranking_ciudad AS (
    SELECT
        fc.*,
        DENSE_RANK() OVER (
            PARTITION BY fc.ciudad
            ORDER BY fc.gasto_total DESC
        ) AS ranking_en_ciudad
    FROM features_cliente AS fc
)
SELECT
    cliente_id,
    nombre,
    ciudad,
    cantidad_compras,
    gasto_total,
    ticket_promedio,
    gasto_alimentos,
    gasto_tecnologia,
    ranking_en_ciudad
FROM ranking_ciudad
WHERE cantidad_compras > 3
  AND ticket_promedio > 50
ORDER BY ciudad, ranking_en_ciudad, cliente_id;
