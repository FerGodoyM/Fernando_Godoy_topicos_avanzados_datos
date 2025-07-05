---------------------------------EJERCICIO 1---------------------------------

--Diseña un modelo NoSQL para el esquema curso_topicos. Documenta en comentarios cómo
--estructurarías los datos en MongoDB (por ejemplo, qué datos embebes y por qué).
--Proporciona un ejemplo de un documento.
[
{
  "ClienteID": 4,
  "Nombre": "Carlos Rivas",
  "Ciudad": "Concepción",
  "FechaNacimiento": "1988-07-22",
  "Pedidos": [
    {
      "PedidoID": 110,
      "Total": 1350,
      "FechaPedido": "2025-06-10",
      "Detalles": [
        {
          "ProductoID": 3,
          "Nombre": "Teclado Mecánico",
          "Precio": 150,
          "Cantidad": 2
        },
        {
          "ProductoID": 4,
          "Nombre": "Monitor 24",
          "Precio": 525,
          "Cantidad": 1
        }
      ]
    }
  ]
}
]


-- En este modelo, los clientes tienen un array de pedidos, y cada pedido tiene un array de detalles de productos.
-- Esto permite una estructura anidada que refleja las relaciones entre clientes, pedidos y productos.
-- Los datos se embeben para evitar múltiples consultas y mejorar la eficiencia de acceso a la información relacionada.

---------------------------------EJERCICIO 2---------------------------------

--Escribe dos consultas en MongoDB:
--a. Una para obtener los clientes de una ciudad específica (por ejemplo, Santiago).
--b. Otra para calcular el número total de productos vendidos por producto.

db.clientes.find({ "Ciudad": "Concepción" },{ "Nombre": 1, "Ciudad": 1, "_id": 0 });

db.clientes.aggregate([
  { $unwind: "$Pedidos" },
  { $unwind: "$Pedidos.Detalles" },
  {
    $group: {
      _id: "$Pedidos.Detalles.Nombre",
      totalVendidos: { $sum: "$Pedidos.Detalles.Cantidad" }
    }
  }
]);