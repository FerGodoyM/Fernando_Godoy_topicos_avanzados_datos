-- Script para crear y poblar la base de datos para la Prueba 2
-- Ejecutar en Oracle SQL Developer en el esquema del estudiante

-- Habilitar salida de mensajes para PL/SQL
SET SERVEROUTPUT ON;

-- Eliminar tablas si ya existen (para evitar errores si el script se ejecuta más de una vez)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Movimientos CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Inventario CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Productos CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Proveedores CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Crear tabla Proveedores
CREATE TABLE Proveedores (
    ProveedorID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50)
);

-- Crear tabla Productos
CREATE TABLE Productos (
    ProductoID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Precio NUMBER,
    ProveedorID NUMBER,
    CONSTRAINT fk_producto_proveedor FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID)
);

-- Crear tabla Inventario
CREATE TABLE Inventario (
    InventarioID NUMBER PRIMARY KEY,
    ProductoID NUMBER,
    Cantidad NUMBER,
    FechaActualizacion DATE,
    CONSTRAINT fk_inventario_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- Crear tabla Movimientos
CREATE TABLE Movimientos (
    MovimientoID NUMBER PRIMARY KEY,
    ProductoID NUMBER,
    TipoMovimiento VARCHAR2(10), -- 'Entrada' o 'Salida'
    Cantidad NUMBER,
    FechaMovimiento DATE,
    CONSTRAINT fk_movimiento_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- Insertar datos en Proveedores
INSERT INTO Proveedores VALUES (1, 'TechCorp', 'Santiago');
INSERT INTO Proveedores VALUES (2, 'GlobalSupply', 'Valparaíso');
INSERT INTO Proveedores VALUES (3, 'InnovaTech', 'Concepción');

-- Insertar datos en Productos
INSERT INTO Productos VALUES (101, 'Monitor', 150000, 1);
INSERT INTO Productos VALUES (102, 'Teclado', 30000, 1);
INSERT INTO Productos VALUES (103, 'Impresora', 200000, 2);
INSERT INTO Productos VALUES (104, 'Router', 80000, 3);

-- Insertar datos en Inventario
INSERT INTO Inventario VALUES (1, 101, 50, TO_DATE('2025-05-01', 'YYYY-MM-DD'));
INSERT INTO Inventario VALUES (2, 102, 100, TO_DATE('2025-05-01', 'YYYY-MM-DD'));
INSERT INTO Inventario VALUES (3, 103, 30, TO_DATE('2025-05-01', 'YYYY-MM-DD'));
INSERT INTO Inventario VALUES (4, 104, 20, TO_DATE('2025-05-01', 'YYYY-MM-DD'));

-- Insertar datos en Movimientos
INSERT INTO Movimientos VALUES (1, 101, 'Entrada', 10, TO_DATE('2025-05-02', 'YYYY-MM-DD'));
INSERT INTO Movimientos VALUES (2, 101, 'Salida', 5, TO_DATE('2025-05-03', 'YYYY-MM-DD'));
INSERT INTO Movimientos VALUES (3, 102, 'Entrada', 20, TO_DATE('2025-05-02', 'YYYY-MM-DD'));
INSERT INTO Movimientos VALUES (4, 103, 'Salida', 10, TO_DATE('2025-05-03', 'YYYY-MM-DD'));

-- Confirmar creación e inserción de datos
SELECT 'Tablas creadas y datos insertados correctamente.' AS mensaje FROM dual;

-- Verificar datos
SELECT * FROM Proveedores;
SELECT * FROM Productos;
SELECT * FROM Inventario;
SELECT * FROM Movimientos;

-- Commit para asegurar los cambios
COMMIT;