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

