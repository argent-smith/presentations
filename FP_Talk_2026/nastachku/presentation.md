---
marp: true
paginate: true
size: 16:9
html: true
---

<style>
@font-face {
  font-family: 'Montserrat';
  src: url("template/шаблон презентации ульяновск 2026/шрифты/Montserrat-Regular.otf") format('opentype');
  font-weight: 400;
  font-style: normal;
}
@font-face {
  font-family: 'Montserrat';
  src: url("template/шаблон презентации ульяновск 2026/шрифты/Montserrat-Light.otf") format('opentype');
  font-weight: 300;
  font-style: normal;
}
@font-face {
  font-family: 'Montserrat';
  src: url("template/шаблон презентации ульяновск 2026/шрифты/Montserrat-SemiBold.otf") format('opentype');
  font-weight: 600;
  font-style: normal;
}
@font-face {
  font-family: 'Montserrat';
  src: url("template/шаблон презентации ульяновск 2026/шрифты/Montserrat-Bold.otf") format('opentype');
  font-weight: 700;
  font-style: normal;
}
@font-face {
  font-family: 'Montserrat';
  src: url("template/шаблон презентации ульяновск 2026/шрифты/Montserrat-ExtraBold.otf") format('opentype');
  font-weight: 800;
  font-style: normal;
}

section {
  font-family: 'Montserrat', 'Segoe UI', sans-serif;
  background: #ffffff;
  color: #1D1D1D;
  padding: 48px 64px;
  font-size: 28px;
  line-height: 1.5;
}

section h1 {
  font-weight: 700;
  font-size: 1.8em;
  color: #1D1D1D;
  border-bottom: 4px solid #ED7D31;
  padding-bottom: 0.2em;
  margin-bottom: 0.6em;
}

section h2 {
  font-weight: 600;
  font-size: 1.1em;
  color: #44546A;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  margin-bottom: 0.4em;
}

section ul {
  padding-left: 1.2em;
  margin: 0.4em 0;
}

section li {
  margin-bottom: 0.35em;
}

section strong {
  color: #ED7D31;
  font-weight: 600;
}

section blockquote {
  border-left: 4px solid #ED7D31;
  padding: 0.4em 1em;
  color: #44546A;
  font-style: italic;
  margin: 1em 0;
  background: #f5f5f5;
  border-radius: 0 4px 4px 0;
}

section table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.85em;
}

section th {
  background: #44546A;
  color: #ffffff;
  padding: 0.5em 0.8em;
  text-align: left;
  font-weight: 600;
}

section td {
  padding: 0.4em 0.8em;
  border-bottom: 1px solid #e0e0e0;
}

section tr:nth-child(even) td {
  background: #f8f8f8;
}

section code {
  font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;
  background: #2d2d2d;
  color: #f8f8f2;
  padding: 0.1em 0.3em;
  border-radius: 3px;
  font-size: 0.85em;
}

section pre {
  background: #2d2d2d;
  border-radius: 6px;
  padding: 0.8em 1em;
  overflow: hidden;
  margin: 0.3em 0;
}

section pre code {
  background: transparent;
  padding: 0;
  font-size: 0.75em;
  line-height: 1.4;
  color: #f8f8f2;
}

/* Syntax highlight approximation */
section pre code .comment { color: #75715e; }

/* Pagination */
section::after {
  font-size: 0.6em;
  color: #aaaaaa;
  font-weight: 300;
}

/* ---- Dark slides (title + section breaks) ---- */
section.dark {
  background: #44546A;
  color: #ffffff;
}

section.dark h1 {
  color: #ffffff;
  border-bottom-color: #ED7D31;
  font-size: 2em;
}

section.dark h2 {
  color: #FFC000;
  font-size: 1.0em;
}

section.dark strong {
  color: #FFC000;
}

section.dark::after {
  color: rgba(255,255,255,0.4);
}

section.dark p {
  color: rgba(255,255,255,0.85);
  font-weight: 300;
}

/* ---- Code slides ---- */
section.code {
  padding: 32px 48px;
  font-size: 22px;
}

section.code h1 {
  font-size: 1.2em;
  margin-bottom: 0.4em;
}

.lang-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 0.5em;
  margin-top: 0.4em;
}

.lang-grid > div {
  min-width: 0;
}

.lang-label {
  font-size: 0.6em;
  font-weight: 700;
  color: #44546A;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-bottom: 0.2em;
}

