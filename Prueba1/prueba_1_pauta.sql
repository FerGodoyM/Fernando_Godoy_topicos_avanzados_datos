/*
***PARTE 1***

*/

/*

Pregunta 1: Relación Muchos a Muchos y su Implementación (10 puntos)

Enunciado: Explica qué es una relación muchos a muchos y cómo se implementa en una base de datos relacional. Usa un ejemplo basado en las tablas del esquema creado para la prueba.

Respuesta Correcta:

    Una relación muchos a muchos en una base de datos relacional ocurre cuando múltiples registros de una tabla A pueden relacionarse con múltiples registros de una tabla B, y viceversa. Esto significa que cada registro de A puede estar asociado con varios registros de B, y cada registro de B puede estar asociado con varios registros de A.
    Para implementar una relación muchos a muchos, se utiliza una tabla intermedia que contiene las claves primarias de ambas tablas como claves foráneas, permitiendo conectar los registros de ambas tablas. Esta tabla intermedia puede incluir columnas adicionales para describir la relación.
    En el esquema de la prueba, un ejemplo de relación muchos a muchos es entre las tablas Empleados y Proyectos. Un empleado puede trabajar en varios proyectos, y un proyecto puede tener varios empleados asignados. Esto se implementa mediante la tabla intermedia Asignaciones, que tiene las columnas EmpleadoID (clave foránea que referencia a Empleados) y ProyectoID (clave foránea que referencia a Proyectos). Además, Asignaciones incluye la columna Horas para registrar las horas asignadas a cada empleado en cada proyecto.

Criterios de Evaluación (10 puntos):

    Definición Correcta (3 puntos): Explicar que una relación muchos a muchos implica que múltiples registros de una tabla se relacionan con múltiples registros de otra.
    Explicación de la Implementación (3 puntos): Mencionar que se usa una tabla intermedia con claves foráneas de ambas tablas.
    Ejemplo Correcto (3 puntos): Identificar la relación entre Empleados y Proyectos a través de Asignaciones, con detalles específicos (columnas EmpleadoID y ProyectoID).
    Precisión y Claridad (1 punto): Redacción técnica y clara.

Pregunta 2: Vistas y Consulta para Total de Horas por Proyecto (10 puntos)

Enunciado: Describe qué es una vista y cómo la usarías para mostrar el total de horas asignadas por proyecto, incluyendo el nombre del proyecto. Escribe la consulta SQL para crear la vista (no es necesario ejecutarla).

Respuesta Correcta:

    Una vista en una base de datos es una tabla virtual creada a partir de una consulta SQL, que no almacena datos físicamente, sino que muestra los resultados de las tablas subyacentes en tiempo real. Las vistas se utilizan para simplificar consultas complejas, mejorar la seguridad al restringir el acceso a ciertas columnas o filas, y presentar datos de manera organizada.
    Para mostrar el total de horas asignadas por proyecto, incluyendo el nombre del proyecto, usaría una vista para encapsular una consulta que calcule la suma de horas por proyecto. Esto permite consultar los datos fácilmente con una instrucción simple como SELECT * FROM vista_total_horas;, sin necesidad de repetir la consulta compleja.

    Consulta SQL para crear la vista:

    CREATE OR REPLACE VIEW vista_total_horas AS
    SELECT p.Nombre, SUM(a.Horas) AS TotalHoras
    FROM Proyectos p
    JOIN Asignaciones a ON p.ProyectoID = a.ProyectoID
    GROUP BY p.Nombre;

Criterios de Evaluación (10 puntos):

    Definición Correcta (3 puntos): Explicar que una vista es una tabla virtual basada en una consulta, que no almacena datos físicamente.
    Uso Adecuado (2 puntos): Describir cómo se usaría para mostrar el total de horas por proyecto (por ejemplo, con una consulta simple).
    Consulta SQL Correcta (4 puntos):
        Usar CREATE OR REPLACE VIEW (1 punto).
        Incluir un JOIN entre Proyectos y Asignaciones con la condición correcta (1 punto).
        Usar SUM(a.Horas) y GROUP BY p.Nombre para calcular el total (2 puntos).
    Precisión y Claridad (1 punto): Redacción clara y consulta sin errores.

Pregunta 3: Excepciones Predefinidas en PL/SQL y Ejemplo con NO_DATA_FOUND (10 puntos)

Enunciado: ¿Qué es una excepción predefinida en PL/SQL y cómo se maneja? Da un ejemplo de cómo manejarías la excepción NO_DATA_FOUND en un bloque PL/SQL.

Respuesta Correcta:

    Una excepción predefinida en PL/SQL es un error identificado y nombrado por Oracle que se lanza automáticamente cuando ocurre una condición específica durante la ejecución del código. Estas excepciones se manejan en un bloque EXCEPTION dentro de un bloque PL/SQL, permitiendo al programador controlar el flujo del programa y evitar que el código falle abruptamente.
    La excepción NO_DATA_FOUND se lanza cuando una consulta SELECT INTO no devuelve ninguna fila. Para manejarla, se usa un bloque EXCEPTION con WHEN NO_DATA_FOUND para capturar el error y ejecutar una acción alternativa, como mostrar un mensaje al usuario.

    Ejemplo de manejo de NO_DATA_FOUND:

    DECLARE
        v_nombre Proyectos.Nombre%TYPE;
    BEGIN
        SELECT Nombre INTO v_nombre
        FROM Proyectos
        WHERE ProyectoID = 999; -- ID que no existe
        DBMS_OUTPUT.PUT_LINE('Proyecto encontrado: ' || v_nombre);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontraron datos para el proyecto especificado.');
    END;
    /

Criterios de Evaluación (10 puntos):

    Definición Correcta (3 puntos): Explicar que una excepción predefinida es un error identificado por Oracle y que se maneja en un bloque EXCEPTION.
    Uso de NO_DATA_FOUND (2 puntos): Describir que NO_DATA_FOUND se lanza cuando un SELECT INTO no devuelve datos.
    Ejemplo Correcto (4 puntos):
        Incluir un bloque PL/SQL completo (DECLARE, BEGIN, EXCEPTION, END) (2 puntos).
        Usar WHEN NO_DATA_FOUND para manejar la excepción (1 punto).
        Mostrar una acción adecuada, como un mensaje (1 punto).
    Precisión y Claridad (1 punto): Redacción clara y ejemplo funcional.

Pregunta 4: Cursor Explícito y Atributos (10 puntos)

Enunciado: Explica qué es un cursor explícito y cómo se usa en PL/SQL. Menciona al menos dos atributos de cursor (como %NOTFOUND) y su propósito.

Respuesta Correcta:

    Un cursor explícito en PL/SQL es un mecanismo que permite declarar una consulta SQL y procesar sus resultados fila por fila, controlando manualmente las operaciones de apertura, recorrido y cierre. Se usa cuando se necesita manejar múltiples filas de una consulta de manera programática, como en un bucle.
    Para usar un cursor explícito, se siguen estos pasos:

        Declarar el cursor: CURSOR nombre IS SELECT ...;
        Abrir el cursor: OPEN nombre;
        Recorrer las filas: Usar FETCH para recuperar datos y un bucle con %NOTFOUND para salir cuando no hay más filas.
        Cerrar el cursor: CLOSE nombre;

    Dos atributos de cursor y su propósito:

        %NOTFOUND: Devuelve TRUE si la última operación FETCH no recuperó ninguna fila, lo que indica que se han procesado todas las filas. Se usa para salir de un bucle.
        %ROWCOUNT: Devuelve el número de filas recuperadas hasta el momento por el cursor, útil para contar cuántas filas se han procesado.


Criterios de Evaluación (10 puntos):

    Definición Correcta (3 puntos): Explicar que un cursor explícito permite procesar filas de una consulta manualmente.
    Uso del Cursor (3 puntos): Describir los pasos: declarar, abrir, recorrer (FETCH con %NOTFOUND), cerrar.
    Atributos Correctos (3 puntos): Mencionar dos atributos como %NOTFOUND y %ROWCOUNT, con su propósito (1.5 puntos cada uno).
    Precisión y Claridad (1 punto): Redacción técnica y clara.

*/

