
-- Transacciones y DataWarehouse

-- Las Transacciones son conjunto de operaciones DML que respetan las propiedad ACID
-- EL DataWarehousees una base de datos optimizada para análisis y reportes, que
-- almacena datos históricos de múltiples fuentes.

------------------------------EJEMPLOS---------------------------------

-- Procedimiento que inserta un pedido y sus detalles, usando savepoints para manejar
-- errores parciales.

CREATE OR REPLACE PROCEDURE insertar_pedido_completo(
    p_pedido_id IN NUMBER,
    p_cliente_id IN NUMBER,
    p_detalle_id1 IN NUMBER,
    p_producto_id1 IN NUMBER,
    p_cantidad1 IN NUMBER,
    p_detalle_id2 IN NUMBER,
    p_producto_id2 IN NUMBER,
    p_cantidad2 IN NUMBER) AS
    
    BEGIN
    -- Iniciar transacción
        INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
        VALUES (p_pedido_id, p_cliente_id, 0, SYSDATE);
        DBMS_OUTPUT.PUT_LINE('Pedido ' || p_pedido_id || ' insertado.');

        -- Primer savepoint después de insertar el pedido
        SAVEPOINT pedido_insertado;

        -- Insertar primer detalle
        INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
        VALUES (p_detalle_id1, p_pedido_id, p_producto_id1, p_cantidad1);
        DBMS_OUTPUT.PUT_LINE('Primer detalle insertado.');

        -- Segundo savepoint después del primer detalle
        SAVEPOINT detalle1_insertado;

        -- Insertar segundo detalle (puede fallar si el DetalleID ya existe)
        INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
        VALUES (p_detalle_id2, p_pedido_id, p_producto_id2, p_cantidad2);
        DBMS_OUTPUT.PUT_LINE('Segundo detalle insertado.');

        -- Calcular y actualizar el total del pedido
        UPDATE Pedidos SET Total = (SELECT SUM(p.Precio * d.Cantidad)
        FROM DetallesPedidos d 
        JOIN Productos p 
        ON d.ProductoID = p.ProductoID
        WHERE d.PedidoID = p_pedido_id)
        WHERE PedidoID = p_pedido_id;

        -- Confirmar toda la transacción
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Transacción completada y confirmada.');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Error: DetalleID duplicado.');
            ROLLBACK TO detalle1_insertado;
            DBMS_OUTPUT.PUT_LINE('Rollback al primer detalle.
            Segundo detalle no insertado.');
        COMMIT; -- Confirmar lo que se hizo hasta el primer detalle
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ROLLBACK TO pedido_insertado;
            DBMS_OUTPUT.PUT_LINE('Rollback al pedido. Detalles no
            insertados.');
        COMMIT; -- Confirmar solo el pedido
    END;
    /

-- Ejecutar
EXEC insertar_pedido_completo(107, 3, 5, 1, 1, 5, 2, 2);
EXEC insertar_pedido_completo(108, 3, 6, 1, 1, 7, 2, 2);

-- Explicacion: Inserta un pedido y dos detalles, 
-- usando savepoints para manejar errores.
-- Si el segundo detalle falla (por ejemplo,
-- DetalleID duplicado), revierte al savepoint
-- detalle1_insertado y confirma el pedido y el
-- primer detalle.Si ocurre otro error, 
-- revierte al savepoint pedido_insertado
-- y confirma solo el pedido.


------------------------------EJERCICIOS-------------------------------
--Crea un procedimiento actualizar_inventario_pedido que reciba un
--PedidoID (parámetro IN) y reduzca la cantidad de
--productos en una tabla Inventario (crea la tabla si no existe)
--según los detalles del pedido. Usa savepoints para manejar errores
--si no hay suficiente inventario.



-- no se si esta bueno, talvez deberia hacer un cursor para recorrer los detalles del pedido
CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(p_pedido_id INT) IS

    v_cantidad DetallesPedidos.Cantidad%TYPE;
    v_productoID DetallesPedidos.ProductoID%TYPE;
    v_cantidad_inventario Inventario.CantidadProductos%TYPE;

    CURSOR c_detalles IS
        SELECT ProductoID, Cantidad FROM DetallesPedidos WHERE PedidoID = p_pedido_id;
BEGIN
    OPEN c_detalles;
    LOOP
        FETCH c_detalles INTO v_productoID, v_cantidad;
        EXIT WHEN c_detalles%NOTFOUND;

        SAVEPOINT antes_producto;

        SELECT CantidadProductos INTO v_cantidad_inventario FROM Inventario WHERE ProductoID = v_productoID;
            IF v_cantidad_inventario < v_cantidad THEN
                ROLLBACK TO antes_producto;
                RAISE_APPLICATION_ERROR(-20001, 'No hay suficiente inventario para el producto ID: ' || v_productoID);
            ELSE
                UPDATE Inventario
                SET CantidadProductos = CantidadProductos - v_cantidad
                WHERE ProductoID = v_productoID;
            END IF;
            
    END LOOP;
    CLOSE c_detalles;
    COMMIT;
END;
/


--Diseña una tabla de hechos Fact_Pedidos y una dimensión Dim_Ciudad para un Data Warehouse
--basado en curso_topicos. Escribe una consulta analítica que muestre el total de ventas por
--ciudad y año.

CREATE TABLE Dim_Ciudad (
    CiudadID NUMBER PRIMARY KEY,
    NombreCiudad VARCHAR2(50) NOT NULL UNIQUE
);

CREATE TABLE Fact_Pedidos (
    PedidoID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    CiudadID NUMBER,
    FechaID NUMBER,
    TotalPedido NUMBER,
    CantidadTotalItems NUMBER,
    CONSTRAINT fk_fact_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
    CONSTRAINT fk_fact_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
    CONSTRAINT fk_fact_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);


SELECT Dim_Cliente.Ciudad AS Ciudad, Dim_Tiempo.Año AS Año, SUM(Hecho_Ventas.Total) AS Total_Ventas FROM Hecho_Ventas
INNER JOIN Dim_Cliente 
ON Hecho_Ventas.ClienteID = Dim_Cliente.ClienteID
INNER JOIN Dim_Tiempo 
ON Hecho_Ventas.FechaID = Dim_Tiempo.FechaID
GROUP BY Dim_Cliente.Ciudad, Dim_Tiempo.Año
ORDER BY Dim_Cliente.Ciudad, Dim_Tiempo.Año;
