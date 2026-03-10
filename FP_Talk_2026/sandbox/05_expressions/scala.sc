// Scala: match — выражение; компилятор предупреждает о неполном переборе
def classify(n: Int): String = n match {
  case n if n < 0 => "negative"
  case 0          => "zero"
  case _          => "positive"
}

List(-3, 0, 5).foreach(n => println(s"$n → ${classify(n)}"))