/*
***PARTE 2***
*/

/*
Ejercicio 1: Cursor Explícito para Listar Departamentos con Salario Promedio Mayor a 600,000 (20 puntos)

Enunciado: Escribe un bloque PL/SQL con un cursor explícito que liste los departamentos con un salario promedio mayor a 600,000, mostrando el nombre del departamento y el promedio de salario de sus empleados. Usa un JOIN entre Departamentos y Empleados.
*/

DECLARE
    CURSOR c_dept_sueldo IS
        SELECT d.Nombre, AVG(e.Salario) AS promedio_sueldo
        FROM Departamentos d
        JOIN Empleados e ON d.DepartamentoID = e.DepartamentoID
        GROUP BY d.Nombre
        HAVING AVG(e.Salario) > 600000;
    v_nombre Departamentos.Nombre%TYPE;
    v_promedio NUMBER;
BEGIN
    OPEN c_dept_sueldo;
    LOOP
        FETCH c_dept_sueldo INTO v_nombre, v_promedio;
        EXIT WHEN c_dept_sueldo%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Departamento: ' || v_nombre || ' - Promedio Sueldo: ' || v_promedio);
    END LOOP;
    CLOSE c_dept_sueldo;
END;
/

/*
Explicación:

    Declara un cursor explícito que calcula el promedio de salario por departamento, filtrando aquellos con promedio mayor a 600,000.
    Usa un JOIN entre Departamentos y Empleados.
    Procesa las filas manualmente con OPEN, FETCH, EXIT WHEN %NOTFOUND, y CLOSE.
    Muestra el nombre del departamento y el promedio de salario.

Criterios de Evaluación (20 puntos):

    Definición del Cursor (5 puntos): Consulta correcta con JOIN, GROUP BY, y HAVING (2 puntos); seleccionar solo las columnas necesarias (Nombre y promedio) (3 puntos).
    Uso del Cursor Explícito (5 puntos): Manejo manual con OPEN, FETCH, EXIT WHEN %NOTFOUND, CLOSE (5 puntos). Nota: El uso de FOR ... LOOP es válido, pero se esperaba manejo manual (puede restar 1-2 puntos si se usa FOR ... LOOP).
    Salida Correcta (5 puntos): Mostrar el nombre del departamento y el promedio (5 puntos).
    Estructura y Funcionalidad (5 puntos): Código bien estructurado y funcional (5 puntos).
*/

