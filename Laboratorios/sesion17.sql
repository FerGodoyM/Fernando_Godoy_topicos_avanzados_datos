
------------------------EJERCICIO 1------------------------

--Crea un usuario user_analista y un rol
--rol_analista. El rol debe tener permisos para
--consultar (SELECT) todas las tablas de
--curso_topicos y para insertar (INSERT) en la tabla
--Pedidos. Asigna el rol al usuario y prueba los permisos.

--Se crea el usuario "user_analista" con contraseña "analista123"
--Y se le da permisos para iniciar sesion con GRANT CONNECT

CREATE USER user_analista IDENTIFIED BY analista123;
GRANT CONNECT TO user_analista;


--Se crea el rol analista y todo lo que puede hacer
CREATE ROLE rol_analista;

GRANT SELECT ON Clientes TO rol_analista;
GRANT SELECT, INSERT ON Pedidos TO rol_analista;
GRANT SELECT ON DetallesPedidos TO rol_analista;
GRANT SELECT ON Productos TO rol_analista;
GRANT SELECT ON Inventario TO rol_analista;


--Se asigna el rol analista al usuario
GRANT rol_analista TO user_analista;

--para probarlo en el bash "sqlplus user_analista/analista123@//localhost:1521/XEPDB1"
--o CONNECT user_analista/analista123;

--recuerda:
--CONNECT SYS AS SYSDBA;
--pass: oracle
--ALTER SESSION SET CONTAINER = XEPDB1;
--SELECT * FROM curso_topicos.Inventario;


----------------EJERCICIO 2-------------------------
--Configura auditoría para monitorear las acciones de
--user_analista al consultar la tabla Clientes y al
--insertar en la tabla Pedidos. Realiza algunas
--acciones y verifica los registros de auditoría.


-- Conectar como SYSDBA para activar auditoría y configurarla
CONNECT sys AS sysdba;
ALTER SYSTEM SET audit_trail=DB SCOPE=SPFILE;
-- Reiniciar la base para aplicar cambios

--crear las auditorías
AUDIT SELECT ON curso_topicos.Clientes BY user_analista;
AUDIT SELECT ON curso_topicos.Pedidos BY user_analista;
AUDIT INSERT ON curso_topicos.Pedidos BY user_analista;
AUDIT SELECT ON curso_topicos.DetallesPedidos BY user_analista;
AUDIT SELECT ON curso_topicos.Productos BY user_analista;
AUDIT SELECT ON curso_topicos.Inventario BY user_analista;

--Consultar auditoría
SELECT username, action_name, timestamp
FROM dba_audit_trail
WHERE username IN ('USER_ANALISTA');