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
