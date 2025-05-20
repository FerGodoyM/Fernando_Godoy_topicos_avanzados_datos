import oracledb
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()
conn = oracledb.connect(user="curso_topicos", password="curso2025", dsn="oracle-db:1521/XEPDB1")
cur = conn.cursor()

print("Conexión exitosa a la base de datos Oracle.")

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
    total_pedido = 0
    num_detalles = random.randint(1, 5)
    for _ in range(num_detalles):
        producto_id = random.randint(1, TOTAL_PRODUCTOS)
        cantidad = random.randint(1, 10)
        cur.execute("SELECT Precio FROM Productos WHERE ProductoID = :1", (producto_id,))
        precio = cur.fetchone()[0]
        total_pedido += precio * cantidad

        cur.execute("""
            INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
            VALUES (:1, :2, :3, :4)
        """, (detalle_id, pedido_id, producto_id, cantidad))
        detalle_id += 1

    # Actualizar total del pedido
    cur.execute("""
        UPDATE Pedidos SET Total = :1 WHERE PedidoID = :2
    """, (total_pedido, pedido_id))

    if pedido_id % 10_000 == 0:
        print(f"{pedido_id} pedidos procesados")
        conn.commit()

# 4. Insertar INVENTARIO

print("Insertando inventario...")
for i in range(1, TOTAL_PRODUCTOS + 1):
    cantidad = random.randint(10, 500)
    cur.execute("""
        INSERT INTO Inventario (ProductoID, CantidadProductos)
        VALUES (:1, :2)
    """, (i, cantidad))
conn.commit()


conn.commit()
cur.close()
conn.close()
print("Datos insertados exitosamente.")
