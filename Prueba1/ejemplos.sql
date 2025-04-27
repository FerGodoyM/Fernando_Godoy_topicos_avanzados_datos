--Ejemplo 1: Lista los clientes con pedidos
--superiores al promedio de todos los pedidos.

SELECT Nombre
FROM Clientes
WHERE ClienteID IN (
SELECT ClienteID
FROM Pedidos
WHERE Total > (SELECT AVG(Total) FROM Pedidos)
);

--Ejemplo 2: Cuenta los pedidos por ciudad usando
--una vista.

CREATE VIEW PedidosPorCiudad AS
SELECT c.Ciudad, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Ciudad;
SELECT * FROM PedidosPorCiudad;

--Ejemplo 3: Bloque anónimo con estructura de
--control y excepción.

DECLARE
	v_total NUMBER := 600;
	v_clasificacion VARCHAR2(20);
BEGIN
	v_clasificacion := CASE
 	WHEN v_total > 1000 THEN 'Alto'
 	WHEN v_total > 500 THEN 'Medio'
 	ELSE 'Bajo'
	END;
	DBMS_OUTPUT.PUT_LINE('Clasificación: ' || v_clasificacion);

EXCEPTION
WHEN VALUE_ERROR THEN
	DBMS_OUTPUT.PUT_LINE('Error: Problema con los datos.');
END;
/

--Ejemplo 4: Bloque con excepción de TimesTen
--(violación de clave única).

DECLARE
	unique_violation EXCEPTION;
	PRAGMA EXCEPTION_INIT(unique_violation, -8001);
BEGIN
	INSERT INTO Clientes (ClienteID, Nombre, Ciudad)
	VALUES (1, 'Carlos Ruiz', 'Concepción'); -- ClienteID 1 ya existe
	DBMS_OUTPUT.PUT_LINE('Inserción exitosa.');
EXCEPTION
	WHEN unique_violation THEN
	DBMS_OUTPUT.PUT_LINE('Error TimesTen: Violación de clave única (TT8001).');
END;
/

--Ejemplo 5: Cursor explícito con actualización de
--precios.

DECLARE
	CURSOR producto_cursor IS
	SELECT ProductoID, Precio
	FROM Productos
	WHERE Precio < 1000
	FOR UPDATE;
	
	v_productoid NUMBER;
	v_precio NUMBER;

BEGIN
	OPEN producto_cursor;
	LOOP
		FETCH producto_cursor INTO v_productoid, v_precio;
		EXIT WHEN producto_cursor%NOTFOUND;
	
		UPDATE Productos
		SET Precio = v_precio * 1.1
		WHERE CURRENT OF producto_cursor;

		DBMS_OUTPUT.PUT_LINE('Producto ' || v_productoid || ' actualizado a: ' || (v_precio * 1.1));
	END LOOP;
	CLOSE producto_cursor;
END;
/

-- Ejemplo 2: Cursor con tipo de objeto.

DECLARE
	CURSOR cliente_cursor IS
 	SELECT VALUE(c) FROM clientes_obj c;
	v_cliente cliente_obj;
BEGIN
	OPEN cliente_cursor;
	LOOP
		FETCH cliente_cursor INTO v_cliente;
		EXIT WHEN cliente_cursor%NOTFOUND;
 		DBMS_OUTPUT.PUT_LINE(v_cliente.get_info());
	END LOOP;
	CLOSE cliente_cursor;
END;
/

