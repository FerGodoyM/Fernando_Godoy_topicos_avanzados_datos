-- Crea una función calcular_edad_cliente que reciba
-- un ClienteID (parámetro IN) y devuelva la edad
-- del cliente en años (basado en FechaNacimiento).
-- Maneja excepciones si el cliente no existe.

Create or replace function calcular_edad_cliente(
    p_cliente_id IN NUMBER
) RETURN NUMBER IS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    -- Obtener la fecha de nacimiento del cliente
    SELECT FechaNacimiento
    INTO v_fecha_nacimiento
    FROM Clientes
    WHERE ClienteID = p_cliente_id;

    -- Calcular la edad en años
    v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    RETURN v_edad;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Cliente no encontrado.');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        RETURN NULL;
END;
/


-- Crea una función obtener_precio_promedio que
-- devuelva el precio promedio de todos los
-- productos. Úsala en una consulta SQL para listar
-- los productos cuyo precio está por encima del
-- promedio.

Create or replace function obtener_precio_promedio
RETURN NUMBER IS
    v_precio_promedio NUMBER;
BEGIN
    SELECT AVG(Precio)
    INTO v_precio_promedio
    FROM Productos;

    RETURN v_precio_promedio;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        RETURN NULL;
END;
/

SELECT * FROM Productos
WHERE Precio > obtener_precio_promedio();
