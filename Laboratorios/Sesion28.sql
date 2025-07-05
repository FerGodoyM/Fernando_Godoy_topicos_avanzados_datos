----------------------------Ejercicio 1----------------------------

--Define qué es una transacción en una base de datos y explica
--cómo las propiedades ACID garantizan su integridad.
--Proporciona un ejemplo de un procedimiento que registre un
--pedido en la tabla Pedidos, usando savepoints para revertir
--la operación si el cliente no existe.

CREATE OR REPLACE PROCEDURE registrar_pedido (
    p_cliente_id IN NUMBER,
    p_total IN NUMBER,
    p_fecha_pedido IN DATE
) AS
    v_cliente_existe NUMBER;
BEGIN
    SAVEPOINT inicio_pedido;
    -- Validar que el cliente existe
    SELECT COUNT(*) INTO v_cliente_existe
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    IF v_cliente_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cliente no existe.');
    END IF;
 -- Insertar pedido
    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
    VALUES ((SELECT NVL(MAX(PedidoID), 0) + 1 FROM Pedidos), p_cliente_id, p_total, p_fecha_pedido);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK TO inicio_pedido;
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM || '.Operación revertida.');
    ROLLBACK;
END;
/

--Una transacción en una base de datos es un conjunto de operaciones que se ejecutan como una sola unidad.
--Debe completarse por completo o no hacerse nada.
--Las propiedades ACID garantizan su integridad:

--Atomicidad: todo o nada.
--Consistencia: mantiene las reglas de la base de datos.
--Aislamiento: no se afecta con otras transacciones al mismo tiempo.
--Durabilidad: los cambios se guardan incluso si el sistema falla.

--Estas propiedades aseguran que los datos siempre sean correctos y confiables.


----------------------------Ejercicio 2----------------------------

--¿Qué es un Data Warehouse y cómo se diferencia de una base
--de datos operativa en términos de propósito y estructura?
--Diseña una tabla de hechos Fact_Inventario para analizar el
--movimiento de productos (entradas y salidas) en la base de
--datos, incluyendo claves foráneas y medidas adecuadas.

CREATE TABLE Fact_Inventario (
    FactID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProductoID NUMBER,
    FechaID NUMBER,
    CantidadMovimiento NUMBER,
    TipoMovimiento VARCHAR2(10),
    CONSTRAINT fk_fact_inventario_producto FOREIGN KEY
    (ProductoID) REFERENCES Dim_Producto(ProductoID),
    CONSTRAINT fk_fact_inventario_tiempo FOREIGN KEY
    (FechaID) REFERENCES Dim_Tiempo(FechaID)
);


--Un Data Warehouse es un sistema de almacenamiento de datos orientado al análisis y la toma de decisiones.
--Reúne información histórica desde múltiples fuentes y la organiza para facilitar consultas complejas y reportes.
--A diferencia de una base de datos operativa, que se usa para gestionar las transacciones del día a día
--(como ventas, registros o actualizaciones en tiempo real), el Data Warehouse se centra en 
--analizar grandes volúmenes de datos a lo largo del tiempo. 
--También se diferencian en estructura: las bases de datos operativas usan modelos relacionales normales, 
--mientras que los Data Warehouses suelen usar modelos dimensionales (como tablas de hechos y dimensiones) 
--para facilitar el análisis.


----------------------------Ejercicio 3----------------------------

--Explica cómo se implementa la herencia en Oracle utilizando
--tipos de objetos y la cláusula UNDER. Diseña una jerarquía
--de tipos para modelar clientes (Cliente → ClientePremium) y
--crea un índice en la tabla Clientes para optimizar consultas
--por Ciudad. Justifica tu elección.

CREATE TYPE Tipo_Cliente AS OBJECT (
    ClienteID NUMBER,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    MEMBER FUNCTION getDescuento RETURN NUMBER
) NOT FINAL;
/

CREATE TYPE BODY Tipo_Cliente AS
    MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN RETURN 0; END;
END;
/

CREATE TYPE Tipo_ClientePremium UNDER Tipo_Cliente (
    DescuentoAdicional NUMBER,
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER
);
/

CREATE TYPE BODY Tipo_ClientePremium AS
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN RETURN DescuentoAdicional; END;
END;
/

CREATE TABLE Clientes OF Tipo_Cliente;
CREATE INDEX idx_clientes_ciudad ON Clientes (Ciudad);

--En Oracle, la herencia se implementa usando tipos de objetos junto con la cláusula UNDER. Esto permite crear un tipo que hereda atributos y
--métodos de otro tipo base, de forma similar a la herencia en programación orientada a objetos.
--Primero se define un tipo base con ciertos atributos. Luego, se crea un subtipo que extiende ese tipo base usando la cláusula UNDER,
--y se le pueden agregar nuevos atributos o métodos. Esta característica permite modelar jerarquías y reutilizar estructuras de datos, 
--facilitando la organización y el mantenimiento del sistema.


----------------------------Ejercicio 4----------------------------

--Explica cómo se implementa la herencia en Oracle utilizando
--tipos de objetos y la cláusula UNDER. Diseña una jerarquía
--de tipos para modelar clientes (Cliente → ClientePremium) y
--crea un índice en la tabla Clientes para optimizar consultas
--por Ciudad. Justifica tu elección.

ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_q1_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_q2_2025 VALUES LESS THAN (TO_DATE('2025-07-01', 'YYYY-MM-DD')),
    PARTITION p_q3_2025 VALUES LESS THAN (TO_DATE('2025-10-01', 'YYYY-MM-DD')),
    PARTITION p_q4_2025 VALUES LESS THAN (MAXVALUE)
);

CREATE INDEX idx_pedidos_cliente_total ON Pedidos(ClienteID, Total);


----------------------------Ejercicio 5----------------------------

--Crea un índice compuesto en DetallesPedidos para PedidoID y
--ProductoID. Particiona Pedidos por rango de FechaPedido
--(mensual para 2025). Escribe una consulta que sume Total por
--ClienteID en enero de 2025.

-- Índice compuesto
CREATE INDEX idx_detalles_pedido_prod ON DetallesPedidos (PedidoID, ProductoID);
-- Partición por rango mensual
ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_jan_2025 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_feb_2025 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION p_mar_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);
-- Consulta
SELECT ClienteID, SUM(Total) AS Total_Mensual FROM Pedidos
WHERE FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-01-31', 'YYYY-MM-DD')
GROUP BY ClienteID;