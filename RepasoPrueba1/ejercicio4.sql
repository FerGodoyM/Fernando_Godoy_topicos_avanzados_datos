--Ejercicio 4

-- Escribe un bloque PL/SQL con un
-- cursor explícito que aumente en 1 la cantidad de
-- los detalles de pedidos (DetallesPedidos)
-- asociados a pedidos con fecha anterior al 2 de
-- marzo de 2025 (FechaPedido en la tabla Pedidos).
-- Usa FOR UPDATE para bloquear las filas y maneja
-- excepciones.

DECLARE
	CURSOR c_aumentar_cantidad IS
	SELECT DetallesPedidos.PedidoID, DetallesPedidos.DetalleID, DetallesPedidos.Cantidad FROM DetallesPedidos
	INNER JOIN Pedidos 
	ON DetallesPedidos.PedidoID = Pedidos.PedidoID
	WHERE FechaPedido < TO_DATE('2025-03-02', 'YYYY-MM-DD')
	FOR UPDATE OF DetallesPedidos.Cantidad;

	v_pedido_id DetallesPedidos.PedidoID%TYPE;
	v_detalle_id DetallesPedidos.DetalleID%TYPE;
	v_cantidad DetallesPedidos.Cantidad%TYPE;
	v_contador NUMBER := 0;
	v_nueva_cantidad DetallesPedidos.Cantidad%TYPE;

BEGIN
	OPEN c_aumentar_cantidad;
	LOOP

		FETCH c_aumentar_cantidad INTO v_pedido_id, v_detalle_id, v_cantidad;
		EXIT WHEN c_aumentar_cantidad%NOTFOUND;

		v_nueva_cantidad := v_cantidad + 1;

		UPDATE DetallesPedidos
		SET Cantidad = v_nueva_cantidad
		WHERE PedidoID = v_pedido_id;
		
		DBMS_OUTPUT.PUT_LINE('el pedido: '|| v_pedido_id || ', Cantidad vieja: ' || v_cantidad || ', Cantidad Nueva: ' || v_nueva_cantidad );
		v_contador := v_contador + 1;

	END LOOP;

	IF v_contador = 0 THEN
		DBMS_OUTPUT.PUT_LINE('NO SE ENCONTRARON PEDIDOS CON DICHAS CONDICIONES');
	END IF;

	CLOSE c_aumentar_cantidad;

EXCEPTION
	WHEN OTHERS THEN
 	DBMS_OUTPUT.PUT_LINE('Error al listar clientes: ' || SQLERRM);
 	
 	IF c_aumentar_cantidad%ISOPEN THEN
 		CLOSE c_aumentar_cantidad;
 	END IF;
END;
/