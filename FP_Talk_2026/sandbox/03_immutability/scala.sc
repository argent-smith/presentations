// Scala: case class с copy — структурное переиспользование, не полная копия
case class User(name: String, age: Int)

val user = User("Alice", 30)
val olderUser = user.copy(age = 31)

println(s"original: $user")
println(s"updated:  $olderUser")
// user неизменён
