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
