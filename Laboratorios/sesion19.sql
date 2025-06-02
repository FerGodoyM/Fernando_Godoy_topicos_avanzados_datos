--Diseña una estrategia de respaldo para el esquema
--curso_topicos. Documenta la estrategia en
--comentarios y escribe un script RMAN para un
--respaldo completo y un respaldo incremental.

--EN SQL (uno por uno)
CONNECT sys AS sysdba;
SELECT log_mode FROM v$database;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

--En el bash (uno por uno)
rman

# Configura la política de retención a una ventana de recuperación de 7 días
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

# Inicia el bloque RUN para realizar las acciones de backup
RUN {
    # Realiza el backup de la base de datos junto con los archivos archivados
    BACKUP DATABASE PLUS ARCHIVELOG;

    # Elimina los backups obsoletos según la política de retención configurada
    DELETE OBSOLETE;
}
# Muestra el estado de los backups actuales
LIST BACKUP;

--Simula un fallo eliminando la tabla Productos y
--recupera los datos usando Flashback (si está
--habilitado) o RMAN. Documenta el proceso.

RUN {
    BACKUP INCREMENTAL LEVEL 1 DATABASE;
    BACKUP ARCHIVELOG ALL;
}

CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u01/backup/%U';
BACKUP DATABASE;
