--Ejercicio 1

--Escribe un cursor explícito que
--liste los pedidos con total mayor a 500 y muestre
--el nombre del cliente asociado, usando un JOIN.


SET SERVEROUTPUT ON;

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
