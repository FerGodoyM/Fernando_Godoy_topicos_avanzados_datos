
-----------------EJERCICIO 1-------------------

--Crea un paquete gestion_clientes con:

--	1)Un procedimiento registrar_cliente que reciba
--	ClienteID, Nombre, Ciudad y FechaNacimiento, y
--	valide que la fecha de nacimiento sea anterior a
--	la fecha actual.

--	2) Una función obtener_edad que reciba un ClienteID
--	y devuelva la edad del cliente.

--	3) Usa una variable global para contar los clientes
--	registrados.

CREATE OR REPLACE PACKAGE gestion_clientes AS

	v_contador_clientes NUMBER;

	PROCEDURE registrar_cliente(
		p_nombre IN VARCHAR2(50),
		p_ciudad IN VARCHAR2(50),
		p_fecha DATE);

	FUNCTION obtener_edad(p_cliente_id IN NUMBER) 
	RETURN NUMBER;

END gestion_clientes;
/


CREATE OR REPLACE PACKAGE BODY gestion_clientes AS
	v_contador_clientes NUMBER := 0;

	PROCEDURE registrar_cliente(
		p_nombre IN VARCHAR2(50),
		p_ciudad IN VARCHAR2(50),
		p_fecha IN DATE) IS
		v_cliente_id NUMBER;

	BEGIN
		--	Encuentra el ultimo ClienteID y le asigna el siguiente al nuevo cliente
		SELECT NVL(MAX(ClienteID), 0) + 1 INTO v_cliente_id FROM Clientes;

		IF p_fecha < SYSDATE THEN
			INSERT INTO Clientes(ClienteID, Nombre, Ciudad, FechaNacimiento)
			VALUES (v_cliente_id, p_nombre, p_ciudad, p_fecha);
			v_contador_clientes := v_contador_clientes + 1;
			DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_cliente_id || ' Nombre: ' 
				|| p_nombre || ' Ciudad: ' || p_ciudad 
				|| ' Fecha Nacimiento: ' || p_fecha);
		ELSE
			DBMS_OUTPUT.PUT_LINE('La fecha debe ser anterior a la actual');
		END IF;
--	EXCEPTION
-- 		WHEN OTHERS THEN
-- 		DBMS_OUTPUT.PUT_LINE('Error al registrar pedido: ' || SQLERRM);
-- 	RAISE;
	END registrar_cliente;

	FUNCTION obtener_edad(p_cliente_id IN NUMBER)
	RETURN NUMBER IS
		v_fecha DATE;
		v_edad NUMBER := 0;

	BEGIN
		SELECT FechaNacimiento INTO v_fecha FROM Clientes
		WHERE ClienteID = p_cliente_id;

		v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha) / 12);
		RETURN v_edad;
--	EXCEPTION
--    	WHEN NO_DATA_FOUND THEN
--		RETURN NULL;

	END obtener_edad;

END gestion_clientes;
/



--------------------EJERCICIO 2---------------------
--Modifica el paquete gestion_clientes para incluir
--una excepción personalizada e_edad_invalida que se
--lance si el cliente tiene menos de 18 años al
--registrarlo. Prueba el paquete con un cliente menor
--de edad.

CREATE OR REPLACE PACKAGE gestion_clientes AS

    v_contador_clientes NUMBER;

    -- Excepción personalizada
    e_edad_invalida EXCEPTION;

    PROCEDURE registrar_cliente(
        p_cliente_id IN NUMBER,
        p_nombre IN VARCHAR2,
        p_ciudad IN VARCHAR2,
        p_fecha IN DATE
    );

    FUNCTION obtener_edad(p_cliente_id IN NUMBER) 
    RETURN NUMBER;

END gestion_clientes;
/

CREATE OR REPLACE PACKAGE BODY gestion_clientes AS

    FUNCTION obtener_edad(p_cliente_id IN NUMBER)
    RETURN NUMBER IS
        v_fecha DATE;
        v_edad  NUMBER;
    BEGIN
        SELECT FechaNacimiento INTO v_fecha
        FROM Clientes
        WHERE ClienteID = p_cliente_id;

        v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha) / 12);
        RETURN v_edad;

--    EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--            DBMS_OUTPUT.PUT_LINE('Cliente no encontrado.');
--            RETURN NULL;
    END obtener_edad;

    PROCEDURE registrar_cliente(
        p_nombre IN VARCHAR2,
        p_ciudad IN VARCHAR2,
        p_fecha  IN DATE
    ) IS
        v_cliente_id NUMBER;
        v_edad       NUMBER;
    BEGIN
        -- Validar fecha
        IF p_fecha >= SYSDATE THEN
            DBMS_OUTPUT.PUT_LINE('La fecha de nacimiento debe ser anterior a hoy.');
            RETURN;
        END IF;

        -- Calcular edad directamente sin acceder aún a la tabla
        v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, p_fecha) / 12);

        IF v_edad < 18 THEN
            RAISE e_edad_invalida;
        END IF;

        -- Obtener el siguiente ClienteID
        SELECT NVL(MAX(ClienteID), 0) + 1 INTO v_cliente_id FROM Clientes;

        -- Insertar cliente
        INSERT INTO Clientes(ClienteID, Nombre, Ciudad, FechaNacimiento)
        VALUES (v_cliente_id, p_nombre, p_ciudad, p_fecha);

        v_contador_clientes := v_contador_clientes + 1;

        DBMS_OUTPUT.PUT_LINE('Cliente registrado exitosamente. ID: ' || v_cliente_id);

    EXCEPTION
        WHEN e_edad_invalida THEN
            DBMS_OUTPUT.PUT_LINE('Error: El cliente debe ser mayor de edad (18+).');
--        WHEN OTHERS THEN
--            DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
    END registrar_cliente;

END gestion_clientes;
/
