# Dockerfile para Oracle Database
FROM oracle/database:21.3.0-xe

# Exponer el puerto predeterminado del listener de Oracle
EXPOSE 1521

# Configurar variables de entorno (opcional, ya que la imagen oficial las maneja)
ENV ORACLE_SID=XE
ENV ORACLE_PWD=oracle

# El CMD ya está definido en la imagen base, pero lo especificamos para claridad
CMD ["sh", "-c", "exec /opt/oracle/runOracle.sh"]