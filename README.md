# Base de Datos

![Diagrama de la Base de Datos](https://github.com/FerGodoyM/Fernando_Godoy_topicos_avanzados_datos/blob/main/diagramaDB.png?raw=true)

## Comandos útiles

```bash
# Levantar el contenedor con build
docker-compose up --build

# Detener y eliminar volúmenes
docker-compose down -v

# Acceder al contenedor de Oracle
docker-compose exec oracle-db bash

# Iniciar sesión en SQL*Plus
sqlplus curso_topicos/curso2025@//localhost:1521/XEPDB1

# Iniciar insertador.py
docker-compose exec data-inserter python insertador.py
