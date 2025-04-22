SET SERVEROUTPUT ON:

--Ejercicio 1

DECLARE
	CURSOR c_listar IS
	SELECT Nombre, PedidoID, Total FROM Pedidos
	INNER JOIN Clientes
	ON Pedidos.ClienteID = Clientes.ClienteID
	WHERE Pedidos.Total > 500;

	v_nombre Clientes.Nombre%TYPE;
	v_pedido_id Pedidos.PedidoID%TYPE;
	v_total Pedidos.Total%TYPE;

BEGIN
	OPEN c_listar;
	DBMS_OUTPUT.PUT_LINE('---------SE EMPIEZA A LISTAR--------');
	LOOP
		FETCH c_listar INTO v_nombre, v_pedido_id, v_total;
		EXIT WHEN c_listar%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('Nombre: '|| v_nombre ||', Pedido: ' || v_pedido_id || ', Total: ' || v_total);
	END LOOP;
	DBMS_OUTPUT.PUT_LINE('---------SE TERMINA DE LISTAR--------');

	CLOSE c_listar;
END;
/

--Ejercicio 2

DECLARE
	CURSOR c_aumetar_precio IS
	SELECT ProductoID, Precio FROM Productos
	WHERE Precio < 1000
	FOR UPDATE OF Productos.Precio;

	v_producto_id Productos.ProductoID%TYPE;
	v_precio Productos.Precio%TYPE;


BEGIN
	OPEN c_aumetar_precio;
	LOOP
		FETCH c_aumetar_precio INTO v_producto_id, v_precio;
		EXIT WHEN c_aumetar_precio%NOTFOUND;

		UPDATE Productos
		SET Precio = v_precio * 1.15
		WHERE ProductoID = v_producto_id;

		DBMS_OUTPUT.PUT_LINE('ID: ' || v_producto_id || ', Nuevo precio: ' || v_precio);
	END LOOP;
	CLOSE c_aumetar_precio;
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('OCURRIO UN ERROR !');
END;
/