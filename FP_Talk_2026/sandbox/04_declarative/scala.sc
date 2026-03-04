// Scala: коллекционное API читается как постановка задачи
case class Order(price: Double)

val orders = List(
  Order(50.0), Order(120.0), Order(200.0), Order(80.0), Order(150.0)
)

def totalDiscount(orders: List[Order]): Double =
  orders
    .filter(_.price > 100.0)
    .map(_.price * 0.1)
    .sum

println(s"сумма скидок: ${totalDiscount(orders)}")
// ожидаемый результат: 47.0
