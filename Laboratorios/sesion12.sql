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
    SELECT total
    INTO v_total
    FROM pedidos
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
