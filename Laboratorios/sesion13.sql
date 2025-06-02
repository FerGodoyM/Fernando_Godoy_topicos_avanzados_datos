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
