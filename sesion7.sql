SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE aumentar_precio_producto(p_producto_id IN NUMBER, p_porcentaje IN NUMBER) AS
	BEGIN
		UPDATE Productos
		SET Precio = Precio * (p_porcentaje/100 + 1)
		WHERE ProductoID = p_producto_id; 
		DBMS_OUTPUT.PUT_LINE('El Precio del producto se a actualizado un ' || p_porcentaje ||'%');
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Uno de los valores ingresados no es valido');
		WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
	END;
/

EXEC aumentar_precio_producto(1, 20);
EXEC aumentar_precio_producto(90, 10);