--Procedimientos Almacenados

--Explicacion: Este procedimiento actualiza el total de un pedido
--basado en los detalles de los productos y sus cantidades.
--Parametros: p_pedido_id es el ID del pedido cuyo total se va a actualizar.

CREATE OR REPLACE PROCEDURE
    actualizar_total_pedido(p_pedido_id IN NUMBER) AS
    v_nuevo_total NUMBER;
BEGIN
    SELECT SUM(p.Precio * d.Cantidad) INTO v_nuevo_total
    FROM DetallesPedidos d JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.PedidoID = p_pedido_id;
    UPDATE Pedidos SET Total = v_nuevo_total WHERE PedidoID = p_pedido_id;
COMMIT;
END;
/

BEGIN
  actualizar_total_pedido(881);
END;
/

--Funciones Almacenadas

--Explicacion: Esta funcion calcula el costo total de un detalle de pedido
--basado en el precio del producto y la cantidad.

CREATE OR REPLACE FUNCTION calcular_costo_detalle(p_detalle_id IN NUMBER) RETURN
NUMBER AS
    v_costo NUMBER;
BEGIN
    SELECT p.Precio * d.Cantidad INTO v_costo
    FROM DetallesPedidos d JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.DetalleID = p_detalle_id;
    RETURN v_costo;
END;
/

-- Triggers

--Explicacion: Antes de insertar un nuevo pedido, este trigger valida que el total
--del pedido sea mayor a 0. Si no lo es, se genera un error.

CREATE OR REPLACE TRIGGER validar_total_pedido
BEFORE INSERT ON Pedidos
FOR EACH ROW
BEGIN
    IF :NEW.Total <= 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'El total del pedido debe ser mayor a 0.');
    END IF;
END;
/

--PROCEDIMIENTOS CON TRIGGERS

--Escenario: Crear un procedimiento que inserte un
--pedido y sus detalles, con un trigger que
--actualice automáticamente el total del pedido al
--insertar detalles.

--Paso 1: Trigger para actualizar el total del
--pedido al insertar un detalle.

CREATE OR REPLACE TRIGGER actualizar_total_al_detalle
AFTER INSERT ON DetallesPedidos
FOR EACH ROW
DECLARE
    v_nuevo_total NUMBER;
BEGIN
    SELECT SUM(p.Precio * d.Cantidad) INTO v_nuevo_total
    FROM DetallesPedidos d JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.PedidoID = :NEW.PedidoID;
    UPDATE Pedidos
    SET Total = v_nuevo_total
    WHERE PedidoID = :NEW.PedidoID;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    NULL; -- No hacer nada si no hay detalles
END;
/


--Paso 2: Procedimiento para insertar un pedido y
--sus detalles.

CREATE OR REPLACE PROCEDURE insertar_pedido_con_detalle(
    p_pedido_id IN NUMBER,
    p_cliente_id IN NUMBER,
    p_detalle_id IN NUMBER,
    p_producto_id IN NUMBER,
    p_cantidad IN NUMBER
) AS
BEGIN
    -- Insertar el pedido (total inicial 0, se actualizará por el trigger)
    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
    VALUES (p_pedido_id, p_cliente_id, 0, SYSDATE);
    -- Insertar el detalle (dispara el trigger)
    INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
    VALUES (p_detalle_id, p_pedido_id, p_producto_id, p_cantidad);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Pedido ' || p_pedido_id || ' y detalle insertados correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/

-- Ejecutar
EXEC insertar_pedido_con_detalle(106, 3, 4, 1, 1);
SELECT * FROM Pedidos WHERE PedidoID = 106;


--FUNCIONES Y PROCEDIMIENTOS COMBINADOS

--Escenario: Crear una función que calcule el total
--de un cliente con un descuento basado en su
--"nivel" (calculado por otra función), y un
--procedimiento que aplique ese descuento a todos
--los pedidos del cliente.

--Paso 1: Función para determinar el nivel del
--cliente según el total de sus pedidos.

CREATE OR REPLACE FUNCTION determinar_nivel_cliente(p_cliente_id IN NUMBER) RETURN
VARCHAR2 AS
    v_total NUMBER;
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    IF v_total IS NULL THEN
        RETURN 'Básico';
    ELSIF v_total > 2000 THEN
        RETURN 'Premium';
    ELSIF v_total > 1000 THEN
        RETURN 'Regular';
    ELSE
    RETURN 'Básico';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN 'Básico';
END;
/

--Paso 2: Función para calcular el total con
--descuento según el nivel.

CREATE OR REPLACE FUNCTION calcular_total_con_descuento_cliente(p_cliente_id IN NUMBER) RETURN NUMBER AS
    v_total NUMBER;
    v_nivel VARCHAR2(20);
    v_descuento NUMBER;
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    v_nivel := determinar_nivel_cliente(p_cliente_id);
    IF v_nivel = 'Premium' THEN
        v_descuento := 0.15; -- 15% descuento
    ELSIF v_nivel = 'Regular' THEN
        v_descuento := 0.05; -- 5% descuento
    ELSE
        v_descuento := 0;
    END IF;
    RETURN NVL(v_total, 0) * (1 - v_descuento);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/

--Paso 3: Procedimiento para aplicar el descuento a
--los pedidos del cliente.

CREATE OR REPLACE PROCEDURE aplicar_descuento_cliente(p_cliente_id IN NUMBER) AS
v_nuevo_total NUMBER;
    CURSOR pedido_cursor IS
    SELECT PedidoID, Total
    FROM Pedidos
    WHERE ClienteID = p_cliente_id
    FOR UPDATE;
    v_factor NUMBER;
BEGIN
    v_nuevo_total := calcular_total_con_descuento_cliente(p_cliente_id);
    SELECT SUM(Total) INTO v_factor
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    IF v_factor = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Cliente ' || p_cliente_id || ' no tiene pedidos.');
    END IF;
    v_factor := v_nuevo_total / v_factor;
    FOR pedido IN pedido_cursor LOOP
    UPDATE Pedidos
    SET Total = pedido.Total * v_factor
    WHERE CURRENT OF pedido_cursor;
    DBMS_OUTPUT.PUT_LINE('Pedido ' || pedido.PedidoID || ' actualizado a: ' || (pedido.Total * v_factor));
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/
-- Ejecutar
EXEC aplicar_descuento_cliente(1);
