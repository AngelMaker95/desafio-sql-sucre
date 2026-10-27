-- ==================
-- DESAFÍO PRÁCTICO 2
-- ==================

-- 1. Creación de Tablas con Claves Primarias y Foráneas.
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL
);

CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    estado VARCHAR(50) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_pedidos_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE CASCADE
);

CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_venta DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_ventas_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id) ON DELETE CASCADE,
    CONSTRAINT fk_ventas_producto FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE
);

-- 2. Inserción de Registros de Prueba
INSERT INTO clientes (nombre, apellido, direccion, correo_electronico, telefono) VALUES
('Carlos', 'Pérez', 'Av. Principal, Edificio El Sol', 'carlos.perez@email.com', '0412-1234567'),
('María', 'González', 'Calle Las Flores, Casa 12', 'maria.gonzalez@email.com', '0414-9876543'),
('Ana', 'Rodríguez', 'Urbanización El Parral, Torre B', 'ana.rodriguez@email.com', '0424-5554433');

INSERT INTO productos (nombre, descripcion, precio, categoria, stock) VALUES
('Camiseta Básica Algodón', 'Camiseta de algodón cuello redondo color blanco', 15.00, 'Camisetas', 50),
('Camiseta Estampada', 'Camiseta con diseño gráfico urbano', 20.00, 'Camisetas', 30),
('Jeans Clásicos Azul', 'Pantalón de mezclilla corte recto', 40.00, 'Pantalones', 25),
('Chaqueta de Cuero', 'Chaqueta estilo biker para invierno', 80.00, 'Chaquetas', 10);

INSERT INTO pedidos (id_cliente, fecha, estado, total) VALUES
(1, NOW() - INTERVAL '10 days', 'Completado', 35.00),
(2, NOW() - INTERVAL '40 days', 'Completado', 40.00),
(3, NOW() - INTERVAL '5 days', 'Completado', 80.00),
(1, NOW() - INTERVAL '60 days', 'Completado', 20.00),
(2, NOW() - INTERVAL '2 days', 'Pendiente', 15.00); 

INSERT INTO ventas (id_pedido, id_producto, cantidad, precio_venta) VALUES
(1, 1, 1, 15.00),
(1, 2, 1, 20.00),
(2, 3, 1, 40.00),
(3, 4, 1, 80.00),
(4, 2, 1, 20.00);


-- ========================
-- 3. TAREAS DE LA PRÁCTICA
-- ========================
-- a) Consultas avanzadas con SELECT y WHERE:
-- Consulta 1: Obtener el nombre completo, dirección y correo electrónico de todos los clientes que han realizado pedidos en los últimos 30 días.
SELECT DISTINCT CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo, c.direccion, c.correo_electronico
FROM clientes c
JOIN pedidos p ON c.id = p.id_cliente
WHERE p.fecha >= (NOW() - INTERVAL '30 days');

-- Consulta 2: Mostrar los productos con mayor cantidad de ventas en el último mes, junto con el total vendido de cada uno.
SELECT pr.id, pr.nombre, SUM(v.cantidad) AS total_cantidad_vendida, SUM(v.cantidad * v.precio_venta) AS total_vendido
FROM ventas v
JOIN pedidos p ON v.id_pedido = p.id
JOIN productos pr ON v.id_producto = pr.id
WHERE p.fecha >= (NOW() - INTERVAL '1 month')
GROUP BY pr.id, pr.nombre
ORDER BY total_cantidad_vendida DESC;

-- Consulta 3: Listar los clientes que han realizado más pedidos en el último año, ordenados por mayor cantidad de pedidos[cite: 5].
SELECT c.id, CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo, COUNT(p.id) AS total_pedidos
FROM clientes c
JOIN pedidos p ON c.id = p.id_cliente
WHERE p.fecha >= (NOW() - INTERVAL '1 year')
GROUP BY c.id, nombre_completo
ORDER BY total_pedidos DESC;


-- b) Actualizaciones con UPDATE:
-- Actualización 1: Aumentar el precio de todos los productos de la categoría "Camisetas" en un 10%.
UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Camisetas';


-- c) Eliminaciones con DELETE:
-- Eliminación 2: Eliminar los pedidos que no tengan ventas asociadas
DELETE FROM pedidos
WHERE id NOT IN (SELECT DISTINCT id_pedido FROM ventas);


-- d) Creación de vistas:
-- Vista 1: Crear una vista llamada "vista_clientes_pedidos" que muestre el nombre completo del cliente, la fecha del pedido y el total del pedido.
CREATE OR REPLACE VIEW vista_clientes_pedidos AS
SELECT CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo, p.fecha AS fecha_pedido, p.total AS total_pedido
FROM clientes c
JOIN pedidos p ON c.id = p.id_cliente;

-- Verificación de la vista creada:
SELECT * FROM vista_clientes_pedidos;