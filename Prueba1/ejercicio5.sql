--Ejercicio 5

-- Crea un tipo de objeto cliente_obj
-- con los atributos cliente_id, nombre, y un método
-- get_info que devuelva una cadena con la
-- información del cliente. Crea una tabla basada en
-- ese tipo, transfiere los datos de la tabla
-- Clientes a esa tabla, y escribe un bloque PL/SQL
-- con un cursor explícito que liste la información
-- de los clientes usando el método get_info

CREATE OR REPLACE TYPE cliente_obj AS OBJECT(
	cliente_id NUMBER,
	nombre VARCHAR2(50),
	MEMBER FUNCTION get_info RETURN VARCHAR2	--MEMBER FUNCTION Es una función que trabaja sobre una instancia específica del objeto
);												--si quiero que trabaje sobre todas las instancias seria "STATIC FUNCTION"
/

CREATE OR REPLACE TYPE BODY cliente_obj AS
	MEMBER FUNCTION get_info RETURN VARCHAR2 IS
	BEGIN
		RETURN 'ID: ' || TO_CHAR(cliente_id) || ', Nombre: ' || nombre;
	END get_info;
END;
/

CREATE TABLE Clientes_Obj OF cliente_obj(
	cliente_id PRIMARY KEY 
);

INSERT INTO Clientes_Obj (cliente_id, nombre)
SELECT ClienteID, Nombre FROM Clientes;

DECLARE
	CURSOR c_listar IS
	SELECT VALUE(c) FROM Clientes_Obj c; -- VALUE(c) para trabajar con objetos completos (EL ALIAS ES OBLIGATORIO, SI NO NO FUNCIONAAAA)

	v_cliente cliente_obj;

BEGIN
	OPEN c_listar;

	LOOP
		FETCH c_listar INTO v_cliente;
		EXIT WHEN c_listar%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE(v_cliente.get_info());
	END LOOP;
	CLOSE c_listar;
END;
/