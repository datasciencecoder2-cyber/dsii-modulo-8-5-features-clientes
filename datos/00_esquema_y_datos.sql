-- Datos ficticios de ensayo, no representan ventas reales.
-- Esquema normalizado: el detalle conserva el precio efectivamente cobrado.
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS detalles_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    cliente_id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    ciudad TEXT NOT NULL
);
CREATE TABLE productos (
    producto_id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    categoria TEXT NOT NULL
);
CREATE TABLE pedidos (
    pedido_id INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(cliente_id),
    fecha TEXT NOT NULL
);
CREATE TABLE detalles_pedido (
    detalle_id INTEGER PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos(pedido_id),
    producto_id INTEGER NOT NULL REFERENCES productos(producto_id),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC NOT NULL CHECK (precio_unitario >= 0)
);

INSERT INTO clientes (cliente_id, nombre, ciudad) VALUES
    (1, 'Ana', 'Buenos Aires'),
    (2, 'Bruno', 'Buenos Aires'),
    (3, 'Carla', 'Buenos Aires'),
    (4, 'Diego', 'Buenos Aires'),
    (5, 'Elena', 'Cordoba'),
    (6, 'Fabio', 'Cordoba'),
    (7, 'Gina', 'Cordoba'),
    (8, 'Hugo', 'Rosario'),
    (9, 'Iris', 'Rosario'),
    (10, 'Jorge', 'Rosario'),
    (11, 'Karen', 'Buenos Aires'),
    (12, 'Laura', 'Mendoza');

INSERT INTO productos (producto_id, nombre, categoria) VALUES
    (1, 'Cafe', 'Alimentos'),
    (2, 'Arroz', 'Alimentos'),
    (3, 'Auriculares', 'Tecnologia'),
    (4, 'Mouse', 'Tecnologia'),
    (5, 'Cuaderno', 'Papeleria');

INSERT INTO pedidos (pedido_id, cliente_id, fecha) VALUES
    (101, 1, '2026-01-01'),
    (102, 1, '2026-01-02'),
    (103, 1, '2026-01-03'),
    (104, 1, '2026-01-04'),
    (201, 2, '2026-01-01'),
    (202, 2, '2026-01-02'),
    (203, 2, '2026-01-03'),
    (204, 2, '2026-01-04'),
    (205, 2, '2026-01-05'),
    (301, 3, '2026-01-01'),
    (302, 3, '2026-01-02'),
    (303, 3, '2026-01-03'),
    (401, 5, '2026-01-01'),
    (402, 5, '2026-01-02'),
    (403, 5, '2026-01-03'),
    (404, 5, '2026-01-04'),
    (501, 6, '2026-01-01'),
    (502, 6, '2026-01-02'),
    (503, 6, '2026-01-03'),
    (504, 6, '2026-01-04'),
    (601, 8, '2026-01-01'),
    (602, 8, '2026-01-02'),
    (603, 8, '2026-01-03'),
    (604, 8, '2026-01-04'),
    (701, 9, '2026-01-01'),
    (702, 9, '2026-01-02'),
    (703, 9, '2026-01-03'),
    (704, 9, '2026-01-04'),
    (705, 9, '2026-01-05'),
    (801, 10, '2026-01-01'),
    (802, 10, '2026-01-02'),
    (803, 10, '2026-01-03'),
    (804, 10, '2026-01-04'),
    (901, 11, '2026-01-01'),
    (902, 11, '2026-01-02'),
    (903, 11, '2026-01-03'),
    (904, 11, '2026-01-04');

INSERT INTO detalles_pedido (detalle_id, pedido_id, producto_id, cantidad, precio_unitario) VALUES
    (1, 101, 1, 1, 20),
    (2, 101, 2, 1, 20),
    (3, 102, 3, 1, 80),
    (4, 103, 1, 1, 70),
    (5, 104, 3, 1, 110),
    (6, 201, 1, 1, 40),
    (7, 202, 3, 1, 45),
    (8, 203, 1, 1, 55),
    (9, 204, 3, 1, 40),
    (10, 205, 1, 1, 60),
    (11, 301, 1, 1, 100),
    (12, 302, 3, 1, 90),
    (13, 303, 1, 1, 80),
    (14, 401, 1, 1, 25),
    (15, 401, 4, 1, 50),
    (16, 402, 3, 1, 75),
    (17, 403, 1, 1, 75),
    (18, 404, 3, 1, 75),
    (19, 501, 1, 1, 100),
    (20, 502, 3, 1, 100),
    (21, 503, 1, 1, 50),
    (22, 504, 3, 1, 50),
    (23, 601, 1, 1, 60),
    (24, 602, 3, 1, 60),
    (25, 603, 1, 1, 60),
    (26, 604, 3, 1, 60),
    (27, 701, 1, 1, 20),
    (28, 702, 3, 1, 20),
    (29, 703, 1, 1, 20),
    (30, 704, 3, 1, 20),
    (31, 705, 1, 1, 20),
    (32, 801, 1, 1, 51),
    (33, 802, 3, 1, 51),
    (34, 803, 1, 1, 51),
    (35, 804, 3, 1, 51),
    (36, 901, 1, 1, 50),
    (37, 902, 3, 1, 50),
    (38, 903, 1, 1, 50),
    (39, 904, 3, 1, 50);
