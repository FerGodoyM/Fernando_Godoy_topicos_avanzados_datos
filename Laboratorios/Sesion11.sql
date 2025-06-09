-- Funciones Almacenadas

--  es un bloque PL/SQL con nombre que devuelve un valor único y se almacena
--  en la base de datos.

--------------------EJEMPLOS------------------------

--  Función simple que devuelve un mensaje.

CREATE OR REPLACE FUNCTION saludar RETURN VARCHAR2 AS
    BEGIN
        RETURN '¡Hola, bienvenidos a la Sesión 11!';
    END;
    /

-- Ejecutar
DECLARE
    v_mensaje VARCHAR2(100);
BEGIN
    v_mensaje := saludar;
    DBMS_OUTPUT.PUT_LINE(v_mensaje);
END;
/

-- Función que calcula el total de pedidos de un cliente.

CREATE OR REPLACE FUNCTION total_pedidos(p_cliente_id IN NUMBER) RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    IF v_total IS NULL THEN
        RETURN 0;
    END IF;
    RETURN v_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/
-- Ejecutar
DECLARE
    v_resultado NUMBER;
BEGIN
    v_resultado := total_pedidos(1);
    DBMS_OUTPUT.PUT_LINE('Total de pedidos del cliente 1: ' || v_resultado);
END;
/


-- Funciones con Parámetros y Excepciones

-- Función que calcula el costo de un detalle de pedido.

CREATE OR REPLACE FUNCTION calcular_costo_detalle(p_detalle_id IN NUMBER) 
RETURN NUMBER AS
    v_precio NUMBER;
    v_cantidad NUMBER;
    v_costo NUMBER;

    BEGIN
        SELECT p.Precio, d.Cantidad INTO v_precio, v_cantidad
        FROM DetallesPedidos d
        JOIN Productos p ON d.ProductoID = p.ProductoID
        WHERE d.DetalleID = p_detalle_id;
        v_costo := v_precio * v_cantidad;
        RETURN v_costo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Detalle con ID ' || p_detalle_id || ' no encontrado.');
    END;
    /
-- Ejecutar
DECLARE
    v_costo NUMBER;
BEGIN
    v_costo := calcular_costo_detalle(1);
    DBMS_OUTPUT.PUT_LINE('Costo del detalle 1: ' || v_costo);
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

--Función que calcula el descuento de un producto según su precio.

CREATE OR REPLACE FUNCTION calcular_descuento(p_producto_id IN NUMBER) 
RETURN NUMBER AS
    v_precio NUMBER;
    v_descuento NUMBER;
    
    BEGIN
        SELECT Precio INTO v_precio
        FROM Productos
        WHERE ProductoID = p_producto_id;
        IF v_precio > 1000 THEN
            v_descuento := v_precio * 0.1; -- 10% de descuento
        ELSIF v_precio > 500 THEN
            v_descuento := v_precio * 0.05; -- 5% de descuento
        ELSE
            v_descuento := 0;
        END IF;
        RETURN v_descuento;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Producto con ID ' || p_producto_id || ' no encontrado.');
    END;
    /

-- Ejecutar
DECLARE
    v_descuento NUMBER;
BEGIN
    v_descuento := calcular_descuento(1);
    DBMS_OUTPUT.PUT_LINE('Descuento del producto 1: ' || v_descuento);
    EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Uso de funciones directamente en consultas

--Usar la función calcular_costo_detalle
--en una consulta para listar detalles con su
--costo.

SELECT d.DetalleID, d.PedidoID, d.ProductoID,
d.Cantidad, calcular_costo_detalle(d.DetalleID) AS Costo
FROM DetallesPedidos d;

-----------------------EJERCICIOS--------------------------
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
