--Analiza el plan de ejecución de la siguiente
--consulta y optimízala para que use índices y
--particiones.

--SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
--FROM Clientes c, Pedidos p
--WHERE c.ClienteID = p.ClienteID
--AND c.Ciudad = 'Santiago'
--AND p.FechaPedido >= TO_DATE('2025-03-01',
--'YYYY-MM-DD')
--GROUP BY c.Nombre;


SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos FROM Clientes c
INNER JOIN Pedidos p
ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01','YYYY-MM-DD')
GROUP BY c.Nombre;


CREATE INDEX idx_pedidos_clienteid ON Pedidos(ClienteID);
CREATE INDEX idx_clientes_clienteid ON Clientes(ClienteID);
CREATE INDEX idx_clientes_ciudad ON Clientes(Ciudad);
CREATE INDEX idx_pedido_fechapedido ON Pedidos(FechaPedido);

CREATE TABLE Pedidos (
    PedidoID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER,
    FechaPedido DATE
)
PARTITION BY RANGE (FechaPedido) (
    PARTITION p_2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION p_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')),
    PARTITION p_2025 VALUES LESS THAN (TO_DATE('2026-01-01', 'YYYY-MM-DD'))
);


--Optimiza la siguiente consulta para evitar un FULL
--TABLE SCAN en DetallesPedidos y analiza el plan de
--ejecución antes y después de la optimización.
--SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
--FROM Productos p, DetallesPedidos dp
--WHERE p.ProductoID = dp.ProductoID
--GROUP BY p.Nombre;


SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p
INNER JOIN DetallesPedidos dp
ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;

--PARA VER SI HAY UN FULL TABLE SCAN
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


