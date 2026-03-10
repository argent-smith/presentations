# Python: comprehension + sum — декларативная постановка задачи
from dataclasses import dataclass

@dataclass
class Order:
    price: float

orders = [
    Order(50.0), Order(120.0), Order(200.0), Order(80.0), Order(150.0)
]

def total_discount(orders):
    return sum(
        o.price * 0.1
        for o in orders
        if o.price > 100.0
    )

print(f"сумма скидок: {total_discount(orders):.1f}")
# ожидаемый результат: 47.0
