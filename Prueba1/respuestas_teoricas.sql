-- 1) Explica qué es una relación muchos a muchos y cómo se
-- implementa en una base de datos relacional. Usa un ejemplo
-- basado en las tablas del esquema creado para la prueba.

-- R: Una relación mucho a muchos significa que X tabla puede contener muchos
--Datos asociados a una primarykey de Y tabla y viceversa.
--Un ejemplo de esto en una aplicacion de colectivos. un colectivo puede llevar a muchas personas
--y una persona se puede subir a muchos colectivos.



--2) Describe que es una vista y cómo la usarías para mostrar el
--total de horas asignadas por proyecto, incluyendo el nombre
--del proyecto. Escribe la consulta SQL para crear la vista
--(no es necesario ejecutarla).

-- Una vista es una sentencia SQL que actua como si fuera una tabla
-- Esto nos ayuda a minimizar codigo y hacerlo más legible.

--CREATE VIEW TotalHoras AS
--SELECT p.Nombre, SUM(a.Horas) AS HorasTotales
--FROM Proyectos p
--LEFT JOIN Asignaciones a
--ON p.ProyectoID = a.ProyectoID
--GROUP BY p.Nombre;



-- 3) ¿Qué es una excepción predefinida en PL/SQL y cómo se
-- maneja? Da un ejemplo de cómo manejarías la excepción
-- NO_DATA_FOUND en un bloque PL/SQL.

-- Una excepción es una forma de preevenir errores esperados,
-- como por ejemplo una division por 0.
-- En el caso de "NO_DATA_FOUND" se utiliza cuando se quiere realizar una instruccion
-- y no existe o no se encuentra un dato buscado

-- WHEN NO_DATA_FOUND THEN
--	DBMS_OUTPUT.PUT_LINE('Error: No se encontro el dato buscado');
-- END;



-- 4) Explica qué es un cursor explícito y cómo se usa en PL/SQL.
-- Menciona al menos dos atributos de cursor (como %NOTFOUND) y
-- su propósito.


-- Un cursor explicito es similar a los cursores vistos en C
-- Son una especie de variables las cuales apuntan a unas filas especificas.
-- algunos atributos de cursores serian

-- %NOTFOUND este atributo nos ayuda a terminar de recorrer las filas de un cursor