---Procedimientos Almacenados

-----------------------EJEMPLOS---------------------------


--Procedimientos Almacenados Basicos
--es un bloque PL/SQL con nombre, almacenado en la base de datos.

--Procedimiento para contar pedidos de un cliente.

CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(
    p_cliente_id IN NUMBER, p_cantidad OUT NUMBER) AS
    BEGIN
        SELECT COUNT(*) INTO p_cantidad FROM Pedidos
        WHERE ClienteID = p_cliente_id;
        DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' tiene ' || p_cantidad || ' pedidos.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN p_cantidad := 0;
        DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' no tiene pedidos.');
    END;
    /

-- Ejecutar
DECLARE
    v_cantidad NUMBER;
BEGIN
    contar_pedidos_cliente(1, v_cantidad);
END;
/

--  Procedimiento Con Logica Condicional y Bucles
--  Uso de IF, ELSIF, ELSE para tomar decisiones y LOOP, WHILE, FOR para iterar.

--Procedimiento que clasifica clientes según el total de sus pedidos.

CREATE OR REPLACE PROCEDURE clasificar_cliente(p_cliente_id IN NUMBER) AS
    v_total NUMBER := 0;
    v_clasificacion VARCHAR2(20);
    BEGIN
        SELECT SUM(Total) INTO v_total FROM Pedidos
        WHERE ClienteID = p_cliente_id;
        IF v_total IS NULL THEN
            v_total := 0;
        END IF;
        IF v_total > 1000 THEN
            v_clasificacion := 'Premium';
        ELSIF v_total > 500 THEN
            v_clasificacion := 'Regular';
        ELSE
            v_clasificacion := 'Básico';
        END IF;
        DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ': ' || v_clasificacion || ' (Total: ' ||
        v_total || ')');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' no tiene pedidos.');
    END;
    /
-- Ejecutar
EXEC clasificar_cliente(1);
EXEC clasificar_cliente(2);

--Procedimiento que aplica un descuento a productos usando un bucle.

CREATE OR REPLACE PROCEDURE aplicar_descuento(p_porcentaje IN NUMBER) AS
v_precio NUMBER;
    CURSOR producto_cursor IS
    SELECT ProductoID, Precio
    FROM Productos
    FOR UPDATE;
    
    BEGIN
        FOR producto IN producto_cursor LOOP
        v_precio := producto.Precio * (1 - p_porcentaje / 100);
        UPDATE Productos
        SET Precio = v_precio
        WHERE ProductoID = producto.ProductoID;
        DBMS_OUTPUT.PUT_LINE('Producto ' || producto.ProductoID || ': Nuevo precio: ' ||
        v_precio);
        END LOOP;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
    END;
    /
-- Ejecutar
EXEC aplicar_descuento(10);


--   Parámetro IN OUT:
--   Permite que un parámetro sea usado como entrada y salida.

--  Procedimiento con parámetro IN OUT para actualizar y devolver el total de un pedido.

CREATE OR REPLACE PROCEDURE actualizar_total_pedido(p_pedido_id IN NUMBER, p_incremento IN OUT NUMBER) AS
    BEGIN
        UPDATE Pedidos
        SET Total = Total + p_incremento
        WHERE PedidoID = p_pedido_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Pedido con ID ' || p_pedido_id || ' no encontrado.');
        END IF;

        SELECT Total INTO p_incremento FROM Pedidos
        WHERE PedidoID = p_pedido_id;
        DBMS_OUTPUT.PUT_LINE('Nuevo total del pedido ' || p_pedido_id || ': ' || p_incremento);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
    END;
    /

-- Ejecutar
DECLARE
    v_incremento NUMBER := 100;
BEGIN
    actualizar_total_pedido(101, v_incremento);
    DBMS_OUTPUT.PUT_LINE('Total actualizado: ' || v_incremento);
END;
/


--Procedimiento con valor por defecto para aplicar un aumento de precio.

