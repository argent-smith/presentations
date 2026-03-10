# Python: разница между чистой и нечистой функцией — только дисциплина

# Нечистая: зависит от внешнего состояния
current_discount = 0.1

def apply_discount_impure(price):
    return price * (1 - current_discount)

# Чистая: результат определяется только аргументами
def apply_discount(rate: float, price: float) -> float:
    return price * (1 - rate)

print(f"нечистая: {apply_discount_impure(100.0)}")  # 90.0 сейчас...
current_discount = 0.5
print(f"нечистая после изменения: {apply_discount_impure(100.0)}")  # 50.0!

print(f"чистая первый раз:  {apply_discount(0.1, 100.0)}")  # 90.0 всегда
print(f"чистая второй раз: {apply_discount(0.1, 100.0)}")  # 90.0 всегда
