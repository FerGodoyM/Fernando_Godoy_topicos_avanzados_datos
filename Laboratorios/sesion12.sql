
-- Triggers

-- bloque PL/SQL que se ejecuta automáticamente en respuesta a un evento DML 
-- o DDL en una tabla.

-------------------------EJEMPLOS-------------------------------

-- Trigger para validar el total de un pedido antes de insertarlo.

CREATE OR REPLACE TRIGGER validar_total_pedido
BEFORE INSERT ON Pedidos
FOR EACH ROW
    BEGIN
        IF :NEW.Total <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El total del pedido debe ser mayor a 0.');
        END IF;
    END;
    /

-- Probar el trigger
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (105, 3, -100, SYSDATE);
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (105, 3, 500, SYSDATE);



-- Trigger para registrar cambios en el precio de productos en una tabla de auditoría.

-- Crear tabla de auditoría
CREATE TABLE AuditoriaPrecios (
    AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProductoID NUMBER,
    PrecioAntiguo NUMBER,
    PrecioNuevo NUMBER,
    FechaCambio DATE);

-- Crear trigger
CREATE OR REPLACE TRIGGER auditar_precio_producto
AFTER UPDATE OF Precio ON Productos
FOR EACH ROW
    BEGIN
        INSERT INTO AuditoriaPrecios (ProductoID, PrecioAntiguo, PrecioNuevo, FechaCambio)
        VALUES (:OLD.ProductoID, :OLD.Precio, :NEW.Precio, SYSDATE);
    END;
    /

-- Probar el trigger
UPDATE Productos SET Precio = 1300 WHERE ProductoID = 1;
SELECT * FROM AuditoriaPrecios;



--------------------------EJERCICIOS---------------------------

-- Crea una función calcular_total_con_descuento que
-- reciba un PedidoID (parámetro IN) y devuelva el
-- total del pedido con un descuento del 10% si el
-- total supera 1000. Usa la función en un
-- procedimiento aplicar_descuento_pedido que
-- actualice el total del pedido.

CREATE OR REPLACE FUNCTION calcular_total_con_descuento(pedido_id IN NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT total INTO v_total FROM pedidos
    WHERE id = pedido_id;

    IF v_total > 1000 THEN
        v_total := v_total * 0.9;
    END IF;

    RETURN v_total;
END;
/


CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(pedido_id IN NUMBER) IS
    v_total_con_descuento NUMBER;
BEGIN
    v_total_con_descuento := calcular_total_con_descuento(pedido_id);

    IF v_total_con_descuento IS NOT NULL THEN
        UPDATE pedidos
        SET total = v_total_con_descuento
        WHERE id = pedido_id;

        DBMS_OUTPUT.PUT_LINE('El total del pedido con ID: ' || pedido_id || ' ha sido actualizado a: ' || v_total_con_descuento);
    END IF;
END;
/


-- Crea un trigger validar_cantidad_detalle que se
-- dispare antes de insertar o actualizar en
-- DetallesPedidos y verifique que la Cantidad sea
-- mayor a 0. Si no, lanza un error.


CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
DECLARE
    v_cantidad NUMBER;
BEGIN
    v_cantidad := :NEW.Cantidad;

    IF v_cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La cantidad debe ser mayor a 0.');
    END IF;
END;
/