section.code pre code {
  font-size: 0.62em;
  line-height: 1.35;
}

/* ---- Section number badge ---- */
.section-num {
  display: inline-block;
  background: #ED7D31;
  color: #ffffff;
  font-size: 0.75em;
  font-weight: 700;
  padding: 0.2em 0.6em;
  border-radius: 4px;
  margin-bottom: 0.5em;
  letter-spacing: 0.05em;
}

/* ---- Summary table highlight ---- */
.plus-three { color: #ED7D31; font-weight: 700; }
.plus-two   { color: #44546A; font-weight: 600; }
.plus-one   { color: #aaaaaa; }
</style>

<!-- _class: dark -->
<!-- _paginate: false -->

# Древняя магия<br>в повседневном коде

## Пять принципов ФП в пяти языках

**Стачка 2026**

---

# ФП в повседневном коде

- `[1,2,3].map(x => x * 2)` — функции высшего порядка
- `const add = x => y => x + y` — замыкание, захват лексического окружения
- `const x = 1; x = 2 // TypeError` — запрет перезаписи переменной

> ФП — пять конкретных свойств кода
> Смысл — **описание результата**, а не микроменеджмент процесса.

---

# Карта доклада

5 свойств × 5 языков

| Язык       | Философия                     |
|------------|-------------------------------|
| OCaml      | чистота подхода               |
| Scala      | прагматизм JVM                |
| Python     | доступность                   |
| JavaScript | вездесущесть                  |
| Rust       | системное программирование    |

---

<!-- _class: dark -->
<!-- _paginate: false -->

<div class="section-num">Свойство 1 из 5</div>

# Декларативность

Код описывает **что** нужно получить, не **как** это вычислить.

---

# Декларативность

Декларативный код специфицирует *что* вычислить. Императивный — *как* управлять потоком выполнения.

- Паттерн не специфичен для ФП: SQL (`SELECT … WHERE`), HTML, регулярные выражения — декларативны. ФП — частный случай
  декларативного стиля.
- `for`-цикл: управление индексом, условием завершения, аккумулятором. `map` / `filter` / `fold`: спецификация трансформации.
- **Зависимость:** декларативный стиль требует функций как значений и иммутабельности данных.

> Декларативный код легко оптимизируется: компилятор рассуждает о намерении, а не о конкретных шагах — все применимые преобразования выводимы из семантики.

---

<!-- _class: code -->

# Декларативность — OCaml

**Задача:** сумма скидок для заказов дороже 100, скидка 10%.

```ocaml
(* pipeline с |> *)
let total_discount orders =
  let open List in
  orders
  |> filter (fun o -> o.price > 100.0)
  |> map (fun o -> o.price *. 0.1)
  |> fold_left ( +. ) 0.0
```

---

<!-- _class: code -->

# Декларативность — Scala

**Задача:** сумма скидок для заказов дороже 100, скидка 10%.

```scala
// читается как постановка задачи
def totalDiscount(orders: List[Order]): Double =
  orders
    .filter(_.price > 100.0)
    .map(_.price * 0.1)
    .sum
```

---

<!-- _class: code -->

# Декларативность — Rust

**Задача:** сумма скидок для заказов дороже 100, скидка 10%.

```rust
fn total_discount_imp(orders: &[Order]) -> f64 {
    let mut total = 0.0;
    for o in orders {
        if o.price > 100.0 { total += o.price * 0.1; }
    }
    total
}

fn total_discount(orders: &[Order]) -> f64 {
    orders.iter()
        .filter(|o| o.price > 100.0)
        .map(|o| o.price * 0.1)
        .sum()
}
// LLVM компилирует обе версии в идентичный машинный код
```

---

<!-- _class: code -->

# Декларативность — Python

**Задача:** сумма скидок для заказов дороже 100, скидка 10%.

```python
def total_discount_imp(orders):
    total = 0.0
    for o in orders:
        if o.price > 100.0:
            total += o.price * 0.1
    return total

def total_discount(orders):
    return sum(o.price * 0.1 for o in orders if o.price > 100.0)
```

---

<!-- _class: code -->

# Декларативность — JavaScript

**Задача:** сумма скидок для заказов дороже 100, скидка 10%.

```javascript
function totalDiscountImp(orders) {
  let total = 0;
  for (const o of orders) {
    if (o.price > 100) total += o.price * 0.1;
  }
  return total;
}

const totalDiscount = (orders) =>
  orders
    .filter((o) => o.price > 100)
    .map((o) => o.price * 0.1)
    .reduce((acc, d) => acc + d, 0);
```

---

<!-- _class: dark -->
<!-- _paginate: false -->

<div class="section-num">Свойство 2 из 5</div>

# Выражения вместо инструкций

Если `if` возвращает значение — код становится компонуемым.

---

# Выражения вместо инструкций

*Инструкция* выполняется ради эффекта. *Выражение* вычисляется в значение. В expression-oriented языках всё — выражение.

- **Компонуемость:** выражение подставляется в любую позицию, ожидающую значение. `f(if x > 0 then a else b)` корректно в OCaml / Scala / Rust; требует ternary-оператора в Python / JS.
- **Exhaust checking:** OCaml и Rust статически верифицируют полноту `match`. Пропущенная ветка — ошибка компиляции.
- **Pattern matching:** деструктуризация + связывание переменных + exhaust checking в одной конструкции.

|                     | OCaml | Scala | Rust | Python | JS |
|---------------------|:-----:|:-----:|:----:|:------:|:--:|
| `if` — выражение    |   ✓   |   ✓   |  ✓   |   —    | —  |
| `match` — выражение |   ✓   |   ✓   |  ✓   |   —    | —  |
| Полнота перебора    |   ✓   |   ✓   |  ✓   |   —    | —  |

---

<!-- _class: code -->

# Выражения вместо инструкций — OCaml

**Задача:** классификация числа — вернуть метку без промежуточной переменной.

```ocaml
let classify n =
  match n with
  | n when n < 0 -> "negative"
  | 0            -> "zero"
  | _            -> "positive"

let label = String.uppercase_ascii (classify (-5))
(* выражение в позиции аргумента *)
```

---

<!-- _class: code -->

# Выражения вместо инструкций — Scala

**Задача:** классификация числа — вернуть метку без промежуточной переменной.

```scala
def classify(n: Int): String =
  n match {
    case n if n < 0 => "negative"
    case 0          => "zero"
    case _          => "positive"
  }

val label = classify(-5).toUpperCase
```

---

<!-- _class: code -->

# Выражения вместо инструкций — Rust

**Задача:** классификация числа — вернуть метку без промежуточной переменной.

```rust
fn classify(n: i32) -> &'static str {
    match n {
        n if n < 0 => "negative",
        0          => "zero",
        _          => "positive",
    }
}

let label = classify(-5).to_uppercase();
```

---

<!-- _class: code -->

# Выражения вместо инструкций — Python

**Задача:** классификация числа — вернуть метку без промежуточной переменной.

```python
def classify(n: int) -> str:
    return (
        "negative" if n < 0 else
        "zero"     if n == 0 else
        "positive"
    )

label = classify(-5).upper()

# label = match n: ...  → SyntaxError: match — инструкция
```

---

<!-- _class: code -->

# Выражения вместо инструкций — JavaScript

**Задача:** классификация числа — вернуть метку без промежуточной переменной.

```javascript
const classify = (n) =>
  n < 0 ? "negative"
  : n === 0 ? "zero"
  : "positive";

const label = classify(-5).toUpperCase();

// if (...) { ... }  → инструкция, нет значения
// n < 0 ? ... : ... → выражение, есть значение
```

---

<!-- _class: dark -->
<!-- _paginate: false -->

<div class="section-num">Свойство 3 из 5</div>

# Функции как значения

First-class value: передаётся аргументом, связывается с переменной, возвращается из функции.

---

# Функции как значения

Функция — *first-class value*: связывается с переменной, передаётся аргументом, возвращается из функции.

- **HOF** (*higher-order function*) — принимает или возвращает функцию. `map`, `filter`, `fold` — частный случай.
- **Замыкание** — функция с захватом лексического окружения. Rust: явный `move`; JS: неявный захват.
- **Каррирование** — `f(a, b)` → `f(a)(b)`. OCaml: по умолчанию; Python: `functools.partial`; JS: явные замыкания.

> Свойство поддерживается во всех пяти языках. Различие — степень **глубины интеграции**.

---

<!-- _class: code -->

# Функции как значения — OCaml

**Задача:** создать умножитель с коэффициентом и применить к списку.

```ocaml
(* каррирование по умолчанию *)
let multiply factor x = x * factor
let triple = multiply 3

(* замыкание: base захвачен в лексическом окружении *)
let make_adder base = fun x -> base + x
let add10 = make_adder 10  (* add10 5 = 15 *)

(* HOF: функция как аргумент *)
let result = List.map triple [1; 2; 3; 4; 5]
(* [3; 6; 9; 12; 15] *)
```

---

<!-- _class: code -->

# Функции как значения — Scala

**Задача:** создать умножитель с коэффициентом и применить к списку.

```scala
// каррирование через .curried
val multiply: (Int, Int) => Int = (factor, x) => x * factor
val triple: Int => Int = multiply.curried(3)

// замыкание: base захвачен в лексическом окружении
val base = 10
val addBase: Int => Int = x => x + base

val result = List(1, 2, 3, 4, 5).map(triple)
// List(3, 6, 9, 12, 15)
```

---

<!-- _class: code -->

# Функции как значения — Rust

**Задача:** создать умножитель с коэффициентом и применить к списку.

```rust
use auto_curry::curry;

#[curry]
fn multiply(factor: i32, x: i32) -> i32 { factor * x }

let triple: impl Fn(i32) -> i32 = multiply(3);

let base = 10;
let add_base: impl Fn(i32) -> i32 = move |x| x + base;

let result: Vec<i32> =
    vec![1, 2, 3, 4, 5].into_iter().map(triple).collect();
```

---

<!-- _class: code -->

# Функции как значения — Python

**Задача:** создать умножитель с коэффициентом и применить к списку.

```python
from functools import partial

def multiply(factor, x): return factor * x
triple = partial(multiply, 3)  # каррирование

result = list(map(triple, [1, 2, 3, 4, 5]))
# [3, 6, 9, 12, 15]

# декоратор = HOF: fn → fn
def logged(fn):
    def wrapper(*a): return fn(*a)
    return wrapper

@logged
def triple2(x): return x * 3
```

---

<!-- _class: code -->

# Функции как значения — JavaScript

**Задача:** создать умножитель с коэффициентом и применить к списку.

```javascript
import * as R from "ramda";

const multiply = R.curry((factor, x) => factor * x);
const triple = multiply(3);

const base = 10;
const addBase = (x) => x + base;

const result = [1, 2, 3, 4, 5].map(triple);
// [3, 6, 9, 12, 15]
```

---

<!-- _class: dark -->
<!-- _paginate: false -->

<div class="section-num">Свойство 4 из 5</div>

# Ссылочная прозрачность

`f(x)` всегда возвращает одно и то же для одного `x`.

---

# Ссылочная прозрачность

Выражение *ссылочно прозрачно*, если его можно заменить значением без изменения поведения программы.

- **Чистая функция:** возвращаемое значение зависит исключительно от аргументов; нет побочных эффектов.
- **Следствия:** корректная мемоизация; независимость порядка вычислений; data race–free параллелизм.
- **Эффекты:** неизбежны (I/O, время, состояние). Стратегия — **изоляция** на границах системы.

| Язык        | Подход к чистоте                              |
|-------------|-----------------------------------------------|
| OCaml       | чистота — умолчание; `ref` — явное исключение |
| Scala       | эффекты в типе: `IO[Double]` ≠ `Double`       |
| Rust        | `&mut` в сигнатуре — явный сигнал о мутации   |
| Python / JS | вопрос дисциплины программиста                |

---

<!-- _class: code -->

# Ссылочная прозрачность — OCaml

**Задача:** функция скидки — чистая и нечистая версии.

```ocaml
let current_discount = ref 0.1

let price_with_global_discount price =
  price *. (1.0 -. !current_discount)

let apply_discount rate price =
  price *. (1.0 -. rate)

let discounted = apply_discount 0.1 100.0
```

---

<!-- _class: code -->

# Ссылочная прозрачность — Scala

**Задача:** функция скидки — чистая и нечистая версии.

```scala
def applyDiscount(rate: Double, price: Double): Double =
  price * (1.0 - rate)

def withLog(rate: Double, price: Double): IO[Double] =
  IO.println("...") *> IO.pure(applyDiscount(rate, price))
```

---

<!-- _class: code -->

# Ссылочная прозрачность — Rust

**Задача:** функция скидки — чистая и нечистая версии.

```rust
fn apply_discount(rate: f64, price: f64) -> f64 {
    price * (1.0 - rate)
}

// нечистая версия — &mut в сигнатуре
fn apply_discount_mut(rate: f64, price: &mut f64) {
    *price *= 1.0 - rate;
}
```

---

<!-- _class: code -->

# Ссылочная прозрачность — Python

**Задача:** функция скидки — чистая и нечистая версии.

```python
current_discount = 0.1

def price_with_global_discount(price: float) -> float:
    return price * (1 - current_discount)

def apply_discount(rate: float, price: float) -> float:
    return price * (1 - rate)
```

---

<!-- _class: code -->

# Ссылочная прозрачность — JavaScript

**Задача:** функция скидки — чистая и нечистая версии.

```javascript
let taxRate = 0.2;
const priceWithTax = (price) => price * (1 + taxRate);

const applyDiscount = (rate) => (price) => price * (1 - rate);
```

---

<!-- _class: dark -->
<!-- _paginate: false -->

<div class="section-num">Свойство 5 из 5</div>

# Иммутабельность

Данные не изменяются — создаются новые версии.

---

# Иммутабельность

`const` / `val` — запрет перезаписи переменной. Иммутабельность — запрет мутации самого значения.

- **Гарантия компилятором** (OCaml `let`, Rust `let`) / **соглашением** (Scala `val`) / **опционально** (Python `frozen=True`, JS `Object.freeze`)
- **Persistent data structures:** *structural sharing*. Обновление одного поля — `O(log n)`, не `O(n)`.
- **Следствия:** нет data races; нет defensive copies; referential transparency по конструкции.

---

<!-- _class: code -->

# Иммутабельность — OCaml

**Задача:** обновить одно поле записи без изменения оригинала.

```ocaml
(* record иммутабелен *)
type user = {
  name: string;
  age: int;
}

let user = { name = "Alice"; age = 30 }

let older = { user with age = 31 }
(* user не изменился *)
```

---

<!-- _class: code -->

# Иммутабельность — Scala

**Задача:** обновить одно поле записи без изменения оригинала.

```scala
case class User(name: String, age: Int)

val user = User("Alice", 30)
val older = user.copy(age = 31)
// user.age = 31 → error: reassignment to val
```

---

<!-- _class: code -->

# Иммутабельность — Rust

**Задача:** обновить одно поле записи без изменения оригинала.

```rust
struct User { name: String, age: u32 }

let user = User { name: "Alice".into(), age: 30 };
let older = User { age: 31, ..user };

let mut draft = User { name: "Bob".into(), age: 25 };
draft.age = 26;  // только let mut допускает мутацию
```

---

<!-- _class: code -->

# Иммутабельность — Python

**Задача:** обновить одно поле записи без изменения оригинала.

```python
from dataclasses import dataclass, replace

@dataclass(frozen=True)
class User:
    name: str
    age: int

user = User("Alice", 30)
older = replace(user, age=31)
user.age = 31  # FrozenInstanceError: cannot assign to field 'age'
```

---

<!-- _class: code -->

# Иммутабельность — JavaScript

**Задача:** обновить одно поле записи без изменения оригинала.

```javascript
"use strict";

const user = Object.freeze({ name: "Alice", age: 30 });
const older = { ...user, age: 31 };

user.age = 31;  // TypeError: Cannot assign to read only property
```

---

# Итог: пять свойств × пять языков

| Свойство               | OCaml   |  Scala  |  Rust   | Python |   JS    |
|------------------------|:-------:|:-------:|:-------:|:------:|:-------:|
| Декларативность        | **+++** | **+++** | **+++** |   ++   |   ++    |
| Выражения              | **+++** |   ++    | **+++** |   +    |    +    |
| Функции как значения   | **+++** | **+++** |   ++    |   ++   | **+++** |
| Ссылочная прозрачность | **+++** |   ++    |   ++    |   +    |    +    |
| Иммутабельность        | **+++** |   ++    | **+++** |   +    |    +    |

`+++` — в дизайне языка, идиоматично &nbsp;&nbsp; `++` — поддерживается, требует дисциплины &nbsp;&nbsp; `+` — возможно, но нетипично

---

# Выводы

ФП — набор формализуемых свойств кода, применимых независимо от языка и декларируемой парадигмы.

**Вопросы:**

1. Какие из пяти свойств присутствуют в вашем текущем проекте?

2. Какие из них язык гарантирует системой типов, а какие — только конвенцией?

3. Где явная иммутабельность или декларативный стиль снизили бы когнитивную нагрузку в последнем PR?

---

<!-- _class: dark -->
<!-- _paginate: false -->

# Спасибо

**Стачка 2026**

<br>

_Материалы доклада, sandbox и примеры кода:_
