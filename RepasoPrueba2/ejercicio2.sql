--Crea un trigger auditar_eliminacion_pedido que se
--dispare después de eliminar un pedido y registre
--el PedidoID, ClienteID, Total y la fecha de
--eliminación en una tabla de auditoría
--AuditoriaPedidos.

CREATE TABLE AuditoriaPedidos(
	AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	PedidoID NUMBER,
	ClienteID NUMBER,
	Total NUMBER,
	FechaEliminacion DATE
);


CREATE OR REPLACE TRIGGER auditar_eliminacion_pedido
AFTER DELETE ON Pedidos
FOR EACH ROW
BEGIN
	INSERT INTO AuditoriaPedidos(PedidoID, ClienteID, Total, FechaEliminacion)
	VALUES (:OLD.PedidoID, :OLD.ClienteID, :OLD.Total, SYSDATE);
END;
/

DELETE FROM Pedidos WHERE PedidoID = 920;
SELECT * FROM AuditoriaPedidos;