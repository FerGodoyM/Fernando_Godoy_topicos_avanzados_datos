--Ejercicio 2

-- Escribe un cursor explícito que
-- aumente un 15% los precios de productos con
-- precio inferior a 1000 y maneje una excepción si
-- falla.

SET SERVEROUTPUT ON;

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