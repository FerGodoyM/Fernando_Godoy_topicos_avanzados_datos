-------------------PARTE 1-------------------------

--------EJERCICIO 1
--Explica la diferencia entre un procedimiento almacenado y una
--función almacenada en PL/SQL. Da un ejemplo de cuándo usarías
--cada uno en el contexto de la base de datos de la prueba.


--Respuesta: La diferencia entre un procedimiento almacenado y una funcion
--es que: el Procedimiento Almacenado es una consulta SQL que esta guardada
--en memoria con un nombre, pero que no retorna ningun valor.
--por otra parte una funcion almacenada al igual que un procedimiento
--es una consulta que esta guardada en memoria con un nombre, pero
--esta si retorna un valor unico.

-- Un ejemplo de uso podria ser: Calcular un porcentaje de descuento por
-- cantidad de compras que tiene un cliente. en este caso vendria bien
-- utilizar una funcion, debido a que nos interesa que nos retorne un
-- porcentaje para poder hacer operaciones con el.

-- Por otra parte un ejemplo de un Procedimiento podria ser utilizar
-- insertar datos en una tabla. en ese caso no nos interesa que retorne
-- un valor, si no que simplemente ejecute la accion.


--------EJERCICIO 2

--Describe cómo usarías un parámetro IN OUT en un procedimiento
--almacenado. Escribe un ejemplo de un procedimiento que use un
--parámetro IN OUT para actualizar y devolver la cantidad en
--inventario después de un movimiento.


-- RESPUESTA: El parametro IN OUT en procedimientos almacenados nos permite
-- utilizar un parametro como entrada y salida.

-- Para este ejemplo nosotros le estamos otorgando cuando debe disminuir
-- la cantidad de inventario y nos otorga como OUT la cantidad de inventario que nos
-- Quedaria

CREATE OR REPLACE PROCEDURE actualizar_inventario(p_inventario_id IN NUMBER, p_cambio IN OUT NUMBER) AS
    BEGIN
        UPDATE Inventario
        SET Cantidad = Cantidad - p_cambio
        WHERE InventarioID = p_inventario_id

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Inventario con ID ' || p_inventario_id || ' no encontrado.');
        END IF;

        SELECT Cantidad INTO p_cambio FROM Inventario
        WHERE InventarioID = p_inventario_id;
        DBMS_OUTPUT.PUT_LINE('Nuevo total del Inventario ' || p_inventario_id || ': ' || p_cambio);
        COMMIT;
    END;
    /


--------EJERCICIO 3
--¿Cómo se puede usar una función almacenada dentro de una
--consulta SQL? Escribe un ejemplo de una función que calcule el
--valor total del inventario de un producto (Precio * Cantidad)
--y úsala en una consulta para listar los productos con su valor
--total.

CREATE OR REPLACE FUNCTION calcular_valor_inventario(p_producto_id IN NUMBER)
RETURN NUMBER AS
    v_precio NUMBER;
    v_cantidad NUMBER;
    v_total NUMBER;
    BEGIN
        SELECT Productos.Precio, Inventario.Cantidad INTO v_precio, v_cantidad FROM Productos
        INNER JOIN Inventario
        ON Productos.ProductoID = Inventario.ProductoID
        WHERE Productos.ProductoID = p_producto_id;
        
        v_total := v_precio * v_cantidad;
        RETURN v_total;
    END;
    /

--Las funciones almacenadas se pueden utilizar directamente en una consulta
--unicamente le debes entregar los parametros necesarios
SELECT InventarioID, ProductoID, Cantidad, calcular_valor_inventario(ProductoID) AS valor
FROM Inventario;


--------EJERCICIO 4

--Explica qué es un trigger y menciona dos tipos de eventos que
--pueden dispararlo. Da un ejemplo de un trigger que se dispare
--después de insertar un movimiento en la tabla Movimientos y
--actualice la cantidad en Inventario.

-- Respuesta: Un trigger es un bloque PL/SQL que se ejecuta automaticamente
-- tras un evento DML O DDL en una tabla.

CREATE OR REPLACE TRIGGER movimientos_actualizar_inventario
AFTER INSERT ON Movimientos
FOR EACH ROW
DECLARE
    BEGIN
        IF :NEW.TipoMovimiento = 'Entrada' THEN
            UPDATE Inventario
            SET Cantidad = Cantidad + :NEW.Cantidad
            WHERE Inventario.ProductoID = :NEW.ProductoID;
        ELSE IF :NEW.TipoMovimiento = 'Salida' THEN
            UPDATE Inventario
            SET Cantidad = Cantidad - :NEW.Cantidad
            WHERE Inventario.ProductoID = :NEW.ProductoID;
        END IF;
    END;
    /


-------------------PARTE 2-------------------------


---------EJERCICIO 1
--Escribe un procedimiento registrar_movimiento que reciba un
--ProductoID, TipoMovimiento ('Entrada' o 'Salida'), y
--Cantidad (parámetros IN). El procedimiento debe:

