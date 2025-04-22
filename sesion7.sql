--ejercicio 1

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE aumentar_precio_producto(p_producto_id IN NUMBER, p_porcentaje IN NUMBER) AS
	BEGIN
		UPDATE Productos
		SET Precio = Precio * (p_porcentaje/100 + 1)
		WHERE ProductoID = p_producto_id;
 
		IF SQL%ROWCOUNT > 0 THEN
			DBMS_OUTPUT.PUT_LINE('El precio del producto se ha actualizado un ' || p_porcentaje || '%');
		ELSE
			DBMS_OUTPUT.PUT_LINE('No se encontró un producto con ese ID');
		END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Uno de los valores ingresados no es valido');
		WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
	END;
/

EXEC aumentar_precio_producto(1, 20);
EXEC aumentar_precio_producto(90, 10);

--ejercicio 2

CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(
    p_cliente_id IN NUMBER,
    p_pedidos_totales OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*) INTO p_pedidos_totales
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;

    IF p_pedidos_totales IS NULL THEN
        p_pedidos_totales := 0;
    END IF;
END;
/

DECLARE
	v_total NUMBER;
BEGIN
	contar_pedidos_cliente(1, v_total);
	DBMS_OUTPUT.PUT_LINE('El total de productos es: ' || v_total);
END;
/
