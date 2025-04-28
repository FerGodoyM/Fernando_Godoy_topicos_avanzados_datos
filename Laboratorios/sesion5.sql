--ejercicio 1

--Escribe un bloque anónimo que use un cursor
--explícito para listar 2 atributos de alguna
--clase, ordenados por uno de los atributos.

DECLARE
	CURSOR c_personas IS
		SELECT Nombre, FechaNacimiento FROM Clientes
		ORDER BY FechaNacimiento DESC;

	v_nombre Clientes.Nombre%TYPE;
	v_fecha Clientes.FechaNacimiento%TYPE;

BEGIN
	OPEN c_personas;
	LOOP
		FETCH c_personas INTO v_nombre, v_fecha;
		EXIT WHEN c_personas%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre || ' Fecha de Nacimiento: ' || v_fecha);
	END LOOP;
	CLOSE c_personas;
END;
/

--ejercicio 2

--Escribe un bloque anónimo que use un cursor
--explícito con parámetro para aumentar un 10% el
--total de la suma de algún atributo numérico de un
--elemento de una tabla y muestre los valores
--originales y actualizados. Usa FOR UPDATE.

DECLARE
	CURSOR c_pedidos (v_pedidosid Pedidos.PedidoID%TYPE) IS
		SELECT Total FROM Pedidos
		WHERE PedidoID = v_pedidosid
		FOR UPDATE OF Total NOWAIT;
	
	v_totalviejo Pedidos.Total%TYPE;
	v_totalnuevo Pedidos.Total%TYPE;
BEGIN

	OPEN c_pedidos(101);
	FETCH c_pedidos INTO v_totalviejo;

	IF c_pedidos%FOUND THEN
		v_totalnuevo := v_totalviejo * 1.10;

		UPDATE Pedidos
		SET Total = v_totalnuevo
		WHERE CURRENT OF c_pedidos;

		DBMS_OUTPUT.PUT_LINE('Precio Viejo: ' || v_totalviejo || ' Precio Nuevo: ' || v_totalnuevo);

		COMMIT;
	ELSE
		DBMS_OUTPUT.PUT_LINE('No se encontro el producto');
	END IF;
	CLOSE c_pedidos;
END;
/