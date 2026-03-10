# Python: dataclass(frozen=True) — иммутабельность через декоратор
from dataclasses import dataclass, replace

@dataclass(frozen=True)
class User:
    name: str
    age: int

user = User("Alice", 30)
older_user = replace(user, age=31)

print(f"original: {user}")
print(f"updated:  {older_user}")

try:
    user.age = 99  # type: ignore
except Exception as e:
    print(f"мутация невозможна: {type(e).__name__}")