/*
Ejercicio 2: Cursor Explícito con FOR UPDATE para Reducir Presupuesto (20 puntos)

Enunciado: Escribe un bloque PL/SQL con un cursor explícito que reduzca un 5% el presupuesto de los proyectos que tienen un presupuesto mayor a 1,500,000. Usa FOR UPDATE y maneja excepciones.
*/

DECLARE
    CURSOR c_reduccion IS
        SELECT ProyectoID, Presupuesto
        FROM Proyectos
        WHERE Presupuesto > 1500000
        FOR UPDATE;
    v_proyecto_id Proyectos.ProyectoID%TYPE;
    v_presupuesto Proyectos.Presupuesto%TYPE;
BEGIN
    OPEN c_reduccion;
    LOOP
        FETCH c_reduccion INTO v_proyecto_id, v_presupuesto;
        EXIT WHEN c_reduccion%NOTFOUND;
        UPDATE Proyectos
        SET Presupuesto = v_presupuesto * 0.95
        WHERE CURRENT OF c_reduccion;
        DBMS_OUTPUT.PUT_LINE('Proyecto ID: ' || v_proyecto_id || ' actualizado a: ' || (v_presupuesto * 0.95));
    END LOOP;
    CLOSE c_reduccion;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

/*
Explicación:

    Declara un cursor explícito que selecciona proyectos con presupuesto mayor a 1,500,000, usando FOR UPDATE.
    Procesa las filas manualmente y actualiza el presupuesto con una reducción del 5% (v_presupuesto * 0.95).
    Maneja excepciones con WHEN OTHERS y revierte los cambios con ROLLBACK en caso de error.

Criterios de Evaluación (20 puntos):

    Definición del Cursor (5 puntos): Consulta correcta con WHERE Presupuesto > 1500000 y FOR UPDATE (5 puntos).
    Uso del Cursor Explícito (5 puntos): Manejo manual con OPEN, FETCH, EXIT WHEN %NOTFOUND, CLOSE (5 puntos).
    Actualización Correcta (5 puntos): Reducción del 5% usando WHERE CURRENT OF (5 puntos).
    Manejo de Excepciones (3 puntos): Usar WHEN OTHERS y mostrar el error (2 puntos); incluir ROLLBACK (1 punto, aunque no es obligatorio).
    Estructura y Funcionalidad (2 puntos): Código funcional y bien estructurado (2 puntos).

*/

