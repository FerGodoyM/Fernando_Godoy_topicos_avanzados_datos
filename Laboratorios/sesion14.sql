
-- Herencia
-- permite a un tipo de dato (subtipo) heredar atributos
-- y métodos de otro tipo (supertipo) y se implementa
-- a través de un modelo objeto-relacional
---------------------EJEMPLOS-------------------------------
-- Ejemplo Persona, Empleado y Gerente

-- Crear un supertipo Persona.

CREATE OR REPLACE TYPE Persona AS OBJECT (
    Nombre VARCHAR2(50),
    FechaNacimiento DATE,
    MEMBER FUNCTION calcular_edad RETURN NUMBER
) NOT FINAL;
/
-- Definir el cuerpo del método
CREATE OR REPLACE TYPE BODY Persona AS
    MEMBER FUNCTION calcular_edad RETURN NUMBER IS
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, FechaNacimiento) / 12);
    END;
END;
/

-- Crear un subtipo Empleado.

CREATE OR REPLACE TYPE Empleado UNDER Persona (
    Salario NUMBER,
    MEMBER FUNCTION calcular_salario_anual RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Empleado AS
    MEMBER FUNCTION calcular_salario_anual RETURN NUMBER IS
    BEGIN
        RETURN Salario * 12;
    END;
END;
/


-- Crear un subtipo Gerente

CREATE OR REPLACE TYPE Gerente UNDER Empleado (
    Departamento VARCHAR2(50),
    OVERRIDING MEMBER FUNCTION calcular_salario_anual RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Gerente AS
    OVERRIDING MEMBER FUNCTION calcular_salario_anual RETURN NUMBER
IS
    BEGIN
        RETURN (Salario * 12) * 1.1; -- 10% adicional para gerentes
    END;
END;
/

--Crear una tabla de objetos que use el supertipo Persona.

CREATE TABLE Personas OF Persona;

-- Insertar una Persona
INSERT INTO Personas
VALUES (Persona('Ana Gómez', TO_DATE('1990-01-15', 'YYYY-MM-DD')));
-- Insertar un Empleado
INSERT INTO Personas
VALUES (Empleado('Carlos Pérez', TO_DATE('1985-06-20', 'YYYY-MM-DD'), 500000));
-- Insertar un Gerente
INSERT INTO Personas
VALUES (Gerente('María López', TO_DATE('1975-03-10', 'YYYY-MM-DD'), 800000, 'Ventas'));


-- Consultar todas las personas
SELECT p.Nombre, p.calcular_edad() AS Edad
FROM Personas p;
-- Consultar solo empleados (incluye gerentes)
SELECT e.Nombre, e.Salario, e.calcular_salario_anual() AS
SalarioAnual
FROM Personas e
WHERE VALUE(e) IS OF (Empleado);
-- Consultar solo gerentes
SELECT g.Nombre, g.Departamento, g.calcular_salario_anual() AS
SalarioAnual
FROM Personas g
WHERE VALUE(g) IS OF (ONLY Gerente);

----------------------EJERCICIOS-----------------------------
-- Crea un supertipo Vehiculo con atributos Marca y
--Año, y un método obtener_antiguedad. Luego, crea
--un subtipo Automovil que herede de Vehiculo, con
--un atributo adicional NumeroPuertas y un método
--descripcion que devuelva una cadena con los
--detalles del automóvil.

CREATE OR REPLACE TYPE Vehiculo AS OBJECT (
    Marca VARCHAR2(50),
    Anio NUMBER,
    
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Vehiculo AS 
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM SYSDATE) - Anio;
    END;
END;
/

CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
    NumeroPuertas NUMBER, 
    MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY Automovil AS 
    MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Marca: ' || Marca || ', Año: ' || Anio || ', Antigüedad: ' || obtener_antiguedad || ' años' || ', Puertas: ' || NumeroPuertas;
    END;
END;
/

DECLARE
    a Automovil := Automovil('Toyota', 2018, 4);
BEGIN
    DBMS_OUTPUT.PUT_LINE(a.descripcion);
END;
/


--Crea un subtipo Camion que herede de Vehiculo,
--con un atributo adicional CapacidadCarga (en
--toneladas) y sobrescriba el método
--obtener_antiguedad para sumar 2 años adicionales
--(los camiones envejecen más rápido). Inserta un
--camión en la tabla Vehiculos y consulta su
--antigüedad y descripción.

CREATE OR REPLACE TYPE Camion UNDER Vehiculo (
    CapacidadCarga NUMBER,
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER,
    OVERRIDING MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY Camion AS
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        RETURN (EXTRACT(YEAR FROM SYSDATE) - Anio) + 2;
    END;

    OVERRIDING MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Marca: ' || Marca || ', Año: ' || Anio || ', Antigüedad (ajustada): ' || obtener_antiguedad || 
               ' años, Capacidad de carga: ' || CapacidadCarga || ' toneladas';
    END;
END;
/

CREATE TABLE Vehiculos OF Vehiculo;
INSERT INTO Vehiculos 
VALUES (Camion('Volvo', 2015, 12));

DECLARE
    v Vehiculo;
BEGIN
    SELECT VALUE(v) INTO v FROM Vehiculos v WHERE Marca = 'Volvo';

    DBMS_OUTPUT.PUT_LINE(v.descripcion);
END;
/

