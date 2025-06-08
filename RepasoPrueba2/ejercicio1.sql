--Crea un procedimiento
--actualizar_precios_por_categoria que reciba un
--porcentaje de aumento (parámetro IN) y aplique el
--aumento solo a productos cuyo precio promedio por
--pedido (calculado con una función) sea mayor a
--500. Usa un cursor para iterar sobre los
--productos.

CREATE OR REPLACE FUNCTION calcular_precio_promedio(p_producto_id IN NUMBER) RETURN 
NUMBER AS
	v_promedio NUMBER;
BEGIN
	SELECT AVG(Productos.Precio * DetallesPedidos.Cantidad) INTO v_promedio
	FROM Productos
	INNER JOIN DetallesPedidos
	ON Productos.ProductoID = DetallesPedidos.ProductoID
	WHERE Productos.ProductoID = p_producto_id;
	RETURN NVL(v_promedio, 0);
END;
/

CREATE OR REPLACE PROCEDURE actualizar_precios_por_categoria(p_porcentaje IN NUMBER) AS
	CURSOR productos_cursor IS
	SELECT ProductoID, Precio
	FROM Productos;
BEGIN
	FOR producto IN productos_cursor LOOP
	IF calcular_precio_promedio(producto.ProductoID) > 500 THEN
		UPDATE Productos
		SET Precio = producto.Precio * (1+ p_porcentaje /100)
		WHERE ProductoID = producto.ProductoID;
		DBMS_OUTPUT.PUT_LINE('Producto ' || producto.ProductoID || 'actualizado');
	END IF;
	END LOOP;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE('Error:' || SQLERRM);
	ROLLBACK;
END;
/

EXEC actualizar_precios_por_categoria(10);