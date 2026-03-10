// Scala: функция — объект Function1
val multiply: Int => Int => Int = factor => x => x * factor
val triple = multiply(3)
val result = List(1, 2, 3, 4, 5).map(triple)

println(result)
// result: List(3, 6, 9, 12, 15)
