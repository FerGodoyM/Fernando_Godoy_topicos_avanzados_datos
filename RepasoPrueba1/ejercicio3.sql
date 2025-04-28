-- Ejercicio 3

-- Escribe un bloque PL/SQL con un
-- cursor explícito que liste los clientes cuyo
-- total de pedidos (suma de los valores de Total en
-- la tabla Pedidos) sea mayor a 1000, mostrando el
-- nombre del cliente y el total acumulado. Usa un
-- JOIN entre Clientes y Pedidos, y agrupa los
-- resultados con GROUP BY.

SET SERVEROUTPUT ON;

DECLARE
	CURSOR c_clientes IS
	SELECT Clientes.ClienteID, Clientes.Nombre, SUM(Pedidos.Total) FROM Clientes
	INNER JOIN Pedidos
	ON Clientes.ClienteID = Pedidos.ClienteID
	GROUP BY Clientes.ClienteID, Clientes.Nombre
	HAVING SUM(Pedidos.Total) > 1000;

	v_cliente_id Clientes.ClienteID%TYPE;
	v_cliente_nombre Clientes.Nombre%TYPE;
	v_suma_pedidos Pedidos.Total%TYPE;

	v_contador NUMBER := 0;

BEGIN
 	OPEN c_clientes;

	DBMS_OUTPUT.PUT_LINE('---------SE EMPIEZA A LISTAR--------');

	LOOP
 		FETCH c_clientes INTO v_cliente_id, v_cliente_nombre, v_suma_pedidos;
 		EXIT WHEN c_clientes%NOTFOUND;
 		DBMS_OUTPUT.PUT_LINE('ClienteID: ' || v_cliente_id || ', Nombre Cliente: ' || v_cliente_nombre || ', Suma Pedidos: ' || v_suma_pedidos);
 		v_contador := v_contador + 1;
 	END LOOP;

 	IF v_contador = 0 THEN
 		DBMS_OUTPUT.PUT_LINE('NO SE ENCONTRARON CLIENTES CON DICHA CONDICION');
 	END IF;

 	CLOSE c_clientes;

EXCEPTION
	WHEN OTHERS THEN
 	DBMS_OUTPUT.PUT_LINE('Error al listar clientes: ' || SQLERRM);
 	
 	IF c_clientes%ISOPEN THEN
 		CLOSE c_clientes;
 	END IF;

END;
/