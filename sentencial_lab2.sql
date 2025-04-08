--Realice 2 sentencias SELECT simples

SELECT PedidoID, Total FROM Pedidos WHERE Total > 500 
ORDER BY Total DESC;

SELECT COUNT(*) AS TotalClientes, Ciudad FROM Clientes
GROUP BY Ciudad HAVING COUNT(*) > 2;

--Realice 2 sentencias SELECT utilizando funciones agregadas sobre su base de datos.

SELECT Nombre FROM Clientes WHERE ClienteID IN (
	SELECT ClienteID FROM Pedidos WHERE Total > (SELECT AVG(Total) FROM Pedidos));

SELECT Nombre
FROM Productos
WHERE Precio = (SELECT MAX(Precio) FROM Productos);

--Realice 2 sentencias SELECT utilizando expresiones regulares.

CLI Oracle > SELECT Nombre
FROM Clientes
WHERE REGEXP_LIKE(Nombre, '^J');

CLI Oracle > SELECT Nombre, Ciudad
FROM Clientes
WHERE REGEXP_LIKE(Ciudad, 'ai');

--Cree 2 vistas.

CREATE VIEW nombre_vista AS consulta;

CREATE VIEW PedidosCaros AS
SELECT c.Nombre, p.Total
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.Total > 500;