import cx_Oracle
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()
conn = cx_Oracle.connect("curso_topicos", "curso2025", "localhost:1521/XEPDB1")
cur = conn.cursor()


TOTAL_CLIENTES = 500_000
TOTAL_PRODUCTOS = 1000
TOTAL_PEDIDOS = 1_000_000
TOTAL_DETALLES = 2_000_000

# 1. Insertar CLIENTES
print("Insertando clientes...")
for i in range(1, TOTAL_CLIENTES + 1):
    nombre = fake.name()
    ciudad = fake.city()
    fecha_nac = fake.date_of_birth(minimum_age=18, maximum_age=90)
    cur.execute("""
        INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
        VALUES (:1, :2, :3, :4)
    """, (i, nombre, ciudad, fecha_nac))
    if i % 10_000 == 0:
        print(f"{i} clientes insertados")
        conn.commit()

# 2. Insertar PRODUCTOS
print("Insertando productos...")
for i in range(1, TOTAL_PRODUCTOS + 1):
    nombre = fake.word().capitalize()
    precio = round(random.uniform(10, 1000), 2)
    cur.execute("""
        INSERT INTO Productos (ProductoID, Nombre, Precio)
        VALUES (:1, :2, :3)
    """, (i, nombre, precio))
conn.commit()

# 3. Insertar PEDIDOS
print("Insertando pedidos...")
for i in range(1, TOTAL_PEDIDOS + 1):
    cliente_id = random.randint(1, TOTAL_CLIENTES)
    fecha_pedido = fake.date_between(start_date='-2y', end_date='today')
    total = 0  # Se recalculará al insertar DetallesPedidos
    cur.execute("""
        INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
        VALUES (:1, :2, :3, :4)
    """, (i, cliente_id, total, fecha_pedido))
    if i % 10_000 == 0:
        print(f"{i} pedidos insertados")
        conn.commit()

# 4. Insertar DETALLES PEDIDOS
print("Insertando detalles de pedidos...")
detalle_id = 1
for pedido_id in range(1, TOTAL_PEDIDOS + 1):
    producto_id = random.randint(1, TOTAL_PRODUCTOS)
    cantidad = random.randint(1, 10)
    cur.execute("""
        INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
        VALUES (:1, :2, :3, :4)
    """, (detalle_id, pedido_id, producto_id, cantidad))
    detalle_id += 1
    if pedido_id % 10_000 == 0:
        print(f"{pedido_id} detalles insertados")
        conn.commit()

conn.commit()
cur.close()
conn.close()
print("Datos insertados exitosamente.")
