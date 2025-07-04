-------------------------------------EJERCICIO 1-------------------------------------

--Diseña (sin script) una estrategia de alta disponibilidad para el esquema curso_topicos:
--  ○ Número de nodos y su ubicación geográfica.
--  ○ Tipo de replicación (síncrona o asíncrona).
--  ○ Uso de los nodos secundarios (por ejemplo, para reportes).
--  ○ Mecanismo de failover.

--Nodos:
-- Nodo Primario: Localizado en Santiago, Chile.
-- Nodo Secundario: Localizado en la Region de Coquimbo, Chile.

-- Replicación:
-- Tipo de replicación: ASíncrona debido a ser más eficiente para la latencia 

-- Uso de nodos secundarios:
-- Los nodos secundarios se utilizarán para reportes y consultas de lectura, lo que permitirá
-- reducir la carga en el nodo primario y mejorar el rendimiento general del sistema.

-- Mecanismo de failover:
-- Se implementará un mecanismo de failover automático que detectará la caída del nodo primario
-- y cambiará automáticamente al nodo secundario.

--Respaldo completo semanal y archivelogs diarios
--Para el monitoreo se ocupara Oracle Enterprise Manager para alertas de fallos

-------------------------------------EJERCICIO 2-------------------------------------

--Escribe una consulta de solo lectura que podría
--ejecutarse en el nodo standby para generar un
--reporte de ventas por cliente. Explica cómo
--aprovecharías Active Data Guard.

SELECT c.ClienteID, c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND
TO_DATE('2025-06-30', 'YYYY-MM-DD')
GROUP BY c.ClienteID, c.Nombre
ORDER BY TotalVentas DESC;


--Explicación:
-- Active Data Guard permite que el nodo standby se utilice para consultas de solo lectura,
-- lo que significa que esta consulta puede ejecutarse en el nodo secundario sin afectar
-- el rendimiento del nodo primario. 