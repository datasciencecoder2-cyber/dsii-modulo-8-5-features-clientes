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
