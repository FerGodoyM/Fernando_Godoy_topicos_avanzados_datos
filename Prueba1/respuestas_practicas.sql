-- EJERCICIO 1

--Escribe un bloque PL/SQL con un cursor explícito que liste
--los departamentos con un salario promedio mayor a 600000,
--mostrando el nombre del departamento y el promedio de
--salario de sus empleados. Usa un JOIN entre Departamentos y
--Empleados.




-- EJERCICIO 2

-- Escribe un bloque PL/SQL con un cursor explícito que reduzca
-- un 5% el presupuesto de los proyectos que tienen un
-- presupuesto mayor a 1500000. Usa FOR UPDATE y maneja
-- excepciones.



--EJERCICIO 3

-- Crea un tipo de objeto empleado_obj con atributos
-- empleado_id, nombre, y un método get_info. Luego, crea una
-- tabla basada en ese tipo y transfiere los datos de Empleados
-- a esa tabla. Finalmente, escribe un cursor explícito que
-- liste la información de los empleados usando el método
-- get_info.

CREATE OR REPLACE TYPE empleado_obj AS OBJECT(
	empleado_id NUMBER,
	nombre VARCHAR2(50),
	MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY empleado_obj AS
	MEMBER FUNCTION get_info RETURN VARCHAR2 IS
	BEGIN
		RETURN 'ID: ' || TO_CHAR(empleado_id) || ', Nombre: ' || nombre;
	END get_info;
END;
/

CREATE TABLE Empleados_Obj OF empleado_obj(
	empleado_id PRIMARY KEY 
);

INSERT INTO Empleados_Obj (empleado_id, nombre)
SELECT EmpleadoID, Nombre FROM Empleados;


DECLARE
	CURSOR c_listar IS
	SELECT VALUE(e) FROM Empleados_Obj e;

	v_empleado empleado_obj;

BEGIN
	OPEN c_listar;

	LOOP
		FETCH c_listar INTO v_empleado;
		EXIT WHEN c_listar%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE(v_empleado.get_info());
	END LOOP;
	CLOSE c_listar;
END;
/