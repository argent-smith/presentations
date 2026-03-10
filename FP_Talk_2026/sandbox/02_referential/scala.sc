// Scala: чистая функция vs зависимость от внешнего состояния

def applyDiscount(rate: Double, price: Double): Double =
  price * (1.0 - rate)

// Нечистая: результат зависит от внешней переменной
var taxRate = 0.2
val priceWithTax = (price: Double) => price * (1 + taxRate)

// Чистая: результат определяется только аргументами
val applyDiscountPure = (rate: Double) => (price: Double) => price * (1 - rate)

println(s"чистая: ${applyDiscount(0.1, 100.0)}")
println(s"нечистая до изменения: ${priceWithTax(100.0)}")

taxRate = 0.5
println(s"нечистая после изменения taxRate: ${priceWithTax(100.0)}")
println(s"чистая — всегда одинаково: ${applyDiscountPure(0.1)(100.0)}")
