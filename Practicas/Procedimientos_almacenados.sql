
	--Ejemplo 1: Procedimiento con parámetro IN para
	--buscar un cliente por ID.

CREATE OR REPLACE PROCEDURE buscar_cliente(p_cliente_id IN NUMBER) AS
	v_nombre VARCHAR2(50);
	v_ciudad VARCHAR2(50);

BEGIN
	SELECT Nombre, Ciudad INTO v_nombre, v_ciudad
	FROM Clientes
	WHERE ClienteID = p_cliente_id;
	DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre || ', Ciudad: ' || v_ciudad);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
 		DBMS_OUTPUT.PUT_LINE('Cliente con ID ' || p_cliente_id || ' no encontrado.');
END;
/

EXEC buscar_cliente(1);
EXEC buscar_cliente(999);





	--Ejemplo 2: Procedimiento con parámetro OUT para
	--calcular el total de pedidos de un cliente.

CREATE OR REPLACE PROCEDURE total_pedidos_cliente(p_cliente_id IN NUMBER, p_total OUT NUMBER) AS
BEGIN
	SELECT SUM(Total) INTO p_total
	FROM Pedidos
	WHERE ClienteID = p_cliente_id;
	IF p_total IS NULL THEN
 		p_total := 0;
	END IF;
END;
/
-- Ejecutar el procedimiento
DECLARE
	v_total NUMBER;
BEGIN
	total_pedidos_cliente(1, v_total);
	DBMS_OUTPUT.PUT_LINE('Total de pedidos del cliente 1: ' || v_total);
END;
/




	--Ejemplo 3: Procedimiento que actualiza el precio
	--de un producto y maneja excepciones.

CREATE OR REPLACE PROCEDURE actualizar_precio_producto(p_producto_id IN NUMBER, p_nuevo_precio IN NUMBER) AS
BEGIN
	UPDATE Productos
	SET Precio = p_nuevo_precio
	WHERE ProductoID = p_producto_id;
	
	IF SQL%ROWCOUNT = 0 THEN
 		RAISE_APPLICATION_ERROR(-20001, 'Producto con ID ' || p_producto_id || ' no encontrado.');
	END IF;
	
	DBMS_OUTPUT.PUT_LINE('Precio del producto ' || p_producto_id || ' actualizado a: ' || p_nuevo_precio);
COMMIT;

EXCEPTION
	WHEN VALUE_ERROR THEN
 		DBMS_OUTPUT.PUT_LINE('Error: El precio debe ser un valor válido.');
	WHEN OTHERS THEN
 		DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

EXEC actualizar_precio_producto(1, 1300);
EXEC actualizar_precio_producto(999, 500);





	--Ejemplo 4: Procedimiento que verifica el total de
	--un pedido antes de insertarlo.

CREATE OR REPLACE PROCEDURE insertar_pedido(p_pedido_id IN NUMBER, p_cliente_id IN NUMBER, p_total IN NUMBER) AS
BEGIN
	IF p_total <= 0 THEN
 		RAISE_APPLICATION_ERROR(-20002, 'El total del pedido debe ser mayor a 0.');
	END IF;
	
	INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
	VALUES (p_pedido_id, p_cliente_id, p_total, SYSDATE);
	DBMS_OUTPUT.PUT_LINE('Pedido ' || p_pedido_id || ' insertado correctamente.');
	COMMIT;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
 		DBMS_OUTPUT.PUT_LINE('Error: El PedidoID ' || p_pedido_id || ' ya existe.');
	WHEN OTHERS THEN
 		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

EXEC insertar_pedido(104, 2, 500);
EXEC insertar_pedido(104, 2, 300);
EXEC insertar_pedido(105, 2, -100);

