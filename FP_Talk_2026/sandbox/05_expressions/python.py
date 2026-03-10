# Python: if — инструкция; тернарный оператор — единственное выражение-ветвление
# match (3.10+) — тоже инструкция, не возвращает значение:
#   label = match n: ...  → SyntaxError

def classify(n: int) -> str:
    return "negative" if n < 0 else "zero" if n == 0 else "positive"

for n in [-3, 0, 5]:
    print(f"{n} → {classify(n)}")
