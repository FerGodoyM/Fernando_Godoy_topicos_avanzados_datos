-- Indices y particiones
-- es una estructura de datos que mejora
-- la velocidad de las consultas al permitir un
-- acceso más rápido a los datos de una tabla
-- y se clasifican en  B-Tree, Bitmap, Único, Compuesto y Basado en Funciones

-- Una partición es una técnica para dividir una
-- tabla o índice grande en fragmentos más pequeños 
-- se clasifican en Rango, Lista, Hash, Compuesta
--------------------------EJEMPLOS-------------------------------
 
-- Indices

-- Mejorar el rendimiento de consultas en la tabla Pedidos y DetallesPedidos.

-- Crear un índice compuesto en Pedidos para consultas por ClienteID y FechaPedido.
CREATE INDEX idx_pedidos_cliente_fecha ON Pedidos(ClienteID, FechaPedido);

-- Crear un índice basado en funciones en Clientes para buscar nombres en mayúsculas.
CREATE INDEX idx_clientes_nombre_upper ON Clientes(UPPER(Nombre));

-- Consulta sin índice (suponiendo que no existiera idx_pedidos_cliente_fecha)
EXPLAIN PLAN FOR
SELECT * FROM Pedidos
WHERE ClienteID = 1 AND FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD');
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Crear el índice
CREATE INDEX idx_pedidos_cliente_fecha ON Pedidos(ClienteID, FechaPedido);

-- Consulta con índice
EXPLAIN PLAN FOR
SELECT * FROM Pedidos
WHERE ClienteID = 1 AND FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD');
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Probar una consulta con el índice basado en funciones.

SELECT * FROM Clientes
WHERE UPPER(Nombre) = 'JUAN PÉREZ';


-- Particiones

-- Particionar la tabla Pedidos por rango
-- de fechas y la tabla Clientes por lista de
-- ciudades.

-- Crear una tabla Pedidos particionada por rango de fechas trimestrales.

-- Eliminar la tabla Pedidos si existe
DROP TABLE Pedidos CASCADE CONSTRAINTS;
-- Crear tabla Pedidos particionada por rango
CREATE TABLE Pedidos (
    PedidoID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER,
    FechaPedido DATE
)
PARTITION BY RANGE (FechaPedido) (
    PARTITION p1_2025_q1 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p2_2025_q2 VALUES LESS THAN (TO_DATE('2025-07-01', 'YYYY-MM-DD')),
    PARTITION p3_2025_q3 VALUES LESS THAN (TO_DATE('2025-10-01', 'YYYY-MM-DD')),
    PARTITION p4_2025_q4 VALUES LESS THAN (TO_DATE('2026-01-01', 'YYYY-MM-DD'))
);
-- Insertar datos
INSERT INTO Pedidos VALUES (101, 1, 2272.5, TO_DATE('2025-03-01', 'YYYY-MM-DD'));
INSERT INTO Pedidos VALUES (102, 1, 246.25, TO_DATE('2025-03-02', 'YYYY-MM-DD'));
INSERT INTO Pedidos VALUES (103, 2, 800, TO_DATE('2025-03-03', 'YYYY-MM-DD'));
INSERT INTO Pedidos VALUES (108, 3, 1225, TO_DATE('2025-05-19', 'YYYY-MM-DD'));

-- Crear una tabla Clientes particionada por lista de ciudades.

-- Eliminar la tabla Clientes si existe
DROP TABLE Clientes CASCADE CONSTRAINTS;
-- Crear tabla Clientes particionada por lista
CREATE TABLE Clientes (
    ClienteID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    FechaNacimiento DATE
)
PARTITION BY LIST (Ciudad) (
    PARTITION p_santiago VALUES ('Santiago'),
    PARTITION p_valparaiso VALUES ('Valparaíso'),
    PARTITION p_otros VALUES (DEFAULT)
);
-- Insertar datos
INSERT INTO Clientes VALUES (1, 'Juan Pérez', 'Santiago', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
INSERT INTO Clientes VALUES (2, 'María Gómez', 'Valparaíso', TO_DATE('1985-10-20', 'YYYY-MM-DD'));
INSERT INTO Clientes VALUES (3, 'Ana López', 'Santiago', TO_DATE('1995-03-10', 'YYYY-MM-DD'));


-- Consulta que usa partición por rango
EXPLAIN PLAN FOR
SELECT * FROM Pedidos
WHERE FechaPedido BETWEEN TO_DATE('2025-03-01', 'YYYY-MM-DD')
AND TO_DATE('2025-03-31', 'YYYY-MM-DD');
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Consulta que usa partición por lista
EXPLAIN PLAN FOR
SELECT * FROM Clientes
WHERE Ciudad = 'Santiago';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

------------------------EJERCICIOS---------------------------------
-- DetallesPedidos para las columnas PedidoID y
-- ProductoID. Luego, escribe una consulta que use
-- este índice y analiza su plan de ejecución.

--Explain Plan sin el index
EXPLAIN PLAN FOR
SELECT * FROM detallesPedidos where PedidoID = 1 and ProductoID = 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


--Corriendo la sentencia con indice
CREATE INDEX idx_detallesPedidos_pedido_producto ON detallesPedidos(PedidoID, ProductoID);

SELECT * FROM detallesPedidos where PedidoID = 1 and ProductoID = 1;


--Explain Plan con el index
EXPLAIN PLAN FOR
SELECT * FROM detallesPedidos where PedidoID = 1 and ProductoID = 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- Crea una tabla Ventas particionada por hash
-- usando la columna ClienteID (4 particiones).
-- Inserta datos de Pedidos y escribe una consulta
-- que muestre el total de ventas por cliente,
-- verificando que las particiones se usen.

CREATE TABLE Ventas (
    VentaID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Monto NUMBER
)
PARTITION BY HASH (ClienteID)
PARTITIONS 4;
-- Insertando datos de ejemplo
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (1, 101, 100);
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (2, 102, 200);
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (3, 103, 300);
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (4, 104, 400);
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (5, 105, 500);
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (6, 106, 600);
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (7, 107, 700);
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (8, 108, 800);
INSERT INTO Ventas (VentaID, ClienteID, Monto) VALUES (9, 109, 900);

EXPLAIN PLAN FOR
SELECT ClienteID, SUM(Total) FROM Ventas
WHERE ClienteID = 101
GROUP BY ClienteID;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);