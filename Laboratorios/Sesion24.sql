
-------------------------------EJERCICIO 1--------------------------------

--define al menos dos roles (por ejemplo, "Usuario", "Administrador").
--● Asigna permisos específicos a cada rol.
--● Crea usuarios y asigna los roles.
--● Documenta los cambios en mejoras_proyecto.sql.

CREATE ROLE admin_tienda_role;
CREATE ROLE bodeguero_role;
CREATE ROLE vendedor_role;

PROMPT Roles creados: admin_tienda_role, bodeguero_role, vendedor_role.

-- --------------------------------------------------------------------------
-- Privilegios para el Administrador de la Tienda (casi control total sobre su tienda)
-- --------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON productos TO admin_tienda_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON categorias TO admin_tienda_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON pedidos TO admin_tienda_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON detalles_pedido TO admin_tienda_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON pagos TO admin_tienda_role;
GRANT SELECT, INSERT, UPDATE ON usuarios TO admin_tienda_role; -- No puede eliminar otros usuarios, pero sí gestionarlos
GRANT SELECT, INSERT, DELETE ON usuario_roles TO admin_tienda_role; -- Puede asignar roles a sus usuarios
GRANT SELECT ON tiendas TO admin_tienda_role; -- Puede ver la info de su tienda

-- --------------------------------------------------------------------------
-- Privilegios para el Bodeguero (gestión de inventario y pedidos)
-- --------------------------------------------------------------------------
GRANT SELECT, UPDATE(stock, descripcion) ON productos TO bodeguero_role;
GRANT SELECT ON pedidos TO bodeguero_role;
GRANT SELECT ON detalles_pedido TO bodeguero_role;

-- --------------------------------------------------------------------------
-- Privilegios para el Vendedor (creación de pedidos)
-- --------------------------------------------------------------------------
GRANT SELECT ON productos TO vendedor_role;
GRANT SELECT ON categorias TO vendedor_role;
GRANT SELECT, INSERT ON pedidos TO vendedor_role;
GRANT SELECT, INSERT ON detalles_pedido TO vendedor_role;
GRANT SELECT, INSERT ON pagos TO vendedor_role;
GRANT SELECT, INSERT ON direcciones TO vendedor_role;

PROMPT Privilegios básicos asignados a los roles.

-- Creamos un contexto para almacenar de forma segura el ID de la tienda del usuario.
CREATE OR REPLACE CONTEXT contexto_tienda USING pkg_seguridad_tienda;

PROMPT Contexto 'contexto_tienda' creado.

CREATE OR REPLACE PACKAGE pkg_seguridad_tienda IS
    -- Procedimiento que se ejecuta al iniciar sesión para establecer el contexto.
    PROCEDURE sp_set_tienda_context;

    -- Función que genera la condición WHERE para las políticas de VPD.
    FUNCTION fn_politica_acceso_tienda(
        p_schema IN VARCHAR2,
        p_object IN VARCHAR2
    ) RETURN VARCHAR2;
END pkg_seguridad_tienda;
/

CREATE OR REPLACE PACKAGE BODY pkg_seguridad_tienda IS
    PROCEDURE sp_set_tienda_context IS
        v_tienda_id NUMBER;
        v_user      VARCHAR2(100) := SYS_CONTEXT('USERENV', 'SESSION_USER');
    BEGIN
        -- Buscamos la tienda a la que pertenece el usuario.
        -- Se asume que el nombre de usuario de la BD es el email en la tabla USUARIOS.
        BEGIN
            SELECT tienda_id INTO v_tienda_id
            FROM usuarios
            WHERE email = v_user;

            -- Establecemos el valor en el contexto de la sesión.
            DBMS_SESSION.SET_CONTEXT('contexto_tienda', 'tienda_id', v_tienda_id);
        EXCEPTION
            -- Si el usuario no está en la tabla (ej. SYS, SYSTEM), no se establece el contexto.
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END sp_set_tienda_context;

    FUNCTION fn_politica_acceso_tienda(
        p_schema IN VARCHAR2,
        p_object IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_tienda_id NUMBER;
    BEGIN
        -- Obtenemos el ID de la tienda desde el contexto.
        v_tienda_id := SYS_CONTEXT('contexto_tienda', 'tienda_id');

        -- Si el usuario tiene un tienda_id asociado, aplicamos el filtro.
        IF v_tienda_id IS NOT NULL THEN
            -- Retorna la cláusula WHERE que se añadirá dinámicamente.
            RETURN 'tienda_id = ' || v_tienda_id;
        ELSE
            -- Si el usuario no tiene tienda_id (es un superusuario como SYS),
            -- o es un usuario que no debe ser filtrado, no se aplica la política.
            -- Devolver '1=1' permite ver todo.
            -- Para mayor seguridad, podría ser '1=0' para no ver nada.
            RETURN '1=1';
        END IF;
    END fn_politica_acceso_tienda;
END pkg_seguridad_tienda;
/

-- Trigger que se dispara después de que un usuario inicie sesión en la BD.
CREATE OR REPLACE TRIGGER trg_set_tienda_context
AFTER LOGON ON DATABASE
BEGIN
    -- Llama al procedimiento para establecer el contexto.
    pkg_seguridad_tienda.sp_set_tienda_context;
END;
/

PROMPT Paquete de seguridad y trigger de logon creados con éxito.

-- Ahora aplicamos las políticas de VPD a las tablas principales.
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => USER,
        object_name   => 'productos',
        policy_name   => 'politica_productos_tienda',
        function_schema => USER,
        policy_function => 'pkg_seguridad_tienda.fn_politica_acceso_tienda',
        statement_types => 'SELECT, INSERT, UPDATE, DELETE',
        update_check   => TRUE
    );

    DBMS_RLS.ADD_POLICY(
        object_schema => USER,
        object_name   => 'usuarios',
        policy_name   => 'politica_usuarios_tienda',
        function_schema => USER,
        policy_function => 'pkg_seguridad_tienda.fn_politica_acceso_tienda',
        statement_types => 'SELECT, INSERT, UPDATE, DELETE',
        update_check   => TRUE
    );

    DBMS_RLS.ADD_POLICY(
        object_schema => USER,
        object_name   => 'categorias',
        policy_name   => 'politica_categorias_tienda',
        function_schema => USER,
        policy_function => 'pkg_seguridad_tienda.fn_politica_acceso_tienda',
        statement_types => 'SELECT, INSERT, UPDATE, DELETE',
        update_check   => TRUE
    );
END;
/

-------------------------------EJERCICIO 2--------------------------------

--Selecciona una consulta crítica de tu proyecto (por ejemplo, un reporte).
--● Ejecuta EXPLAIN PLAN y analiza el plan de ejecución.
--● Aplica una mejora (por ejemplo, crear un índice, reescribir la consulta).
--● Documenta los cambios y el nuevo plan de ejecución en mejoras_proyecto.sql.

CREATE INDEX idx_productos_nombre ON productos(nombre);

EXPLAIN PLAN FOR
SELECT p.nombre, SUM(dp.cantidad) AS total_unidades, SUM(dp.cantidad * dp.precio_unitario) AS total_ventas
FROM detalles_pedido dp
JOIN productos p ON dp.producto_id = p.producto_id
GROUP BY p.nombre
ORDER BY total_ventas DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
