-- Crea un índice compuesto en la tabla
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