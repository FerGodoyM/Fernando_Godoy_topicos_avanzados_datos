--ejercicio uno

-- Escribe un bloque anónimo que use un cursor
--explícito basado en un objeto para listar 2
--atributos de alguna clase, ordenados por uno de
--los atributos.


CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
  cliente_id NUMBER,
  nombre     VARCHAR2(50),
  ciudad     VARCHAR2(50),
  MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_obj AS
  MEMBER FUNCTION get_info RETURN VARCHAR2 IS
  BEGIN
    RETURN 'ID: ' || cliente_id || ', Nombre: ' || nombre || ', Ciudad: ' || ciudad;
  END;
END;
/

CREATE TABLE clientes_tab OF cliente_obj;

INSERT INTO clientes_tab VALUES (cliente_obj(1, 'Ana', 'Valparaíso'));
INSERT INTO clientes_tab VALUES (cliente_obj(2, 'Luis', 'Santiago'));
INSERT INTO clientes_tab VALUES (cliente_obj(3, 'Benjamin', 'Calama'));
INSERT INTO clientes_tab VALUES (cliente_obj(4, 'Carlos', 'La Serena'));

COMMIT;

DECLARE
  CURSOR c_clientes IS
    SELECT c.nombre, c.ciudad
    FROM clientes_tab c
    ORDER BY c.nombre;

  v_nombre clientes_tab.nombre%TYPE;
  v_ciudad clientes_tab.ciudad%TYPE;
BEGIN
  OPEN c_clientes;
  LOOP
    FETCH c_clientes INTO v_nombre, v_ciudad;
    EXIT WHEN c_clientes%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre || ', Ciudad: ' || v_ciudad);
  END LOOP;
  CLOSE c_clientes;
END;
/





--ejecicio dos

--Escribe un bloque anónimo que use un cursor
--explícito con parámetro basado en un objeto para
--aumentar un 10% el total de la suma de algún
--atributo numérico de un elemento de una tabla y
--muestre los valores originales y actualizados.
--Usa FOR UPDATE o usa función dentro del objeto

CREATE OR REPLACE TYPE producto_obj AS OBJECT (
  producto_id NUMBER,
  nombre      VARCHAR2(50),
  precio      NUMBER,
  MEMBER FUNCTION info RETURN VARCHAR2
);
/ 

CREATE OR REPLACE TYPE BODY producto_obj AS
  MEMBER FUNCTION info RETURN VARCHAR2 IS
  BEGIN
    RETURN 'ID: ' || producto_id || ', Nombre: ' || nombre || ', Precio: ' || precio;
  END;
END;
/

CREATE TABLE productos_tab OF producto_obj;

INSERT INTO productos_tab VALUES (producto_obj(1, 'Monitor', 150.00));
INSERT INTO productos_tab VALUES (producto_obj(2, 'Teclado', 25.00));
INSERT INTO productos_tab VALUES (producto_obj(3, 'Mouse', 15.00));
COMMIT;

DECLARE
  CURSOR c_productos(p_id NUMBER) IS
    SELECT VALUE(p)
    FROM productos_tab p
    WHERE p.producto_id = p_id
    FOR UPDATE;

  v_producto producto_obj;
  v_precio_original NUMBER;
  v_precio_actualizado NUMBER;
BEGIN
  OPEN c_productos(2);
  FETCH c_productos INTO v_producto;

  IF c_productos%FOUND THEN
    v_precio_original := v_producto.precio;
    v_precio_actualizado := v_precio_original * 1.10;

    UPDATE productos_tab p
    SET p.precio = v_precio_actualizado
    WHERE p.producto_id = v_producto.producto_id;

    DBMS_OUTPUT.PUT_LINE('Producto: ' || v_producto.nombre);
    DBMS_OUTPUT.PUT_LINE('Precio original: ' || v_precio_original);
    DBMS_OUTPUT.PUT_LINE('Precio actualizado: ' || v_precio_actualizado);
  ELSE
    DBMS_OUTPUT.PUT_LINE('No se encontró el producto con ese ID.');
  END IF;

  CLOSE c_productos;
END;
/