CREATE OR REPLACE PROCEDURE aumentar_precio_defecto(
    p_producto_id IN NUMBER, p_porcentaje IN NUMBER DEFAULT 5) AS
    BEGIN
        UPDATE Productos
        SET Precio = Precio * (1 + p_porcentaje / 100)
        WHERE ProductoID = p_producto_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Producto con ID ' || p_producto_id || ' no encontrado.');
        END IF;
        DBMS_OUTPUT.PUT_LINE('Precio del producto ' || p_producto_id || ' aumentado en ' || p_porcentaje || '%.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/
-- Ejecutar
EXEC aumentar_precio_defecto(1); -- Usa el valor por defecto (5%)
EXEC aumentar_precio_defecto(1, 10); -- Especifica un 10%


--  Procedimientos con Transacciones y Rollback
-- Las Transacciones son un conjunto de operaciones que deben completarse
-- como una unidad (o revertirse). y el Rollback, revierte los cambios si ocurre un error.


--  Procedimiento que inserta un pedido y sus detalles, con rollback si falla.

CREATE OR REPLACE PROCEDURE insertar_pedido_detalle(
    p_pedido_id IN NUMBER,
    p_cliente_id IN NUMBER,
    p_total IN NUMBER,
    p_producto_id IN NUMBER,
    p_cantidad IN NUMBER) AS
    v_detalle_id NUMBER;

    BEGIN
        -- Insertar el pedido
        INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
        VALUES (p_pedido_id, p_cliente_id, p_total, SYSDATE);
        -- Obtener el próximo DetalleID
        SELECT NVL(MAX(DetalleID), 0) + 1 INTO v_detalle_id FROM DetallesPedidos;
        -- Insertar el detalle del pedido
        INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
        VALUES (v_detalle_id, p_pedido_id, p_producto_id, p_cantidad);
        -- Confirmar la transacción
        DBMS_OUTPUT.PUT_LINE('Pedido ' || p_pedido_id || ' y detalle insertados correctamente.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/
-- Ejecutar
EXEC insertar_pedido_detalle(104, 3, 400, 1, 1);
EXEC insertar_pedido_detalle(104, 3, 300, 2, 2); -- Falla por PedidoID duplicado

------------------------EJERCICIOS-----------------------------

-- Crea un procedimiento actualizar_total_pedidos
-- que reciba un ClienteID (parámetro IN) y un
-- porcentaje de aumento (parámetro IN con valor por
-- defecto 10%). Aumenta el total de todos los
-- pedidos del cliente en el porcentaje
-- especificado. Usa un bucle para iterar sobre los
-- pedidos.

CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_cliente_id IN NUMBER, p_porcentaje IN NUMBER DEFAULT 10)
AS
    CURSOR pedido_cursor IS
    SELECT PedidoID, Total
    FROM Pedidos
    WHERE ClienteID = p_cliente_id
    FOR UPDATE;
BEGIN
    FOR pedido IN pedido_cursor LOOP
        UPDATE Pedidos
        SET Total = pedido.Total * (1 + p_porcentaje / 100)
        WHERE CURRENT OF pedido_cursor;
        DBMS_OUTPUT.PUT_LINE('Pedido ' || pedido.PedidoID || ': Nuevo total: ' || (pedido.Total * (1 + p_porcentaje / 100)));
    END LOOP;
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' no tiene pedidos.');
    ELSE
    COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/

-- Llamada al procedimiento para probarlo
SET SERVEROUTPUT ON;
EXEC actualizar_total_pedidos(1);


-- Crea un procedimiento calcular_costo_detalle que
-- reciba un DetalleID (parámetro IN) y devuelva el
-- costo total del detalle (parámetro IN OUT). El
-- costo se calcula como Precio * Cantidad (usando
-- las tablas DetallesPedidos y Productos). Maneja
-- excepciones si el detalle no existe.


CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo IN OUT NUMBER) AS
v_precio NUMBER;
v_cantidad NUMBER;
BEGIN
    SELECT p.Precio, d.Cantidad INTO v_precio, v_cantidad
    FROM DetallesPedidos d
    JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.DetalleID = p_detalle_id;
    p_costo := v_precio * v_cantidad;
    DBMS_OUTPUT.PUT_LINE('Costo del detalle ' || p_detalle_id || ': ' || p_costo);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Detalle con ID ' || p_detalle_id || ' no encontrado.');
END;
/

DECLARE
    v_costo NUMBER := 0;
BEGIN
    calcular_costo_detalle(1, v_costo);
    DBMS_OUTPUT.PUT_LINE('Costo calculado: ' || v_costo);
END;
/