/*
Ejercicio 3: Tipo de Objeto, Tabla de Objetos, y Cursor Explícito (20 puntos)

Enunciado: Crea un tipo de objeto empleado_obj con atributos empleado_id, nombre, y un método get_info. Luego, crea una tabla basada en ese tipo y transfiere los datos de Empleados a esa tabla. Finalmente, escribe un cursor explícito que liste la información de los empleados usando el método get_info.
*/

-- Crear el tipo de objeto
CREATE OR REPLACE TYPE empleado_obj AS OBJECT (
    empleado_id NUMBER,
    nombre VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

-- Crear el cuerpo del tipo
CREATE OR REPLACE TYPE BODY empleado_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || empleado_id || ', Nombre: ' || nombre;
    END;
END;
/

-- Crear la tabla basada en el tipo
CREATE TABLE empleado_obj_tab OF empleado_obj (
    empleado_id PRIMARY KEY
);

-- Transferir los datos de Empleados
INSERT INTO empleado_obj_tab (empleado_id, nombre)
SELECT EmpleadoID, Nombre
FROM Empleados;
COMMIT;

-- Listar los datos con un cursor explícito
DECLARE
    CURSOR c_empleados IS
        SELECT VALUE(e) FROM empleado_obj_tab e;
    v_empleado empleado_obj;
BEGIN
    OPEN c_empleados;
    LOOP
        FETCH c_empleados INTO v_empleado;
        EXIT WHEN c_empleados%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_empleado.get_info());
    END LOOP;
    CLOSE c_empleados;
END;
/

/*
Explicación:

    Crea un tipo de objeto empleado_obj con los atributos y el método get_info.
    Crea una tabla empleado_obj_tab basada en el tipo, con una clave primaria.
    Transfiere los datos de Empleados a la tabla usando INSERT.
    Usa un cursor explícito para listar los datos, invocando el método get_info.

Criterios de Evaluación (20 puntos):

    Creación del Tipo (5 puntos): Sintaxis correcta con AS OBJECT y definición del método (3 puntos); implementación correcta del método get_info (2 puntos).
    Creación de la Tabla (3 puntos): Usar OF empleado_obj con clave primaria (3 puntos).
    Transferencia de Datos (4 puntos): Usar INSERT para transferir los datos de Empleados (4 puntos).
    Uso del Cursor Explícito (5 puntos): Manejo manual con SELECT VALUE(e), FETCH, EXIT WHEN %NOTFOUND, y uso de get_info (5 puntos).
    Estructura y Funcionalidad (3 puntos): Código funcional y bien estructurado (3 puntos).
*/