--○ Insertar un nuevo movimiento en la tabla Movimientos (usa
--el próximo MovimientoID disponible).
--○ Actualizar la cantidad en Inventario según el tipo de
--movimiento.
--○ Actualizar la FechaActualizacion en Inventario a la fecha
--actual.
--○ Manejar excepciones si el producto no existe o si la
--cantidad en inventario se vuelve negativa.

CREATE OR REPLACE PROCEDURE registrar_movimiento(
    p_producto_id IN NUMBER,
    p_tipo_movimiento IN VARCHAR2(10),
    p_cantidad IN NUMBER) AS
    v_movimiento_id IN NUMBER,
    v_inventario IN NUMBER

    BEGIN
        SELECT Cantidad INTO v_inventario FROM Inventario
        WHERE ProductoID = p_producto_id;

        SELECT NVL(MAX(MovimientoID), 0) + 1 INTO v_movimiento_id FROM Movimientos;

        INSERT INTO Movimientos (MovimientoID, ProductoID, TipoMovimiento, Cantidad, FechaMovimiento)
        VALUES (v_movimiento_id, p_producto_id, p_tipo_movimiento, p_cantidad, SYSDATE);

        IF p_tipo_movimiento = 'Entrada' THEN
            UPDATE Inventario
            SET Cantidad = Cantidad + p_cantidad
            WHERE Inventario.ProductoID = p_producto_id;

            UPDATE Inventario
            SET FechaActualizacion = SYSDATE
            WHERE Inventario.ProductoID = p_producto_id;
            DBMS_OUTPUT.PUT_LINE('Movimiento ' || v_movimiento_id || ' Insertado y Inventario Actualizado');

        ELSE IF p_tipo_movimiento = 'Salida' || ((v_inventario - p_cantidad) >= 0) THEN
            UPDATE Inventario
            SET Cantidad = Cantidad - p_cantidad
            WHERE Inventario.ProductoID = p_producto_id;

            UPDATE Inventario
            SET FechaActualizacion = SYSDATE
            WHERE Inventario.ProductoID = p_producto_id;
            DBMS_OUTPUT.PUT_LINE('Movimiento ' || v_movimiento_id || ' Insertado y Inventario Actualizado');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Ocurrio un error !');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
    END;
    /



-----------EJERCICIO2

--Escribe una función calcular_valor_inventario_proveedor que
--reciba un ProveedorID (parámetro IN) y devuelva el valor
--total del inventario de los productos de ese proveedor (suma
--de Precio * Cantidad). Luego, usa la función en un
--procedimiento mostrar_valor_proveedor que muestre el valor
--total del inventario por proveedor para todos los
--proveedores.

CREATE OR REPLACE FUNCTION calcular_valor_inventario_proveedor(p_proveedor_id IN NUMBER)
RETURN NUMBER AS
    v_precio NUMBER,
    v_cantidad NUMBER,
    v_total NUMBER,
    v_producto_id NUMBER
    BEGIN
        SELECT Precio, ProductoID INTO v_precio, v_producto_id FROM Productos
        WHERE ProveedorID = p_proveedor_id;

        SELECT Cantidad INTO v_cantidad FROM Inventario
        WHERE ProductoID = v_producto_id;

        v_total := v_precio * v_cantidad;
        RETURN v_total;
    END;
    /

CREATE OR REPLACE PROCEDURE mostrar_valor_proveedor()

--necesito un cursor aqui pero no alcanzo



-----------EJERCICIO3

--Crea un trigger auditar_movimientos que se dispare después
--de insertar o eliminar un movimiento en la tabla Movimientos
--y registre el MovimientoID, ProductoID, TipoMovimiento,
--Cantidad, la acción ('INSERT' o 'DELETE') y la fecha en una
--tabla de auditoría AuditoriaMovimientos.

CREATE TABLE AuditoriaMovimientos(
    AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    MovimientoID NUMBER,
    ProductoID NUMBER,
    TipoMovimiento VARCHAR2(10),
    Cantidad NUMBER,
    Accion VARCHAR2(10),
    Fecha DATE
);

CREATE OR REPLACE TRIGGER auditar_movimientos
AFTER DELETE OR INSERT ON Movimientos
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AuditoriaMovimientos(MovimientoID, ProductoID, TipoMovimiento, Cantidad, Accion, Fecha)
        VALUES (:OLD.MovimientoID, :OLD.ProductoID, 'INSERT', :OLD.Cantidad, SYSDATE);
    ELSE
        INSERT INTO AuditoriaMovimientos(MovimientoID, ProductoID, TipoMovimiento, Cantidad, Accion, Fecha)
        VALUES (:OLD.MovimientoID, :OLD.ProductoID, 'DELTE', :OLD.Cantidad, SYSDATE);        
    END IF;
    COMMIT;
END;
/