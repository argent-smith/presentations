# Функциональные примитивы: обзор в специализированных и мейнстримных языках программирования

**Комплексный обзор фундаментальных свойств функционального программирования в OCaml, F#, Clojure, Scala, Ruby, Rust, Go, JavaScript, TypeScript, Python, Java и C++**

## Введение

Функциональное программирование строится на **пяти фундаментальных свойствах**, которые определяют саму суть парадигмы. Прочие — композиция, рекурсия, ленивость, типизация, паттерн-матчинг — являются вспомогательными инструментами, облегчающими реализацию этих базовых принципов.

### Пять фундаментальных свойств

1. **Функции как объекты первого класса** — функции являются полноценными значениями
2. **Чистые функции и чистота функций** — детерминизм и отсутствие эффектов
3. **Иммутабельность данных** — данные не изменяются после создания
4. **Декларативный стиль** — описание "что требуется", а не "как делается"
5. **Выражения вместо инструкций** — всё вычисляется в значение

### Вспомогательные свойства

Дополнительные механизмы, облегчающие реализацию фундаментальных свойств:

1. **Композиция функций** — построение сложной функциональности из простых функций
2. **Рекурсия вместо итерации** — повторяющиеся вычисления без изменяемого состояния
3. **Алгебраические типы данных (АТД)** — конструирование сложных типов, исключающих недопустимые состояния
4. **Сопоставление с образцом** — элегантная деструктуризация иммутабельных структур; естественно работает с АТД
5. **Статическая типизация с выводом типов** — безопасность на этапе компиляции без избыточных аннотаций
6. **Ленивые вычисления** — откладывание фактического вычисления до момента использования значения
7. **Изоляция эффектов** — явное отделение чистой логики от операций с эффектами

### О языках в этом обзоре

**Преимущественно функциональные языки:**
- **OCaml** — эталонный ML-семейства с сильной типизацией, мультипарадигменный (ФП + мощная ООП-подсистема)
- **F#** — потомок OCaml на .NET, прагматичный ФП с ООП
- **Clojure** — современный Lisp на JVM, иммутабельность по умолчанию, акцент на простоту
- **Scala** — JVM-платформа, баланс ФП и ООП

**Интерпретируемые функционально-ОО языки:**
- **Ruby** — динамический мультипарадигменный
- **Python 3.x** — простота и лаконичность

**Системные и коммерческие языки с сильной поддержкой ФП:**
- **Rust** — владение и заимствование, безопасность памяти без GC
- **Go** — простота, конкурентность, прагматичный минимализм
- **Java 8+** — промышленная зрелость
- **C++ 11/14/17/20** — производительность и контроль

**Веб-ориентированные языки:**
- **JavaScript (ES6+)** — вездесущий язык веба, функции первого класса
- **TypeScript** — JavaScript с статической типизацией и развитой системой типов

---

## Часть I: Фундаментальные свойства

### 1. Функции как объекты первого класса

**Смысл:** Функции являются полноценными значениями — их можно присваивать переменным, передавать как аргументы, возвращать как результаты.

**Значение (value):** Неизменяемый результат вычисления, который можно использовать в программе. Примеры: числа (42), строки ("hello"), булевы значения (true/false), функции, структуры данных. В функциональном программировании функции — такие же значения, как числа или строки.

**Зачем это нужно:** Фундамент для абстракции, композиции и переиспользования кода.

**Примеры на всех языках:**

```ocaml
(* OCaml *)
let create_multiplier factor = fun x -> x * factor
let triple = create_multiplier 3
```

```fsharp
// F# (родственник OCaml на .NET)
let createMultiplier factor = fun x -> x * factor
let triple = createMultiplier 3
```

```clojure
;; Clojure
(defn create-multiplier [factor]
  (fn [x] (* x factor)))
(def triple (create-multiplier 3))
```

```scala
// Scala 3
def createMultiplier(factor: Int): Int => Int =
  x => x * factor
val triple = createMultiplier(3)
```

```ruby
# Ruby
create_multiplier = ->(factor) { ->(x) { x * factor } }
triple = create_multiplier.call(3)
```

```rust
// Rust
fn create_multiplier(factor: i32) -> impl Fn(i32) -> i32 {
    move |x| x * factor
}
let triple = create_multiplier(3);
```

```go
// Go
func createMultiplier(factor int) func(int) int {
    return func(x int) int { return x * factor }
}
triple := createMultiplier(3)
```

```javascript
// JavaScript
const createMultiplier = factor => x => x * factor;
const triple = createMultiplier(3);
```

```typescript
// TypeScript
const createMultiplier = (factor: number): (x: number) => number =>
    x => x * factor;
const triple = createMultiplier(3);
```

```python
# Python
def create_multiplier(factor):
    return lambda x: x * factor
triple = create_multiplier(3)
```

```java
// Java
Function<Integer, Integer> createMultiplier(int factor) {
    return x -> x * factor;
}
Function<Integer, Integer> triple = createMultiplier(3);
```

```cpp
// C++
auto create_multiplier(int factor) {
    return [factor](int x) { return x * factor; };
}
auto triple = create_multiplier(3);
```

### 2. Чистые функции и чистота функций

**Смысл:** Детерминированность (одинаковый вход → одинаковый выход) и отсутствие эффектов.

**Ссылочная прозрачность (referential transparency):** Выражение называется ссылочно прозрачным, если его можно заменить соответствующим значением без изменения поведения программы. Чистая функция — это функция, результат вызова которой является ссылочно прозрачным для всех ссылочно прозрачных аргументов.

**Зачем это нужно:** Предсказуемость, тестируемость, параллелизуемость, оптимизируемость. Ссылочная прозрачность позволяет программисту и компилятору рассуждать о поведении программы как о системе перезаписи, что упрощает верификацию, рефакторинг и оптимизацию через мемоизацию, удаление общих подвыражений и распараллеливание.

**Примеры чистых функций:**

```ocaml
(* OCaml *)
let add a b = a + b
let multiply x y = x * y
let compose f g x = f (g x)
(* Все вызовы детерминированы и ссылочно прозрачны *)
```

```fsharp
// F#
let add a b = a + b
let multiply x y = x * y
let compose f g x = f (g x)
// Чистые функции по умолчанию
```

```clojure
;; Clojure
(defn add [a b] (+ a b))
(defn multiply [x y] (* x y))
(defn compose [f g] (fn [x] (f (g x))))
;; Иммутабельность и чистота поощряются языком
```

```scala
// Scala 3
def add(a: Int, b: Int): Int = a + b
def multiply(x: Int, y: Int): Int = x * y
def compose[A, B, C](f: B => C, g: A => B): A => C =
  x => f(g(x))
// Чистые функции - идиоматичный стиль
```

```ruby
# Ruby
add = ->(a, b) { a + b }
multiply = ->(x, y) { x * y }
compose = ->(f, g) { ->(x) { f.call(g.call(x)) } }
# Чистота достигается осознанно, язык не принуждает
```

```rust
// Rust
fn add(a: i32, b: i32) -> i32 { a + b }
fn multiply(x: i32, y: i32) -> i32 { x * y }
fn compose<A, B, C, F, G>(f: F, g: G) -> impl Fn(A) -> C
where
    F: Fn(B) -> C,
    G: Fn(A) -> B,
{
    move |x| f(g(x))
}
// Чистота гарантируется системой владения
```

```go
// Go
func add(a, b int) int {
    return a + b
}
func multiply(x, y int) int {
    return x * y
}
// Чистота достигается дисциплиной программиста
```

```javascript
// JavaScript
const add = (a, b) => a + b;
const multiply = (x, y) => x * y;
const compose = (f, g) => x => f(g(x));
// Чистота - вопрос стиля, язык не принуждает
```

```typescript
// TypeScript
const add = (a: number, b: number): number => a + b;
const multiply = (x: number, y: number): number => x * y;
const compose = <A, B, C>(f: (b: B) => C, g: (a: A) => B): (a: A) => C =>
  x => f(g(x));
// Типы помогают, но чистоту не гарантируют
```

```python
# Python
def add(a, b):
    return a + b  # Всегда возвращает одно и то же для одних входных данных
                  # Выражение add(2, 3) можно заменить на 5 без изменения поведения

def calculate_discount(price, rate):
    return price * (1 - rate)  # Детерминированно, без эффектов
```

```java
// Java
public static int add(int a, int b) {
    return a + b;
}

public static int multiply(int x, int y) {
    return x * y;
}

public static <A, B, C> Function<A, C> compose(
    Function<B, C> f,
    Function<A, B> g
) {
    return x -> f.apply(g.apply(x));
}
// Чистота - дисциплина программиста
```

```cpp
// C++
auto add(int a, int b) -> int {
    return a + b;
}

auto multiply(int x, int y) -> int {
    return x * y;
}

template<typename F, typename G>
auto compose(F f, G g) {
    return [=](auto x) { return f(g(x)); };
}
// Чистота требует дисциплины, const помогает
```

**Примеры нечистых функций:**

```ocaml
(* OCaml - ввод-вывод *)
let print_and_increment x =
  print_endline "Вызов функции";  (* Эффект вывода! *)
  x + 1
(* НЕ ссылочно прозрачно из-за побочного эффекта *)

(* OCaml - изменяемые ссылки *)
let counter = ref 0
let increment () =
  counter := !counter + 1;  (* Эффект! *)
  !counter
(* Результат зависит от внешнего состояния *)
```

```fsharp
// F# - изменяемое состояние
let mutable counter = 0
let increment () =
    counter <- counter + 1  // Эффект!
    counter  // НЕ ссылочно прозрачно

// F# - случайность
let rand = System.Random()
let rollDice () = rand.Next(1, 7)  // Недетерминированно
```

```clojure
;; Clojure - атомы (изменяемое состояние)
(def counter (atom 0))
(defn increment []
  (swap! counter inc))  ;; Эффект!
;; НЕ ссылочно прозрачно

;; Clojure - ввод-вывод
(defn greet-user []
  (println "Введите имя:")
  (let [name (read-line)]
    (println (str "Привет, " name "!"))))
;; Недетерминированно из-за IO
```

```scala
// Scala 3 - изменяемое состояние
var counter = 0
def increment(): Int =
  counter += 1  // Эффект!
  counter       // НЕ ссылочно прозрачно

// Scala 3 - случайность
import scala.util.Random
def rollDice(): Int = Random.nextInt(6) + 1  // Недетерминированно
```

```ruby
# Ruby - изменяемое состояние
$counter = 0
def increment
  $counter += 1  # Эффект!
  $counter       # НЕ ссылочно прозрачно
end

# Ruby - ввод-вывод
def greet_user
  print "Введите имя: "
  name = gets.chomp  # Эффект ввода!
  puts "Привет, #{name}!"  # Эффект вывода!
end
```

```rust
// Rust - изменяемое состояние
use std::cell::Cell;

fn impure_example() {
    let counter = Cell::new(0);
    let increment = || {
        let val = counter.get();
        counter.set(val + 1);  // Эффект!
        counter.get()
    };
    // НЕ ссылочно прозрачно
}

// Rust - ввод-вывод
fn greet_user() {
    println!("Введите имя:");  // Эффект!
    let mut name = String::new();
    std::io::stdin().read_line(&mut name).unwrap();  // Эффект!
    println!("Привет, {}!", name.trim());
}
```

```go
// Go - глобальное состояние
var counter = 0

func increment() int {
    counter++  // Эффект!
    return counter  // НЕ ссылочно прозрачно
}

// Go - текущее время
func getCurrentTimestamp() int64 {
    return time.Now().Unix()  // Недетерминированно!
}
```

```javascript
// JavaScript - внешнее состояние
let counter = 0;
function increment() {
    counter += 1;  // Эффект!
    return counter;  // НЕ ссылочно прозрачно
}

// JavaScript - Date.now()
function getCurrentTimestamp() {
    return Date.now();  // Недетерминированно!
}

// JavaScript - DOM манипуляции
function updateTitle(text) {
    document.title = text;  // Эффект!
}
```

```typescript
// TypeScript - изменяемое состояние
let counter = 0;
function increment(): number {
    counter += 1;  // Эффект!
    return counter;  // НЕ ссылочно прозрачно
}

// TypeScript - случайность
function randomInt(max: number): number {
    return Math.floor(Math.random() * max);  // Недетерминированно!
}
```

```python
# Python - глобальное состояние
counter = 0
def increment():
    global counter
    counter += 1  # Эффект!
    return counter  # Результат зависит от внешнего состояния - НЕ ссылочно прозрачно

# Python - ввод-вывод
def greet_user():
    name = input("Введите имя: ")  # Эффект ввода!
    print(f"Привет, {name}!")       # Эффект вывода!
    # Недетерминированно: каждый вызов может дать разный результат
```

```java
// Java - изменяемое состояние
class Counter {
    private int count = 0;

    public int increment() {
        count++;  // Эффект!
        return count;  // НЕ ссылочно прозрачно
    }
}

// Java - ввод-вывод
public static void greetUser() {
    Scanner scanner = new Scanner(System.in);
    System.out.print("Введите имя: ");  // Эффект!
    String name = scanner.nextLine();    // Эффект!
    System.out.println("Привет, " + name + "!");
}
```

```cpp
// C++ - глобальное состояние
int counter = 0;

int increment() {
    counter++;  // Эффект!
    return counter;  // НЕ ссылочно прозрачно
}

// C++ - ввод-вывод
void greet_user() {
    std::cout << "Введите имя: ";  // Эффект!
    std::string name;
    std::cin >> name;              // Эффект!
    std::cout << "Привет, " << name << "!" << std::endl;
}
```

**Практическая демонстрация ссылочной прозрачности:**

```ocaml
(* OCaml *)
let double x = x * 2
let result1 = double 5 + double 5  (* 10 + 10 = 20 *)
let result2 = 10 + 10              (* Можем заменить double 5 на 10 *)
(* result1 = result2 - замена не изменила поведение *)
```

```python
# Python - чистая функция
def square(x):
    return x * x

# Благодаря ссылочной прозрачности:
result1 = square(4) + square(4)  # 16 + 16 = 32
result2 = 16 + 16                # Можем заменить square(4) на 16
assert result1 == result2        # Поведение идентично

# Нечистая функция
import random
def random_int():
    return random.randint(1, 10)

# НЕ ссылочно прозрачно:
result3 = random_int() + random_int()  # Например, 3 + 7 = 10
result4 = 3 + 3                        # НЕЛЬЗЯ заменить вызовы на конкретные значения!
# result3 ≠ result4 - замена изменила поведение
```

### 3. Иммутабельность данных

**Смысл:** Данные не изменяются после создания. Вместо модификации существующих структур создаются новые.

**Зачем это нужно:** Устраняет непреднамеренные эффекты, ликвидирует race conditions.

**Сравнение подходов:**

| Язык           | Иммутабельность по умолчанию | Инструменты                                  |
|----------------|------------------------------|----------------------------------------------|
| **OCaml**      | ✓ Да                         | records, lists                               |
| **F#**         | ✓ Да                         | records, lists (как в OCaml)                 |
| **Clojure**    | ✓✓✓ Да                       | persistent data structures                   |
| **Scala**      | ✓ Коллекции                  | val, case class                              |
| **Ruby**       | ✗ Нет                        | freeze                                       |
| **Rust**       | ✓ Да                         | let (immutable by default)                   |
| **Go**         | ✗ Нет                        | const (только примитивы)                     |
| **JavaScript** | ✗ Нет                        | const (ссылка), Object.freeze                |
| **TypeScript** | ✗ Нет                        | readonly, const, as const                    |
| **Python**     | Частично                     | tuple, frozenset, @dataclass(frozen=True)    |
| **Java**       | Частично                     | final, records (16+), List.of (9+)           |
| **C++**        | ✗ Нет                        | const, constexpr                             |

**Примеры работы с мутабельными/иммутабельными данными:**

**Скалярные переменные:**

```ocaml
(* OCaml - иммутабельность по умолчанию *)
(* Иммутабельное связывание *)
let x = 42
(* x <- 43  (* ОШИБКА: невозможно изменить *) *)

(* Повторное связывание создает новую переменную, скрывая предыдущую *)
let x = x + 1  (* x теперь 43, но старое значение не изменилось *)

(* Мутабельная ссылка требует явного типа ref *)
let counter = ref 0
counter := !counter + 1  (* Явное разыменование и присваивание *)
(* counter теперь содержит 1 *)
```

```fsharp
// F# - иммутабельность по умолчанию
// Иммутабельное связывание
let x = 42
// x <- 43  // ОШИБКА: невозможно изменить

// Повторное связывание создает новую переменную
let x = x + 1  // x теперь 43 в новой области видимости

// Мутабельная переменная требует явного ключевого слова
let mutable counter = 0
counter <- counter + 1  // Явное изменение
// counter теперь 1
```

```clojure
;; Clojure - иммутабельность по умолчанию
;; Иммутабельное связывание
(def x 42)
;; Можно переопределить символ, но не изменить значение
(def x 43)  ;; Новое связывание

;; Мутабельное состояние через атомы
(def counter (atom 0))
(swap! counter inc)  ;; Атомарное изменение
;; @counter теперь 1
```

```scala
// Scala 3 - иммутабельность через val
// Иммутабельное значение
val x = 42
// x = 43  // ОШИБКА: reassignment to val

// Мутабельная переменная требует var
var counter = 0
counter += 1  // Явное изменение
// counter теперь 1

// Shadowing возможен в новой области видимости
val x = x + 1  // ОШИБКА в той же области, OK в вложенной
```

```ruby
# Ruby - мутабельность по умолчанию
# Переменные мутабельны
x = 42
x = 43  # OK - переприсваивание

# Объекты тоже мутабельны
str = "hello"
str << " world"  # OK - мутация строки

# Иммутабельность через freeze
frozen_str = "hello".freeze
# frozen_str << " world"  # ОШИБКА: FrozenError

# Константы (соглашение, не гарантия)
CONSTANT = 42
# CONSTANT = 43  # Предупреждение, но работает!
```

```rust
// Rust - иммутабельность по умолчанию
// Иммутабельное связывание
let x = 42;
// x = 43;  // ОШИБКА: cannot assign twice to immutable variable

// Shadowing - новое связывание с тем же именем
let x = x + 1;  // x теперь 43, новая переменная

// Мутабельная переменная требует mut
let mut counter = 0;
counter += 1;  // Явное изменение
// counter теперь 1
```

```go
// Go - мутабельность по умолчанию
// Переменные мутабельны
var x int = 42
x = 43  // OK

// const только для литералов времени компиляции
const Y = 42
// const не работает для переменных!

// Нет встроенного способа сделать переменную иммутабельной
counter := 0
counter += 1  // OK
```

```javascript
// JavaScript - const для иммутабельных ссылок
// Иммутабельная ссылка
const x = 42;
// x = 43;  // ОШИБКА: Assignment to constant variable

// Shadowing в новой области
{
  const x = 43;  // OK - новая область видимости
}

// Мутабельная переменная через let
let counter = 0;
counter += 1;  // OK
// counter теперь 1

// ВАЖНО: const защищает только ссылку, не содержимое объектов
const obj = { value: 10 };
obj.value = 20;  // OK - мутация содержимого!
```

```typescript
// TypeScript - const для иммутабельных ссылок
// Иммутабельная ссылка
const x = 42;
// x = 43;  // ОШИБКА: Cannot assign to 'x' because it is a constant

// Shadowing в новой области
{
  const x = 43;  // OK - новая область видимости
}

// Мутабельная переменная через let
let counter = 0;
counter += 1;  // OK
// counter теперь 1

// ВАЖНО: const защищает только ссылку, не содержимое объектов
const obj = { value: 10 };
obj.value = 20;  // OK - мутация содержимого!
// Для иммутабельности объектов используйте readonly или Object.freeze
```

```python
# Python - переменные всегда перепривязываемы
# Переменные можно переприсваивать
x = 42
x = 43  # OK

# Нет встроенного способа сделать переменную иммутабельной
# Константы - соглашение (UPPER_CASE)
CONSTANT = 42
CONSTANT = 43  # Никакой ошибки - только соглашение!

# Иммутабельные типы: int, str, tuple, frozenset
# Мутабельные типы: list, dict, set
```

```java
// Java - final для иммутабельных ссылок
// Иммутабельная ссылка
final int x = 42;
// x = 43;  // ОШИБКА: cannot assign a value to final variable

// Мутабельная переменная
int counter = 0;
counter += 1;  // OK
// counter теперь 1

// final защищает только ссылку!
final StringBuilder sb = new StringBuilder("hello");
sb.append(" world");  // OK - мутация содержимого
```

```cpp
// C++ - const для иммутабельных значений
// Иммутабельная переменная
const int x = 42;
// x = 43;  // ОШИБКА: assignment of read-only variable

// Мутабельная переменная
int counter = 0;
counter += 1;  // OK

// constexpr для констант времени компиляции
constexpr int Y = 42;
// constexpr int z = counter;  // ОШИБКА: не константа времени компиляции
```

**Составные структуры данных:**

```ocaml
(* OCaml - иммутабельность по умолчанию *)
(* Иммутабельные записи *)
type person = { name: string; age: int }

let p1 = { name = "Alice"; age = 30 }
let p2 = { p1 with age = 31 }  (* Создается новая запись *)
(* p1 остается неизменным: { name = "Alice"; age = 30 } *)

(* Мутабельные поля требуют явного объявления *)
type counter = { mutable count: int }

let c = { count = 0 }
let () = c.count <- c.count + 1  (* Явное изменение *)
(* c теперь { count = 1 } *)
```

```fsharp
// F# - иммутабельность по умолчанию
// Иммутабельные записи
type Person = { Name: string; Age: int }

let p1 = { Name = "Alice"; Age = 30 }
let p2 = { p1 with Age = 31 }  // Создается новая запись
// p1 остается неизменным

// Мутабельные поля требуют явного объявления
type Counter = { mutable Count: int }

let c = { Count = 0 }
c.Count <- c.Count + 1  // Явное изменение
```

```clojure
;; Clojure - все структуры данных иммутабельны
;; Иммутабельная map
(def person {:name "Alice" :age 30})
(def person2 (assoc person :age 31))  ;; Создается новая структура
;; person остается {:name "Alice" :age 30}

;; Persistent data structures обеспечивают эффективность
;; (structural sharing)

;; Мутабельность через атомы
(def state (atom {:count 0}))
(swap! state update :count inc)
;; @state теперь {:count 1}
```

```scala
// Scala 3 - иммутабельные классы случаев
case class Person(name: String, age: Int)

val p1 = Person("Alice", 30)
val p2 = p1.copy(age = 31)  // Создается новая копия
// p1 остается неизменным

// Мутабельность требует явного объявления
class Counter {
  var count: Int = 0  // var делает поле мутабельным
}

val c = Counter()
c.count += 1  // Явное изменение
```

```ruby
# Ruby - мутабельность по умолчанию
# Мутабельный хеш
person = {name: "Alice", age: 30}
person[:age] = 31  # OK - мутация
# person теперь {name: "Alice", age: 31}

# Иммутабельность через freeze
person2 = {name: "Bob", age: 25}.freeze
# person2[:age] = 26  # ОШИБКА: FrozenError

# Struct для простых структур
Person = Struct.new(:name, :age)
p = Person.new("Alice", 30)
p.age = 31  # OK - мутабельно по умолчанию
```

```rust
// Rust - иммутабельность по умолчанию
// Иммутабельная структура
struct Person {
    name: String,
    age: u32,
}

let p1 = Person { name: "Alice".to_string(), age: 30 };
let p2 = Person { age: 31, ..p1 };  // ОШИБКА: p1 частично перемещен!

// Правильный способ - клонирование
#[derive(Clone)]
struct PersonCloneable {
    name: String,
    age: u32,
}

let p3 = PersonCloneable { name: "Bob".to_string(), age: 25 };
let p4 = PersonCloneable { age: 26, ..p3.clone() };  // OK

// Мутабельность требует явного объявления
let mut counter = 0;
counter += 1;  // OK только с mut
```

```go
// Go - мутабельность по умолчанию
// Структуры мутабельны
type Person struct {
    Name string
    Age  int
}

person := Person{Name: "Alice", Age: 30}
person.Age = 31  // OK - мутация

// Иммутабельность через конвенцию - приватные поля
type ImmutablePerson struct {
    name string  // приватное
    age  int
}

func NewPerson(name string, age int) ImmutablePerson {
    return ImmutablePerson{name: name, age: age}
}

func (p ImmutablePerson) WithAge(age int) ImmutablePerson {
    return ImmutablePerson{name: p.name, age: age}
}
```

```javascript
// JavaScript - мутабельность по умолчанию
// Объекты мутабельны
const person = {name: "Alice", age: 30};
person.age = 31;  // OK - мутация содержимого!

// Object.freeze для поверхностной иммутабельности
const person2 = Object.freeze({name: "Bob", age: 25});
person2.age = 26;  // Не сработает (в strict mode - ошибка)

// Для глубокой иммутабельности нужны библиотеки (Immutable.js, Immer)
```

```typescript
// TypeScript - иммутабельность через readonly
interface Person {
  readonly name: string;
  readonly age: number;
}

const p1: Person = { name: "Alice", age: 30 };
// p1.age = 31;  // ОШИБКА КОМПИЛЯЦИИ: Cannot assign to 'age'

// Создание измененной копии
const p2: Person = { ...p1, age: 31 };

// Мутабельный вариант
interface MutablePerson {
  name: string;
  age: number;
}

const p3: MutablePerson = { name: "Bob", age: 25 };
p3.age = 26;  // OK - поле мутабельно

// as const для глубокой иммутабельности
const config = {
  host: "localhost",
  port: 8080,
  options: { timeout: 5000 }
} as const;
// config.port = 9000;  // ОШИБКА
// config.options.timeout = 3000;  // ОШИБКА
```

```python
# Python - смешанный подход
# Списки мутабельны
numbers = [1, 2, 3]
numbers.append(4)  # OK - мутация

# Кортежи иммутабельны
person = ("Alice", 30)
# person[1] = 31  # ОШИБКА: tuple doesn't support item assignment

# Словари мутабельны
person_dict = {"name": "Alice", "age": 30}
person_dict["age"] = 31  # OK

# Иммутабельные dataclass (Python 3.7+)
from dataclasses import dataclass

@dataclass(frozen=True)
class Person:
    name: str
    age: int

p1 = Person("Alice", 30)
# p1.age = 31  # ОШИБКА: FrozenInstanceError
p2 = Person(p1.name, 31)  # Создание нового экземпляра
```

```java
// Java - мутабельность по умолчанию
// Обычные классы мутабельны
class MutablePerson {
    String name;
    int age;
}

MutablePerson person = new MutablePerson();
person.age = 30;
person.age = 31;  // OK

// Records для иммутабельных данных (Java 16+)
record Person(String name, int age) {}

Person p1 = new Person("Alice", 30);
// p1.age = 31;  // ОШИБКА: нет сеттеров
Person p2 = new Person(p1.name(), 31);  // Создание новой записи

// Collections.unmodifiableList для иммутабельных коллекций
List<Integer> list = List.of(1, 2, 3);  // Java 9+
// list.add(4);  // ОШИБКА: UnsupportedOperationException
```

```cpp
// C++ - мутабельность по умолчанию
// Структуры мутабельны
struct Person {
    std::string name;
    int age;
};

Person person{"Alice", 30};
person.age = 31;  // OK - мутация

// const для иммутабельных объектов
const Person person2{"Bob", 25};
// person2.age = 26;  // ОШИБКА: assignment of member in read-only object

// Иммутабельные методы (const методы)
struct ImmutablePerson {
    std::string name;
    int age;

    ImmutablePerson with_age(int new_age) const {
        return ImmutablePerson{name, new_age};
    }
};

const ImmutablePerson p{"Alice", 30};
auto p2 = p.with_age(31);  // Создается новый объект
```

### 4. Декларативный стиль программирования

**Смысл:** Описание "что требуется" вместо "как это сделать". Код как выражения и трансформации.

**Зачем это нужно:** Читаемость, верифицируемость, компонуемость.

**Примеры (фильтрация и трансформация данных):**

```ocaml
(* OCaml - декларативный стиль через функции высшего порядка *)
let numbers = [1; 2; 3; 4; 5; 6]

(* Императивный стиль - как делать *)
let evens_imperative =
  let result = ref [] in
  List.iter (fun n ->
    if n mod 2 = 0 then
      result := n :: !result
  ) numbers;
  List.rev !result

(* Декларативный стиль - что нужно *)
let evens_declarative = List.filter (fun n -> n mod 2 = 0) numbers
let doubled = List.map (fun n -> n * 2) evens_declarative

(* Композиция: что делаем, а не как *)
let result = numbers
  |> List.filter (fun n -> n mod 2 = 0)
  |> List.map (( * ) 2)
```

```fsharp
// F# - pipeline оператор для декларативности
let numbers = [1; 2; 3; 4; 5; 6]

// Императивный стиль
let mutable evens = []
for n in numbers do
    if n % 2 = 0 then
        evens <- n :: evens
let evensImperative = List.rev evens

// Декларативный стиль
let evensDeclarative =
    numbers
    |> List.filter (fun n -> n % 2 = 0)
    |> List.map (fun n -> n * 2)
```

```clojure
;; Clojure - декларативные трансформации данных
(def numbers [1 2 3 4 5 6])

;; Императивный стиль (нетипично для Clojure)
(loop [nums numbers
       result []]
  (if (empty? nums)
    result
    (let [n (first nums)]
      (recur (rest nums)
             (if (even? n)
               (conj result n)
               result)))))

;; Декларативный стиль (идиоматично)
(->> numbers
     (filter even?)
     (map #(* 2 %)))
```

```scala
// Scala 3 - декларативные коллекции
val numbers = List(1, 2, 3, 4, 5, 6)

// Императивный стиль
var evens = List.empty[Int]
for (n <- numbers) {
  if (n % 2 == 0) {
    evens = evens :+ n
  }
}

// Декларативный стиль
val result = numbers
  .filter(_ % 2 == 0)
  .map(_ * 2)
```

```ruby
# Ruby - декларативные методы Enumerable
numbers = [1, 2, 3, 4, 5, 6]

# Императивный стиль
evens = []
numbers.each do |n|
  evens << n if n.even?
end

# Декларативный стиль
result = numbers
  .select(&:even?)
  .map { |n| n * 2 }
```

```rust
// Rust - итераторы и ленивые вычисления
let numbers = vec![1, 2, 3, 4, 5, 6];

// Императивный стиль
let mut evens = Vec::new();
for n in &numbers {
    if n % 2 == 0 {
        evens.push(*n);
    }
}

// Декларативный стиль
let result: Vec<i32> = numbers
    .iter()
    .filter(|n| *n % 2 == 0)
    .map(|n| n * 2)
    .collect();
```

```go
// Go - императивный стиль преобладает
numbers := []int{1, 2, 3, 4, 5, 6}

// Императивный стиль (идиоматично для Go)
var evens []int
for _, n := range numbers {
    if n%2 == 0 {
        evens = append(evens, n)
    }
}

var result []int
for _, n := range evens {
    result = append(result, n*2)
}

// Декларативный стиль возможен через сторонние библиотеки
// но не идиоматичен для Go
```

```javascript
// JavaScript - декларативные методы массивов
const numbers = [1, 2, 3, 4, 5, 6];

// Императивный стиль
const evens = [];
for (let i = 0; i < numbers.length; i++) {
    if (numbers[i] % 2 === 0) {
        evens.push(numbers[i]);
    }
}

// Декларативный стиль
const result = numbers
    .filter(n => n % 2 === 0)
    .map(n => n * 2);
```

```typescript
// TypeScript - типобезопасный декларативный стиль
const numbers: number[] = [1, 2, 3, 4, 5, 6];

// Императивный стиль
const evens: number[] = [];
for (const n of numbers) {
    if (n % 2 === 0) {
        evens.push(n);
    }
}

// Декларативный стиль
const result: number[] = numbers
    .filter((n): n is number => n % 2 === 0)
    .map(n => n * 2);
```

```python
# Python - декларативные конструкции
numbers = [1, 2, 3, 4, 5, 6]

# Императивный стиль
evens = []
for num in numbers:
    if num % 2 == 0:
        evens.append(num)

# Декларативный стиль - list comprehension
result = [n * 2 for n in numbers if n % 2 == 0]

# Декларативный стиль - функциональный подход
from functools import reduce
result = list(map(lambda n: n * 2, filter(lambda n: n % 2 == 0, numbers)))
```

```java
// Java - Stream API для декларативности
List<Integer> numbers = List.of(1, 2, 3, 4, 5, 6);

// Императивный стиль
List<Integer> evens = new ArrayList<>();
for (Integer n : numbers) {
    if (n % 2 == 0) {
        evens.add(n);
    }
}

// Декларативный стиль (Java 8+)
List<Integer> result = numbers.stream()
    .filter(n -> n % 2 == 0)
    .map(n -> n * 2)
    .collect(Collectors.toList());
```

```cpp
// C++ - ranges для декларативности (C++20)
#include <vector>
#include <ranges>
#include <algorithm>

std::vector<int> numbers = {1, 2, 3, 4, 5, 6};

// Императивный стиль
std::vector<int> evens;
for (int n : numbers) {
    if (n % 2 == 0) {
        evens.push_back(n);
    }
}

// Декларативный стиль (C++20 ranges)
auto result = numbers
    | std::views::filter([](int n) { return n % 2 == 0; })
    | std::views::transform([](int n) { return n * 2; });
std::vector<int> result_vec(result.begin(), result.end());
```

### 5. Выражения вместо инструкций

**Смысл:** Всё вычисляется в значение. Нет инструкций без возвращаемого значения.

**Выражение (expression):** Конструкция кода, которая вычисляется и возвращает значение. Примеры: `2 + 3` возвращает `5`, `if x > 0 then "positive" else "non-positive"` возвращает строку.

**Инструкция (statement):** Конструкция кода, которая выполняет действие, но не возвращает значение. Примеры: `print("hello")`, присваивание `x = 5`, циклы `while`, `for`. Инструкции используются ради эффектов.

**Ключевое отличие:** Выражения можно вкладывать друг в друга и использовать как части других выражений, потому что они всегда возвращают значение. Инструкции нельзя использовать там, где ожидается значение.

**Зачем это нужно:** Единообразие, компонуемость, упрощенное рассуждение о коде.

**Примеры:**

| Язык           | if-else        | match/switch  | try-catch               |
|----------------|----------------|---------------|-------------------------|
| **OCaml**      | ✓ Выражение    | ✓             | ✓                       |
| **F#**         | ✓ Выражение    | ✓             | ✓                       |
| **Clojure**    | ✓ Выражение    | ✗             | ✓ Выражение             |
| **Scala**      | ✓ Выражение    | ✓             | ✓                       |
| **Ruby**       | ✓ Выражение    | ✓             | ✓                       |
| **Rust**       | ✓ Выражение    | ✓             | ✓ (Result)              |
| **Go**         | ✗              | ✗             | ✗ (нет исключений)      |
| **JavaScript** | Тернарный      | ✗             | ✗                       |
| **TypeScript** | Тернарный      | ✗             | ✗                       |
| **Python**     | Тернарный      | match (3.10+) | ✗                       |
| **Java**       | Тернарный      | ✓ (14+)       | Частично                |
| **C++**        | Тернарный      | ✗             | ✗                       |

**Примеры if-else как выражений:**

```ocaml
(* OCaml - if как выражение *)
let status x =
  let message = if x > 0 then "positive" else "non-positive" in
  message

(* Вложенные выражения *)
let category n =
  if n < 0 then "negative"
  else if n = 0 then "zero"
  else "positive"

(* Можно использовать в любом контексте *)
let result = (if x > 0 then x else -x) + 10
```

```fsharp
// F# - if как выражение
let status x =
    let message = if x > 0 then "positive" else "non-positive"
    message

// Прямое использование в вычислениях
let absoluteValue x = if x < 0 then -x else x

// В любом выражении
let result = (if x > 0 then x else -x) + 10
```

```clojure
;; Clojure - if как выражение
(defn status [x]
  (let [message (if (> x 0) "positive" "non-positive")]
    message))

;; cond для множественных условий
(defn category [n]
  (cond
    (< n 0) "negative"
    (= n 0) "zero"
    :else "positive"))

;; Используется как часть выражения
(def result (+ (if (> x 0) x (- x)) 10))
```

```scala
// Scala 3 - if как выражение
def status(x: Int): String =
  val message = if x > 0 then "positive" else "non-positive"
  message

// Прямое возвращение
def absoluteValue(x: Int): Int = if x < 0 then -x else x

// В составе выражений
val result = (if x > 0 then x else -x) + 10
```

```ruby
# Ruby - if как выражение
def status(x)
  message = if x > 0 then "positive" else "non-positive" end
  message
end

# Постфиксная форма
def absolute_value(x)
  x < 0 ? -x : x
end

# Всё возвращает значение
result = (x > 0 ? x : -x) + 10
```

```rust
// Rust - if как выражение (без точки с запятой)
fn status(x: i32) -> String {
    let message = if x > 0 { "positive" } else { "non-positive" };
    message.to_string()
}

// Прямое возвращение (последнее выражение без ;)
fn absolute_value(x: i32) -> i32 {
    if x < 0 { -x } else { x }
}

// В составе выражений
let result = (if x > 0 { x } else { -x }) + 10;
```

```go
// Go - if как инструкция, не выражение
func status(x int) string {
    var message string
    if x > 0 {
        message = "positive"
    } else {
        message = "non-positive"
    }
    return message
}

// Нельзя использовать в выражениях
// result := (if x > 0 { x } else { -x }) + 10  // ОШИБКА!

// Приходится использовать функции или переменные
func absoluteValue(x int) int {
    if x < 0 {
        return -x
    }
    return x
}
```

```javascript
// JavaScript - только тернарный оператор
function status(x) {
    const message = x > 0 ? "positive" : "non-positive";
    return message;
}

// if-else как инструкция
function category(n) {
    if (n < 0) return "negative";
    if (n === 0) return "zero";
    return "positive";
}

// Тернарный в выражениях
const result = (x > 0 ? x : -x) + 10;
```

```typescript
// TypeScript - только тернарный оператор
function status(x: number): string {
    const message = x > 0 ? "positive" : "non-positive";
    return message;
}

// if-else как инструкция
function category(n: number): string {
    if (n < 0) return "negative";
    if (n === 0) return "zero";
    return "positive";
}

// Тернарный в выражениях
const result = (x > 0 ? x : -x) + 10;
```

```python
# Python - тернарный оператор
def status(x):
    message = "positive" if x > 0 else "non-positive"
    return message

# if-elif-else как инструкция
def category(n):
    if n < 0:
        return "negative"
    elif n == 0:
        return "zero"
    else:
        return "positive"

# Тернарный в выражениях
result = (x if x > 0 else -x) + 10
```

```java
// Java - тернарный оператор
public static String status(int x) {
    String message = x > 0 ? "positive" : "non-positive";
    return message;
}

// if-else как инструкция
public static String category(int n) {
    if (n < 0) {
        return "negative";
    } else if (n == 0) {
        return "zero";
    } else {
        return "positive";
    }
}

// switch expression (Java 14+)
public static String categorySwitch(int n) {
    return switch (Integer.signum(n)) {
        case -1 -> "negative";
        case 0 -> "zero";
        case 1 -> "positive";
        default -> throw new IllegalStateException();
    };
}
```

```cpp
// C++ - тернарный оператор
auto status(int x) -> std::string {
    auto message = x > 0 ? "positive" : "non-positive";
    return message;
}

// if-else как инструкция
auto category(int n) -> std::string {
    if (n < 0) {
        return "negative";
    } else if (n == 0) {
        return "zero";
    } else {
        return "positive";
    }
}

// if constexpr как выражение (время компиляции)
template<int N>
constexpr auto sign() {
    if constexpr (N < 0) return "negative";
    else if constexpr (N == 0) return "zero";
    else return "positive";
}
```

---

## Часть II: Вспомогательные свойства

### 1. Композиция функций

**Как помогает:** Маленькие функции комбинируются для создания сложной функциональности: `(f ∘ g)(x) = f(g(x))`.

**Каррирование (currying):** Преобразование функции от нескольких аргументов в последовательность функций, каждая из которых принимает один аргумент. Например, функция `add(x, y)` преобразуется в `add(x)(y)`. Это позволяет легко создавать частично применённые функции (partial application) — фиксировать некоторые аргументы и получать новую функцию от оставшихся аргументов.

**Поддержка:**

| Язык           | Каррирование          | Pipeline                           | Идиоматичность |
|----------------|----------------------|------------------------------------|----------------|
| **OCaml**      | Автоматическое       | `\|>`, `@@`                        | ✓✓✓            |
| **F#**         | Автоматическое       | `\|>`, `>>`                        | ✓✓✓            |
| **Clojure**    | `partial`            | `comp`, `->`, `->>`                | ✓✓✓            |
| **Scala**      | `.curried`           | `andThen`, `compose`               | ✓✓✓            |
| **Ruby**       | Ручное               | `>>`, `<<`                         | ✓✓             |
| **Rust**       | Ручное               | `map`, `and_then`                  | ✓✓             |
| **Go**         | ✗                    | ✗                                  | ✗              |
| **JavaScript** | Ручное               | Библиотеки (Ramda, lodash/fp)      | ✓              |
| **TypeScript** | Ручное               | Библиотеки (fp-ts)                 | ✓✓             |
| **Python**     | `functools.partial`  | Библиотеки                         | ✓              |
| **Java**       | Ручное               | `andThen`, `compose`               | ✓✓             |
| **C++**        | `std::bind`          | Ranges (C++20)                     | ✓              |

**Примеры:**

```ocaml
(* OCaml - автоматическое каррирование и композиция *)

(* Простые функции *)
let add x y = x + y
let multiply x y = x * y
let square x = x * x

(* Частичное применение благодаря автоматическому каррированию *)
let add5 = add 5
let double = multiply 2

(* Композиция функций вручную *)
let compose f g x = f (g x)
let add5_then_double = compose double add5

(* Pipeline оператор |> *)
let result = 10
  |> add 5
  |> multiply 2
  |> square
(* Результат: ((10 + 5) * 2)^2 = 900 *)

(* Обработка списка через pipeline *)
let numbers = [1; 2; 3; 4; 5; 6]

let process_numbers nums =
  nums
  |> List.filter (fun n -> n mod 2 = 0)
  |> List.map (multiply 3)
  |> List.fold_left (+) 0

(* Reverse pipeline @@ *)
let result2 = square @@ double @@ add5 10
```

```fsharp
// F# - автоматическое каррирование и мощные операторы

// Простые функции
let add x y = x + y
let multiply x y = x * y
let square x = x * x

// Частичное применение
let add5 = add 5
let double = multiply 2

// Композиция через оператор >>
let add5ThenDouble = add5 >> double
let doubleThenSquare = double >> square

// Pipeline |>
let result = 10
    |> add 5
    |> multiply 2
    |> square

// Обработка коллекций
let numbers = [1; 2; 3; 4; 5; 6]

let processNumbers =
    numbers
    |> List.filter (fun n -> n % 2 = 0)
    |> List.map ((*) 3)
    |> List.sum

// Композиция функций высшего порядка
let pipeline =
    List.filter (fun n -> n % 2 = 0)
    >> List.map ((*) 3)
    >> List.sum
```

```clojure
;; Clojure - композиция через comp и threading macros

;; Простые функции
(defn add [x y] (+ x y))
(defn multiply [x y] (* x y))
(defn square [x] (* x x))

;; Частичное применение через partial
(def add5 (partial add 5))
(def double (partial multiply 2))

;; Композиция через comp (справа налево)
(def add5-then-double (comp double add5))

;; Threading macro -> (слева направо)
(-> 10
    (add 5)
    (multiply 2)
    square)
;; Результат: 900

;; Thread-last ->> для коллекций
(def numbers [1 2 3 4 5 6])

(->> numbers
     (filter even?)
     (map (partial * 3))
     (reduce +))
;; Результат: 36

;; as-> для сложных цепочек
(as-> 10 x
  (add 5 x)
  (multiply 2 x)
  (square x))
```

```scala
// Scala 3 - композиция и методы

// Простые функции
def add(x: Int, y: Int): Int = x + y
def multiply(x: Int, y: Int): Int = x * y
def square(x: Int): Int = x * x

// Каррирование вручную
val addCurried: Int => Int => Int = x => y => x + y
val add5 = addCurried(5)
val double = multiply(2, _: Int)

// Композиция через andThen и compose
val add5ThenDouble = add5.andThen(multiply(2, _))
val squareThenDouble = square.andThen(multiply(2, _))

// Extension методы для pipeline (Scala 3)
extension [A](x: A)
  infix def |>(f: A => A): A = f(x)

val result = 10
  |> (add(5, _))
  |> (multiply(2, _))
  |> square

// Обработка коллекций
val numbers = List(1, 2, 3, 4, 5, 6)

val processNumbers = numbers
  .filter(_ % 2 == 0)
  .map(_ * 3)
  .sum

// Композиция через Function1
val pipeline = ((x: List[Int]) => x.filter(_ % 2 == 0))
  .andThen(_.map(_ * 3))
  .andThen(_.sum)
```

```ruby
# Ruby - ручное каррирование и композиция

# Простые функции через lambda
add = ->(x, y) { x + y }
multiply = ->(x, y) { x * y }
square = ->(x) { x * x }

# Каррирование через curry
add_curried = add.curry
add5 = add_curried[5]
double = multiply.curry[2]

# Композиция через >> и <<
add5_then_double = add5 >> double
double_then_square = double >> square

result = add5_then_double[10]  # (10 + 5) * 2 = 30

# Композиция вручную
compose = ->(f, g) { ->(x) { f[g[x]] } }
add5_then_square = compose[square, add5]

# Обработка коллекций через chain
numbers = [1, 2, 3, 4, 5, 6]

result = numbers
  .select(&:even?)
  .map { |n| n * 3 }
  .sum

# Функциональный pipeline через then (Ruby 2.6+)
result = 10
  .then { |x| add5[x] }
  .then { |x| double[x] }
  .then { |x| square[x] }
```

```rust
// Rust - композиция через типажи и замыкания

// Простые функции
fn add(x: i32, y: i32) -> i32 { x + y }
fn multiply(x: i32, y: i32) -> i32 { x * y }
fn square(x: i32) -> i32 { x * x }

// Частичное применение через замыкания
let add5 = |x| add(x, 5);
let double = |x| multiply(x, 2);

// Композиция вручную
fn compose<A, B, C, F, G>(f: F, g: G) -> impl Fn(A) -> C
where
    F: Fn(B) -> C,
    G: Fn(A) -> B,
{
    move |x| f(g(x))
}

let add5_then_double = compose(double, add5);

// Методы цепочки для итераторов
let numbers = vec![1, 2, 3, 4, 5, 6];

let result: i32 = numbers
    .iter()
    .filter(|&&n| n % 2 == 0)
    .map(|&n| n * 3)
    .sum();

// Pipeline через map и and_then для Result/Option
use std::num::ParseIntError;

fn process_string(s: &str) -> Result<i32, ParseIntError> {
    s.parse::<i32>()
        .map(|x| add(x, 5))
        .map(|x| multiply(x, 2))
        .map(square)
}
```

```go
// Go - ограниченная поддержка композиции

import "fmt"

// Простые функции
func add(x, y int) int { return x + y }
func multiply(x, y int) int { return x * y }
func square(x int) int { return x * x }

// Частичное применение через замыкания
func makeAdder(y int) func(int) int {
    return func(x int) int {
        return add(x, y)
    }
}

add5 := makeAdder(5)
double := func(x int) int { return multiply(x, 2) }

// Композиция функций вручную
func compose(f, g func(int) int) func(int) int {
    return func(x int) int {
        return f(g(x))
    }
}

add5ThenDouble := compose(double, add5)
result := add5ThenDouble(10)  // 30

// Обработка слайсов (нет встроенного map/filter)
numbers := []int{1, 2, 3, 4, 5, 6}

// Фильтр
var evens []int
for _, n := range numbers {
    if n%2 == 0 {
        evens = append(evens, n)
    }
}

// Map
var tripled []int
for _, n := range evens {
    tripled = append(tripled, n*3)
}

// Sum
sum := 0
for _, n := range tripled {
    sum += n
}
```

```javascript
// JavaScript - композиция через функции высшего порядка

// Простые функции
const add = (x, y) => x + y;
const multiply = (x, y) => x * y;
const square = x => x * x;

// Ручное каррирование
const curry = f => x => y => f(x, y);
const addCurried = curry(add);
const add5 = addCurried(5);
const double = curry(multiply)(2);

// Композиция вручную (справа налево)
const compose = (...fns) => x =>
  fns.reduceRight((acc, fn) => fn(acc), x);

// Pipe (слева направо)
const pipe = (...fns) => x =>
  fns.reduce((acc, fn) => fn(acc), x);

const add5ThenDouble = pipe(add5, double);
const result = add5ThenDouble(10);  // 30

// Обработка массивов
const numbers = [1, 2, 3, 4, 5, 6];

const processNumbers = pipe(
  nums => nums.filter(n => n % 2 === 0),
  nums => nums.map(n => n * 3),
  nums => nums.reduce((a, b) => a + b, 0)
);

const result2 = processNumbers(numbers);

// Метод-цепочка
const result3 = numbers
  .filter(n => n % 2 === 0)
  .map(n => n * 3)
  .reduce((a, b) => a + b, 0);
```

```typescript
// TypeScript - типизированная композиция

// Простые функции
const add = (x: number, y: number): number => x + y;
const multiply = (x: number, y: number): number => x * y;
const square = (x: number): number => x * x;

// Типизированное каррирование
const curry = <A, B, C>(f: (a: A, b: B) => C) =>
  (a: A) => (b: B): C => f(a, b);

const addCurried = curry(add);
const add5 = addCurried(5);
const double = curry(multiply)(2);

// Типизированная композиция
type Fn<A, B> = (a: A) => B;

const compose = <A, B, C>(
  f: Fn<B, C>,
  g: Fn<A, B>
): Fn<A, C> => x => f(g(x));

const pipe = <A, B, C>(
  f: Fn<A, B>,
  g: Fn<B, C>
): Fn<A, C> => x => g(f(x));

const add5ThenDouble = pipe(add5, double);

// Обработка массивов
const numbers: number[] = [1, 2, 3, 4, 5, 6];

const processNumbers = (nums: number[]): number =>
  nums
    .filter(n => n % 2 === 0)
    .map(n => n * 3)
    .reduce((a, b) => a + b, 0);

// fp-ts для продвинутой композиции
import { pipe as fpPipe } from 'fp-ts/function';
import * as A from 'fp-ts/Array';

const result = fpPipe(
  numbers,
  A.filter((n: number) => n % 2 === 0),
  A.map((n: number) => n * 3),
  A.reduce(0, (a, b) => a + b)
);
```

```python
# Python - композиция через functools

from functools import partial, reduce

# Простые функции
def add(x, y):
    return x + y

def multiply(x, y):
    return x * y

def square(x):
    return x * x

# Частичное применение
add5 = partial(add, 5)
double = partial(multiply, 2)

# Композиция вручную
def compose(*fns):
    def inner(x):
        return reduce(lambda acc, f: f(acc), reversed(fns), x)
    return inner

def pipe(*fns):
    def inner(x):
        return reduce(lambda acc, f: f(acc), fns, x)
    return inner

add5_then_double = pipe(add5, double)
result = add5_then_double(10)  # 30

# Обработка списков
numbers = [1, 2, 3, 4, 5, 6]

# Традиционный способ
result = sum(
    map(lambda n: n * 3,
        filter(lambda n: n % 2 == 0, numbers))
)

# Через comprehension
result2 = sum(n * 3 for n in numbers if n % 2 == 0)

# Через toolz для функциональной композиции
from toolz import pipe as tz_pipe, curry

process_numbers = tz_pipe(
    numbers,
    curry(filter)(lambda n: n % 2 == 0),
    curry(map)(lambda n: n * 3),
    sum
)
```

```java
// Java - композиция через Function interface

import java.util.function.*;
import java.util.List;
import java.util.stream.Collectors;

// Простые функции
Function<Integer, Function<Integer, Integer>> add =
    x -> y -> x + y;

Function<Integer, Function<Integer, Integer>> multiply =
    x -> y -> x * y;

Function<Integer, Integer> square = x -> x * x;

// Частичное применение
Function<Integer, Integer> add5 = add.apply(5);
Function<Integer, Integer> doubleF = multiply.apply(2);

// Композиция через compose и andThen
Function<Integer, Integer> add5ThenDouble =
    add5.andThen(doubleF);

Function<Integer, Integer> doubleThenSquare =
    doubleF.andThen(square);

int result = add5ThenDouble.apply(10);  // 30

// Обработка коллекций через Stream API
List<Integer> numbers = List.of(1, 2, 3, 4, 5, 6);

int processedSum = numbers.stream()
    .filter(n -> n % 2 == 0)
    .map(n -> n * 3)
    .reduce(0, Integer::sum);

// Композиция через reduce
Function<Integer, Integer> pipeline =
    List.of(add5, doubleF, square)
        .stream()
        .reduce(Function.identity(),
                Function::andThen);
```

```cpp
// C++20 - композиция через ranges и lambda

#include <functional>
#include <ranges>
#include <numeric>
#include <vector>

namespace views = std::ranges::views;

// Простые функции
auto add = [](int x, int y) { return x + y; };
auto multiply = [](int x, int y) { return x * y; };
auto square = [](int x) { return x * x; };

// Частичное применение через bind
auto add5 = [add](int x) { return add(x, 5); };
auto doubleF = [multiply](int x) { return multiply(x, 2); };

// Композиция вручную
template<typename F, typename G>
auto compose(F f, G g) {
    return [=](auto x) { return f(g(x)); };
}

auto add5_then_double = compose(doubleF, add5);
int result = add5_then_double(10);  // 30

// Обработка коллекций через ranges
std::vector<int> numbers = {1, 2, 3, 4, 5, 6};

auto processed = numbers
    | views::filter([](int n) { return n % 2 == 0; })
    | views::transform([](int n) { return n * 3; });

int sum = std::accumulate(
    processed.begin(),
    processed.end(),
    0
);

// Цепочка композиций
auto pipeline = compose(
    square,
    compose(doubleF, add5)
);
```

### 2. Рекурсия вместо итерации

**Как помогает:** Повторяющиеся вычисления без изменяемых счетчиков циклов. Хвостовая рекурсия (TCO) оптимизируется в итерацию.

**Поддержка TCO:**

| Язык           | TCO                     | Примечания                         |
|----------------|-------------------------|------------------------------------|
| **OCaml**      | ✓ Гарантирована         | Рекурсия идиоматична               |
| **F#**         | ✓ Гарантирована         | Рекурсия идиоматична               |
| **Clojure**    | ✓ `recur`               | Хвостовая рекурсия через `recur`   |
| **Scala**      | ✓ Саморекурсия          | Аннотация `@tailrec`               |
| **Ruby**       | ✗                       | Риск stack overflow                |
| **Rust**       | ✓ LLVM                  | Оптимизируется компилятором        |
| **Go**         | ✗                       | Используйте итерацию               |
| **JavaScript** | ✗                       | Не гарантируется                   |
| **TypeScript** | ✗                       | Не гарантируется                   |
| **Python**     | ✗                       | Явное решение Guido                |
| **Java**       | ✗                       | Используйте итерацию               |
| **C++**        | Зависит от компилятора  | С `-O2`/`-O3`                      |

**Примеры:**

```ocaml
(* OCaml - рекурсия как идиоматичный подход *)

(* Простая рекурсия: факториал *)
let rec factorial n =
  if n <= 1 then 1
  else n * factorial (n - 1)

(* Хвостовая рекурсия с аккумулятором *)
let factorial_tail n =
  let rec loop acc n =
    if n <= 1 then acc
    else loop (acc * n) (n - 1)
  in
  loop 1 n

(* Рекурсия по списку: сумма *)
let rec sum = function
  | [] -> 0
  | x :: xs -> x + sum xs

(* Хвостовая рекурсия для списка *)
let sum_tail lst =
  let rec loop acc = function
    | [] -> acc
    | x :: xs -> loop (acc + x) xs
  in
  loop 0 lst

(* Взаимная рекурсия *)
let rec is_even n =
  if n = 0 then true
  else is_odd (n - 1)
and is_odd n =
  if n = 0 then false
  else is_even (n - 1)
```

```fsharp
// F# - рекурсия с гарантированной TCO

// Простая рекурсия
let rec factorial n =
    if n <= 1 then 1
    else n * factorial (n - 1)

// Хвостовая рекурсия
let factorialTail n =
    let rec loop acc n =
        if n <= 1 then acc
        else loop (acc * n) (n - 1)
    loop 1 n

// Рекурсия по списку
let rec sum lst =
    match lst with
    | [] -> 0
    | x :: xs -> x + sum xs

// Хвостовая рекурсия со сверткой
let sumTail lst =
    let rec loop acc lst =
        match lst with
        | [] -> acc
        | x :: xs -> loop (acc + x) xs
    loop 0 lst

// Map через рекурсию
let rec map f lst =
    match lst with
    | [] -> []
    | x :: xs -> f x :: map f xs

// Числа Фибоначчи (хвостовая рекурсия)
let fibonacci n =
    let rec fib a b count =
        if count = 0 then a
        else fib b (a + b) (count - 1)
    fib 0 1 n
```

```clojure
;; Clojure - явная хвостовая рекурсия через recur

;; Простая рекурсия (без TCO)
(defn factorial [n]
  (if (<= n 1)
    1
    (* n (factorial (dec n)))))

;; Хвостовая рекурсия через recur
(defn factorial-tail [n]
  (loop [acc 1, n n]
    (if (<= n 1)
      acc
      (recur (* acc n) (dec n)))))

;; Рекурсия по последовательности
(defn sum [lst]
  (if (empty? lst)
    0
    (+ (first lst) (sum (rest lst)))))

;; Хвостовая рекурсия для последовательности
(defn sum-tail [lst]
  (loop [acc 0, lst lst]
    (if (empty? lst)
      acc
      (recur (+ acc (first lst)) (rest lst)))))

;; Map через рекурсию
(defn my-map [f coll]
  (if (empty? coll)
    '()
    (cons (f (first coll))
          (my-map f (rest coll)))))

;; Числа Фибоначчи
(defn fibonacci [n]
  (loop [a 0, b 1, count n]
    (if (zero? count)
      a
      (recur b (+ a b) (dec count)))))
```

```scala
// Scala - TCO для саморекурсии с @tailrec

import scala.annotation.tailrec

// Простая рекурсия
def factorial(n: Int): Int =
  if n <= 1 then 1
  else n * factorial(n - 1)

// Хвостовая рекурсия с проверкой компилятором
@tailrec
def factorialTail(n: Int, acc: Int = 1): Int =
  if n <= 1 then acc
  else factorialTail(n - 1, acc * n)

// Рекурсия по списку
def sum(lst: List[Int]): Int = lst match
  case Nil => 0
  case x :: xs => x + sum(xs)

// Хвостовая рекурсия для списка
@tailrec
def sumTail(lst: List[Int], acc: Int = 0): Int = lst match
  case Nil => acc
  case x :: xs => sumTail(xs, acc + x)

// Map через рекурсию
def map[A, B](lst: List[A], f: A => B): List[B] = lst match
  case Nil => Nil
  case x :: xs => f(x) :: map(xs, f)

// Числа Фибоначчи
@tailrec
def fibonacci(n: Int, a: Long = 0, b: Long = 1): Long =
  if n == 0 then a
  else fibonacci(n - 1, b, a + b)
```

```ruby
# Ruby - нет TCO, рискованно для больших данных

# Простая рекурсия (осторожно: stack overflow!)
def factorial(n)
  return 1 if n <= 1
  n * factorial(n - 1)
end

# "Хвостовая" рекурсия (но без оптимизации)
def factorial_tail(n, acc = 1)
  return acc if n <= 1
  factorial_tail(n - 1, acc * n)
end

# Рекурсия по массиву
def sum(arr)
  return 0 if arr.empty?
  arr.first + sum(arr[1..])
end

# С аккумулятором
def sum_tail(arr, acc = 0)
  return acc if arr.empty?
  sum_tail(arr[1..], acc + arr.first)
end

# Итеративный подход предпочтительнее
def factorial_iter(n)
  (1..n).reduce(1, :*)
end

# Числа Фибоначчи итеративно
def fibonacci(n)
  return n if n <= 1
  a, b = 0, 1
  n.times { a, b = b, a + b }
  a
end
```

```rust
// Rust - TCO оптимизируется LLVM (с флагами оптимизации)

// Простая рекурсия
fn factorial(n: u64) -> u64 {
    if n <= 1 {
        1
    } else {
        n * factorial(n - 1)
    }
}

// Хвостовая рекурсия (оптимизируется в цикл)
fn factorial_tail(n: u64) -> u64 {
    fn loop_fn(acc: u64, n: u64) -> u64 {
        if n <= 1 {
            acc
        } else {
            loop_fn(acc * n, n - 1)
        }
    }
    loop_fn(1, n)
}

// Рекурсия по слайсу
fn sum(arr: &[i32]) -> i32 {
    match arr {
        [] => 0,
        [x, rest @ ..] => x + sum(rest),
    }
}

// Хвостовая рекурсия для слайса
fn sum_tail(arr: &[i32]) -> i32 {
    fn loop_fn(acc: i32, arr: &[i32]) -> i32 {
        match arr {
            [] => acc,
            [x, rest @ ..] => loop_fn(acc + x, rest),
        }
    }
    loop_fn(0, arr)
}

// Идиоматичный подход через итератор
fn factorial_iter(n: u64) -> u64 {
    (1..=n).product()
}

// Числа Фибоначчи
fn fibonacci(n: u32) -> u64 {
    fn fib_tail(a: u64, b: u64, count: u32) -> u64 {
        if count == 0 { a }
        else { fib_tail(b, a + b, count - 1) }
    }
    fib_tail(0, 1, n)
}
```

```go
// Go - нет TCO, используйте циклы

import "fmt"

// Простая рекурсия (риск stack overflow)
func factorial(n int) int {
    if n <= 1 {
        return 1
    }
    return n * factorial(n-1)
}

// Итеративный подход (рекомендуется)
func factorialIter(n int) int {
    result := 1
    for i := 2; i <= n; i++ {
        result *= i
    }
    return result
}

// Рекурсия по слайсу
func sum(arr []int) int {
    if len(arr) == 0 {
        return 0
    }
    return arr[0] + sum(arr[1:])
}

// Итеративная сумма
func sumIter(arr []int) int {
    result := 0
    for _, v := range arr {
        result += v
    }
    return result
}

// Числа Фибоначчи итеративно
func fibonacci(n int) int {
    if n <= 1 {
        return n
    }
    a, b := 0, 1
    for i := 2; i <= n; i++ {
        a, b = b, a+b
    }
    return b
}
```

```javascript
// JavaScript - нет TCO (кроме Safari), используйте циклы

// Простая рекурсия
function factorial(n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

// "Хвостовая" рекурсия (не оптимизируется в большинстве движков)
function factorialTail(n, acc = 1) {
  if (n <= 1) return acc;
  return factorialTail(n - 1, acc * n);
}

// Рекурсия по массиву
function sum(arr) {
  if (arr.length === 0) return 0;
  return arr[0] + sum(arr.slice(1));
}

// Итеративный подход (предпочтительнее)
function factorialIter(n) {
  let result = 1;
  for (let i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

// Reduce вместо рекурсии
function sumReduce(arr) {
  return arr.reduce((acc, x) => acc + x, 0);
}

// Числа Фибоначчи
function fibonacci(n) {
  if (n <= 1) return n;
  let [a, b] = [0, 1];
  for (let i = 2; i <= n; i++) {
    [a, b] = [b, a + b];
  }
  return b;
}
```

```typescript
// TypeScript - нет TCO, используйте циклы

// Простая рекурсия
function factorial(n: number): number {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

// "Хвостовая" рекурсия
function factorialTail(n: number, acc: number = 1): number {
  if (n <= 1) return acc;
  return factorialTail(n - 1, acc * n);
}

// Рекурсия по массиву
function sum(arr: number[]): number {
  if (arr.length === 0) return 0;
  const [first, ...rest] = arr;
  return first + sum(rest);
}

// Обобщенная рекурсивная функция
function recursiveReduce<T, R>(
  arr: T[],
  fn: (acc: R, val: T) => R,
  init: R
): R {
  if (arr.length === 0) return init;
  const [first, ...rest] = arr;
  return recursiveReduce(rest, fn, fn(init, first));
}

// Итеративный подход (рекомендуется)
function factorialIter(n: number): number {
  return Array.from({ length: n }, (_, i) => i + 1)
    .reduce((acc, x) => acc * x, 1);
}

// Числа Фибоначчи
function fibonacci(n: number): number {
  if (n <= 1) return n;
  let [a, b] = [0, 1];
  for (let i = 2; i <= n; i++) {
    [a, b] = [b, a + b];
  }
  return b;
}
```

```python
# Python - нет TCO по философским соображениям

# Простая рекурсия (ограничение глубины ~1000)
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n - 1)

# "Хвостовая" рекурсия (не оптимизируется)
def factorial_tail(n, acc=1):
    if n <= 1:
        return acc
    return factorial_tail(n - 1, acc * n)

# Рекурсия по списку
def sum_recursive(lst):
    if not lst:
        return 0
    return lst[0] + sum_recursive(lst[1:])

# Итеративный подход (идиоматично)
def factorial_iter(n):
    from functools import reduce
    from operator import mul
    return reduce(mul, range(1, n + 1), 1)

# Sum встроенная функция
def sum_iter(lst):
    return sum(lst)

# Числа Фибоначчи итеративно
def fibonacci(n):
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

# Trampolining для обхода ограничения рекурсии
def trampoline(fn):
    def trampolined(*args, **kwargs):
        result = fn(*args, **kwargs)
        while callable(result):
            result = result()
        return result
    return trampolined
```

```java
// Java - нет TCO, используйте циклы

// Простая рекурсия
public static int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

// Итеративный подход (рекомендуется)
public static int factorialIter(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

// Рекурсия по списку
public static int sum(List<Integer> list) {
    if (list.isEmpty()) return 0;
    return list.get(0) + sum(list.subList(1, list.size()));
}

// Stream API вместо явной рекурсии
public static int factorialStream(int n) {
    return IntStream.rangeClosed(1, n)
        .reduce(1, (a, b) -> a * b);
}

public static int sumStream(List<Integer> list) {
    return list.stream()
        .mapToInt(Integer::intValue)
        .sum();
}

// Числа Фибоначчи
public static long fibonacci(int n) {
    if (n <= 1) return n;
    long a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
        long temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}
```

```cpp
// C++ - TCO зависит от компилятора и флагов оптимизации

#include <numeric>
#include <vector>

// Простая рекурсия
int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

// Хвостовая рекурсия (может быть оптимизирована с -O2/-O3)
int factorial_tail(int n, int acc = 1) {
    if (n <= 1) return acc;
    return factorial_tail(n - 1, acc * n);
}

// Рекурсия по вектору
int sum_recursive(const std::vector<int>& vec, size_t index = 0) {
    if (index >= vec.size()) return 0;
    return vec[index] + sum_recursive(vec, index + 1);
}

// Итеративный подход (рекомендуется)
int factorial_iter(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

// STL алгоритмы
int sum_stl(const std::vector<int>& vec) {
    return std::accumulate(vec.begin(), vec.end(), 0);
}

// Constexpr рекурсия (вычисляется в compile-time)
constexpr int factorial_constexpr(int n) {
    return n <= 1 ? 1 : n * factorial_constexpr(n - 1);
}

// Числа Фибоначчи
long long fibonacci(int n) {
    if (n <= 1) return n;
    long long a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
        long long temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}
```

### 3. Алгебраические типы данных (АТД)

**Как помогает:** Конструкторы типов для построения сложных иммутабельных структур. Недопустимые состояния становятся непредставимыми.

**АТД позволяют точно описать все возможные варианты значений типа через композицию базовых конструкций.** Типы-произведения (records, tuples) объединяют несколько значений одновременно (И). Типы-суммы (variants, enums) задают перечисление взаимоисключающих вариантов (ИЛИ). Это фундамент для создания точных доменных моделей, где некорректные состояния просто невозможно представить в системе типов.

**Типы-суммы и типы-произведения:**

| Язык           | Типы-суммы                | Типы-произведения      | Проверка полноты покрытия |
|----------------|---------------------------|------------------------|---------------------------|
| **OCaml**      | ✓✓✓ variants              | ✓✓✓ records            | ✓ Компилятор              |
| **F#**         | ✓✓✓ discriminated unions  | ✓✓✓ records            | ✓ Компилятор              |
| **Clojure**    | ✓ records/protocols       | ✓ records/maps         | ✗                         |
| **Scala**      | ✓✓✓ sealed traits         | ✓✓✓ case classes       | ✓ Sealed                  |
| **Ruby**       | ✗ Симуляция               | ✓ Struct               | ✗                         |
| **Rust**       | ✓✓✓ enum                  | ✓✓✓ struct             | ✓ Компилятор              |
| **Go**         | ✗                         | ✓ struct               | ✗                         |
| **JavaScript** | ✗                         | ✓ Object               | ✗                         |
| **TypeScript** | ✓✓ union types            | ✓✓ interface/type      | Частично                  |
| **Python**     | ✓ Union types             | ✓✓ dataclasses         | ✗                         |
| **Java**       | ✓✓ sealed (17+)           | ✓✓ records (16+)       | ✓ Sealed                  |
| **C++**        | ✓✓ variant (17+)          | ✓✓ struct              | Частично                  |

**Примеры:**

```ocaml
(* OCaml - variant types и records *)

(* Тип-произведение *)
type point = { x: float; y: float }

(* Тип-сумма *)
type shape =
  | Circle of { center: point; radius: float }
  | Rectangle of { top_left: point; width: float; height: float }
  | Triangle of point * point * point

(* Использование *)
let area = function
  | Circle { radius; _ } -> 3.14 *. radius *. radius
  | Rectangle { width; height; _ } -> width *. height
  | Triangle (p1, p2, p3) -> (* формула Герона *) 0.0

(* Option type - встроенный тип-сумма *)
type 'a option = None | Some of 'a

let divide x y =
  if y = 0.0 then None else Some (x /. y)
```

```fsharp
// F# - discriminated unions и records

// Тип-произведение
type Point = { X: float; Y: float }

// Тип-сумма
type Shape =
    | Circle of center: Point * radius: float
    | Rectangle of topLeft: Point * width: float * height: float
    | Triangle of Point * Point * Point

// Использование
let area shape =
    match shape with
    | Circle (_, radius) -> 3.14 * radius * radius
    | Rectangle (_, width, height) -> width * height
    | Triangle _ -> 0.0  // упрощено

// Result type для обработки ошибок
let divide x y =
    if y = 0.0 then Error "Division by zero"
    else Ok (x / y)
```

```clojure
;; Clojure - records и протоколы для симуляции АТД

;; Тип-произведение через defrecord
(defrecord Point [x y])

;; Типы-суммы симулируются через tagged maps
(defn circle [center radius]
  {:type :circle :center center :radius radius})

(defn rectangle [top-left width height]
  {:type :rectangle :top-left top-left :width width :height height})

;; Pattern matching через multimethods
(defmulti area :type)

(defmethod area :circle [{:keys [radius]}]
  (* 3.14 radius radius))

(defmethod area :rectangle [{:keys [width height]}]
  (* width height))

;; Either через {:ok value} или {:error msg}
(defn divide [x y]
  (if (zero? y)
    {:error "Division by zero"}
    {:ok (/ x y)}))
```

```scala
// Scala 3 - sealed traits и case classes

// Тип-произведение
case class Point(x: Double, y: Double)

// Тип-сумма через sealed trait
sealed trait Shape
case class Circle(center: Point, radius: Double) extends Shape
case class Rectangle(topLeft: Point, width: Double, height: Double) extends Shape
case class Triangle(p1: Point, p2: Point, p3: Point) extends Shape

// Pattern matching с проверкой полноты покрытия
def area(shape: Shape): Double = shape match
  case Circle(_, radius) => 3.14 * radius * radius
  case Rectangle(_, width, height) => width * height
  case Triangle(_, _, _) => 0.0  // упрощено

// Either type
def divide(x: Double, y: Double): Either[String, Double] =
  if y == 0.0 then Left("Division by zero")
  else Right(x / y)
```

```ruby
# Ruby - Struct и паттерн для симуляции АТД

# Тип-произведение через Struct
Point = Struct.new(:x, :y)

# Симуляция типов-сумм через классы
class Shape
  class Circle < Shape
    attr_reader :center, :radius
    def initialize(center, radius)
      @center, @radius = center, radius
    end
  end

  class Rectangle < Shape
    attr_reader :top_left, :width, :height
    def initialize(top_left, width, height)
      @top_left, @width, @height = top_left, width, height
    end
  end
end

# Pattern matching (Ruby 3.0+)
def area(shape)
  case shape
  in Shape::Circle[center:, radius:]
    3.14 * radius * radius
  in Shape::Rectangle[top_left:, width:, height:]
    width * height
  end
end

# Dry-monads для Either
require 'dry/monads'
include Dry::Monads[:result]

def divide(x, y)
  return Failure("Division by zero") if y.zero?
  Success(x / y)
end
```

```rust
// Rust - enum и struct

// Тип-произведение
#[derive(Debug, Clone, Copy)]
struct Point {
    x: f64,
    y: f64,
}

// Тип-сумма через enum
#[derive(Debug)]
enum Shape {
    Circle { center: Point, radius: f64 },
    Rectangle { top_left: Point, width: f64, height: f64 },
    Triangle(Point, Point, Point),
}

// Pattern matching с проверкой полноты покрытия
fn area(shape: &Shape) -> f64 {
    match shape {
        Shape::Circle { radius, .. } => 3.14 * radius * radius,
        Shape::Rectangle { width, height, .. } => width * height,
        Shape::Triangle(_, _, _) => 0.0,  // упрощено
    }
}

// Result<T, E> - встроенный тип
fn divide(x: f64, y: f64) -> Result<f64, String> {
    if y == 0.0 {
        Err("Division by zero".to_string())
    } else {
        Ok(x / y)
    }
}
```

```go
// Go - struct (нет нативных типов-сумм)

// Тип-произведение
type Point struct {
    X float64
    Y float64
}

// Симуляция типов-сумм через интерфейс и типы
type Shape interface {
    isShape()
}

type Circle struct {
    Center Point
    Radius float64
}

type Rectangle struct {
    TopLeft Point
    Width   float64
    Height  float64
}

func (c Circle) isShape()    {}
func (r Rectangle) isShape() {}

// Type switch для диспетчеризации
func area(s Shape) float64 {
    switch shape := s.(type) {
    case Circle:
        return 3.14 * shape.Radius * shape.Radius
    case Rectangle:
        return shape.Width * shape.Height
    default:
        return 0.0
    }
}

// Result через кортеж (value, error)
func divide(x, y float64) (float64, error) {
    if y == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return x / y, nil
}
```

```javascript
// JavaScript - Object (нет нативных АТД)

// Тип-произведение через Object
const createPoint = (x, y) => ({ x, y });

// Симуляция типов-сумм через tagged unions
const createCircle = (center, radius) => ({
  type: 'circle',
  center,
  radius
});

const createRectangle = (topLeft, width, height) => ({
  type: 'rectangle',
  topLeft,
  width,
  height
});

// Диспетчеризация вручную
function area(shape) {
  switch (shape.type) {
    case 'circle':
      return 3.14 * shape.radius * shape.radius;
    case 'rectangle':
      return shape.width * shape.height;
    default:
      return 0;
  }
}

// Either через объекты
const divide = (x, y) =>
  y === 0
    ? { type: 'error', message: 'Division by zero' }
    : { type: 'ok', value: x / y };
```

```typescript
// TypeScript - union types и interface

// Тип-произведение
interface Point {
  x: number;
  y: number;
}

// Тип-сумма через discriminated union
type Shape =
  | { type: 'circle'; center: Point; radius: number }
  | { type: 'rectangle'; topLeft: Point; width: number; height: number }
  | { type: 'triangle'; p1: Point; p2: Point; p3: Point };

// Exhaustive checking через never
function area(shape: Shape): number {
  switch (shape.type) {
    case 'circle':
      return 3.14 * shape.radius * shape.radius;
    case 'rectangle':
      return shape.width * shape.height;
    case 'triangle':
      return 0;  // упрощено
    default:
      // Компилятор проверит, что все варианты покрыты
      const _exhaustive: never = shape;
      return _exhaustive;
  }
}

// Either type
type Either<L, R> = { type: 'left'; value: L } | { type: 'right'; value: R };

function divide(x: number, y: number): Either<string, number> {
  return y === 0
    ? { type: 'left', value: 'Division by zero' }
    : { type: 'right', value: x / y };
}
```

```python
# Python - dataclasses и Union types

from dataclasses import dataclass
from typing import Union

# Тип-произведение
@dataclass
class Point:
    x: float
    y: float

# Типы-суммы через Union и dataclasses
@dataclass
class Circle:
    center: Point
    radius: float

@dataclass
class Rectangle:
    top_left: Point
    width: float
    height: float

@dataclass
class Triangle:
    p1: Point
    p2: Point
    p3: Point

Shape = Union[Circle, Rectangle, Triangle]

# Pattern matching (Python 3.10+)
def area(shape: Shape) -> float:
    match shape:
        case Circle(center=_, radius=r):
            return 3.14 * r * r
        case Rectangle(top_left=_, width=w, height=h):
            return w * h
        case Triangle():
            return 0.0  # упрощено

# Either через библиотеку returns
from returns.result import Result, Success, Failure

def divide(x: float, y: float) -> Result[float, str]:
    if y == 0:
        return Failure("Division by zero")
    return Success(x / y)
```

```java
// Java 21 - sealed interfaces и records

// Тип-произведение
record Point(double x, double y) {}

// Тип-сумма через sealed interface
sealed interface Shape permits Circle, Rectangle, Triangle {}

record Circle(Point center, double radius) implements Shape {}
record Rectangle(Point topLeft, double width, double height) implements Shape {}
record Triangle(Point p1, Point p2, Point p3) implements Shape {}

// Pattern matching с проверкой полноты покрытия
double area(Shape shape) {
    return switch (shape) {
        case Circle(Point _, double radius) -> 3.14 * radius * radius;
        case Rectangle(Point _, double width, double height) -> width * height;
        case Triangle _ -> 0.0;  // упрощено
    };
}

// Either через Vavr
import io.vavr.control.Either;

Either<String, Double> divide(double x, double y) {
    return y == 0
        ? Either.left("Division by zero")
        : Either.right(x / y);
}
```

```cpp
// C++17/20 - std::variant и struct

#include <variant>
#include <string>
#include <optional>

// Тип-произведение
struct Point {
    double x;
    double y;
};

// Типы для суммы
struct Circle {
    Point center;
    double radius;
};

struct Rectangle {
    Point topLeft;
    double width;
    double height;
};

struct Triangle {
    Point p1, p2, p3;
};

// Тип-сумма через std::variant
using Shape = std::variant<Circle, Rectangle, Triangle>;

// Pattern matching через std::visit
double area(const Shape& shape) {
    return std::visit([](auto&& s) -> double {
        using T = std::decay_t<decltype(s)>;
        if constexpr (std::is_same_v<T, Circle>) {
            return 3.14 * s.radius * s.radius;
        } else if constexpr (std::is_same_v<T, Rectangle>) {
            return s.width * s.height;
        } else {
            return 0.0;
        }
    }, shape);
}

// Either через std::expected (C++23) или std::variant
template<typename T, typename E>
using Result = std::variant<T, E>;

Result<double, std::string> divide(double x, double y) {
    if (y == 0.0) {
        return std::string("Division by zero");
    }
    return x / y;
}
```

### 4. Сопоставление с образцом

**Как помогает:** Элегантная деструктуризация иммутабельных структур. Проверка структуры + извлечение компонентов одновременно.

**Связь с АТД:** Сопоставление с образцом — естественный инструмент для работы с алгебраическими типами данных. Когда АТД определяет конечное множество возможных вариантов значения (типы-суммы), сопоставление с образцом позволяет элегантно разобрать каждый вариант, извлекая вложенные данные (типы-произведения). В языках с сильной поддержкой АТД компилятор проверяет полноту покрытия всех возможных вариантов, делая невозможными логические ошибки из-за забытых случаев.

**Возможности:**

| Язык           | Версия | Деструктуризация | Guards        | Полнота покрытия  |
|----------------|--------|------------------|---------------|-------------------|
| **OCaml**      | Все    | ✓✓✓              | ✓ when        | ✓ Компилятор      |
| **F#**         | Все    | ✓✓✓              | ✓ when        | ✓ Компилятор      |
| **Clojure**    | Все    | ✓✓               | core.match    | ✗                 |
| **Scala**      | Все    | ✓✓✓              | ✓ if          | ✓ Sealed traits   |
| **Ruby**       | 2.7+   | ✓✓               | ✓ if          | ✗                 |
| **Rust**       | Все    | ✓✓✓              | ✓ if          | ✓ Компилятор      |
| **Go**         | ✗      | ✗                | ✗             | ✗                 |
| **JavaScript** | ES6+   | ✓✓               | ✗             | ✗                 |
| **TypeScript** | Все    | ✓✓               | ✗             | ✗                 |
| **Python**     | 3.10+  | ✓✓               | ✓ if          | ✗                 |
| **Java**       | 21     | ✓✓               | ✓ when        | ✓ Sealed          |
| **C++**        | 17+    | ✓ bindings       | constexpr if  | Частично          |

**Примеры паттерн-матчинга:**

```ocaml
(* OCaml - сопоставление с образцом *)
type shape =
  | Circle of float
  | Rectangle of float * float
  | Triangle of float * float * float

let area = function
  | Circle radius -> 3.14 *. radius *. radius
  | Rectangle (width, height) -> width *. height
  | Triangle (a, b, c) ->
      let s = (a +. b +. c) /. 2. in
      sqrt (s *. (s -. a) *. (s -. b) *. (s -. c))

(* Guards *)
let classify n = match n with
  | x when x < 0 -> "negative"
  | 0 -> "zero"
  | x when x > 100 -> "large"
  | _ -> "positive"
```

```fsharp
// F# - сопоставление с образцом
type Shape =
    | Circle of radius: float
    | Rectangle of width: float * height: float
    | Triangle of a: float * b: float * c: float

let area shape =
    match shape with
    | Circle radius -> 3.14 * radius * radius
    | Rectangle (width, height) -> width * height
    | Triangle (a, b, c) ->
        let s = (a + b + c) / 2.0
        sqrt (s * (s - a) * (s - b) * (s - c))

// Guards с when
let classify n =
    match n with
    | x when x < 0 -> "negative"
    | 0 -> "zero"
    | x when x > 100 -> "large"
    | _ -> "positive"
```

```clojure
;; Clojure - деструктуризация в let
(let [[x y & rest] [1 2 3 4 5]]
  (println x y rest))  ;; 1 2 (3 4 5)

;; core.match для паттерн-матчинга
(require '[clojure.core.match :refer [match]])

(defn classify [n]
  (match [n]
    [(_ :guard neg?)] "negative"
    [0] "zero"
    [(_ :guard #(> % 100))] "large"
    :else "positive"))
```

```scala
// Scala 3 - сопоставление с образцом
enum Shape:
  case Circle(radius: Double)
  case Rectangle(width: Double, height: Double)
  case Triangle(a: Double, b: Double, c: Double)

def area(shape: Shape): Double = shape match
  case Shape.Circle(r) => 3.14 * r * r
  case Shape.Rectangle(w, h) => w * h
  case Shape.Triangle(a, b, c) =>
    val s = (a + b + c) / 2.0
    math.sqrt(s * (s - a) * (s - b) * (s - c))

// Guards с if
def classify(n: Int): String = n match
  case x if x < 0 => "negative"
  case 0 => "zero"
  case x if x > 100 => "large"
  case _ => "positive"
```

```ruby
# Ruby 2.7+ - pattern matching
def area(shape)
  case shape
  in [:circle, radius]
    3.14 * radius * radius
  in [:rectangle, width, height]
    width * height
  in [:triangle, a, b, c]
    s = (a + b + c) / 2.0
    Math.sqrt(s * (s - a) * (s - b) * (s - c))
  end
end

# Guards с if
def classify(n)
  case n
  in x if x < 0
    "negative"
  in 0
    "zero"
  in x if x > 100
    "large"
  else
    "positive"
  end
end
```

```rust
// Rust - exhaustive pattern matching
enum Shape {
    Circle { radius: f64 },
    Rectangle { width: f64, height: f64 },
    Triangle { a: f64, b: f64, c: f64 },
}

fn area(shape: &Shape) -> f64 {
    match shape {
        Shape::Circle { radius } => 3.14 * radius * radius,
        Shape::Rectangle { width, height } => width * height,
        Shape::Triangle { a, b, c } => {
            let s = (a + b + c) / 2.0;
            (s * (s - a) * (s - b) * (s - c)).sqrt()
        }
    }
}

// Guards с if
fn classify(n: i32) -> &'static str {
    match n {
        x if x < 0 => "negative",
        0 => "zero",
        x if x > 100 => "large",
        _ => "positive",
    }
}
```

```go
// Go - нет паттерн-матчинга, используется type switch
type Shape interface {
    Area() float64
}

type Circle struct{ Radius float64 }
type Rectangle struct{ Width, Height float64 }

func (c Circle) Area() float64 {
    return 3.14 * c.Radius * c.Radius
}

func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

// Type switch
func area(s Shape) float64 {
    switch v := s.(type) {
    case Circle:
        return v.Area()
    case Rectangle:
        return v.Area()
    default:
        return 0
    }
}
```

```javascript
// JavaScript - деструктуризация
const point = {x: 10, y: 20};
const {x, y} = point;

// Деструктуризация массивов
const [first, second, ...rest] = [1, 2, 3, 4, 5];

// Нет exhaustive checking
function classify(n) {
    if (n < 0) return "negative";
    if (n === 0) return "zero";
    if (n > 100) return "large";
    return "positive";
}
```

```typescript
// TypeScript - discriminated unions
type Shape =
    | { kind: 'circle'; radius: number }
    | { kind: 'rectangle'; width: number; height: number }
    | { kind: 'triangle'; a: number; b: number; c: number };

function area(shape: Shape): number {
    switch (shape.kind) {
        case 'circle':
            return 3.14 * shape.radius * shape.radius;
        case 'rectangle':
            return shape.width * shape.height;
        case 'triangle':
            const s = (shape.a + shape.b + shape.c) / 2;
            return Math.sqrt(s * (s - shape.a) * (s - shape.b) * (s - shape.c));
    }
}
```

```python
# Python 3.10+ - structural pattern matching
def area(shape):
    match shape:
        case ("circle", radius):
            return 3.14 * radius * radius
        case ("rectangle", width, height):
            return width * height
        case ("triangle", a, b, c):
            s = (a + b + c) / 2
            return (s * (s - a) * (s - b) * (s - c)) ** 0.5

# Guards с if
def classify(n):
    match n:
        case x if x < 0:
            return "negative"
        case 0:
            return "zero"
        case x if x > 100:
            return "large"
        case _:
            return "positive"
```

```java
// Java 21 - pattern matching для switch
sealed interface Shape permits Circle, Rectangle, Triangle {}
record Circle(double radius) implements Shape {}
record Rectangle(double width, double height) implements Shape {}
record Triangle(double a, double b, double c) implements Shape {}

double area(Shape shape) {
    return switch (shape) {
        case Circle(double r) -> 3.14 * r * r;
        case Rectangle(double w, double h) -> w * h;
        case Triangle(double a, double b, double c) -> {
            double s = (a + b + c) / 2.0;
            yield Math.sqrt(s * (s - a) * (s - b) * (s - c));
        }
    };
}

// Guards с when
String classify(int n) {
    return switch (n) {
        case 0 -> "zero";
        case int x when x < 0 -> "negative";
        case int x when x > 100 -> "large";
        default -> "positive";
    };
}
```

```cpp
// C++17 - structured bindings и std::visit
#include <variant>
#include <cmath>

struct Circle { double radius; };
struct Rectangle { double width, height; };
struct Triangle { double a, b, c; };

using Shape = std::variant<Circle, Rectangle, Triangle>;

double area(const Shape& shape) {
    return std::visit([](auto&& s) -> double {
        using T = std::decay_t<decltype(s)>;
        if constexpr (std::is_same_v<T, Circle>) {
            return 3.14 * s.radius * s.radius;
        } else if constexpr (std::is_same_v<T, Rectangle>) {
            return s.width * s.height;
        } else if constexpr (std::is_same_v<T, Triangle>) {
            double p = (s.a + s.b + s.c) / 2.0;
            return std::sqrt(p * (p - s.a) * (p - s.b) * (p - s.c));
        }
    }, shape);
}
```

### 5. Статическая типизация с выводом типов

**Как помогает:** Ошибки ловятся на этапе компиляции. Вывод типов сокращает аннотации без потери безопасности.

**Системы типов:**

| Язык           | Типизация    | Вывод типов          | Generics    | Advanced                         |
|----------------|--------------|----------------------|-------------|----------------------------------|
| **OCaml**      | Статическая  | ✓✓✓ Хиндли-Милнер    | ✓✓✓         | GADTs, phantom types             |
| **F#**         | Статическая  | ✓✓✓ Хиндли-Милнер    | ✓✓✓         | Type providers, units of measure |
| **Clojure**    | Динамическая | N/A                  | N/A         | Clojure Spec (opt-in)            |
| **Scala**      | Статическая  | ✓✓ Локальный         | ✓✓✓         | HKT, path-dependent              |
| **Ruby**       | Динамическая | N/A                  | N/A         | RBS (opt-in)                     |
| **Rust**       | Статическая  | ✓✓✓ Мощный           | ✓✓✓         | Traits, lifetimes                |
| **Go**         | Статическая  | ✓ Базовый            | ✓ (1.18+)   | Interfaces                       |
| **JavaScript** | Динамическая | N/A                  | N/A         | ✗                                |
| **TypeScript** | Статическая  | ✓✓ Мощный            | ✓✓✓         | Union types, mapped types        |
| **Python**     | Динамическая | N/A                  | ✓ TypeVar   | Type hints (opt-in)              |
| **Java**       | Статическая  | ✓ Локальный          | ✓✓          | Bounded wildcards                |
| **C++**        | Статическая  | ✓✓ auto, decltype    | ✓✓✓         | Concepts, metaprog               |

**Вывод типов Хиндли-Милнера:**

Алгоритм, позволяющий компилятору автоматически определить типы всех выражений в программе без явных аннотаций. Ключевое свойство: компилятор выводит **наиболее общий тип** (most general type) — максимально полиморфный тип, который подходит для данного выражения. Например, функция `let identity x = x` получает тип `'a -> 'a` (работает с любым типом), а не конкретный `int -> int`. Если типы несовместимы (например, пытаемся сложить число и строку), компилятор выдаст ошибку на этапе компиляции, указав точное место конфликта типов.

**Примеры:**

```ocaml
(* OCaml - полный вывод типов без аннотаций *)

(* Компилятор выводит: val identity : 'a -> 'a *)
let identity x = x

(* Компилятор выводит: val compose : ('b -> 'c) -> ('a -> 'b) -> 'a -> 'c *)
let compose f g x = f (g x)

(* Компилятор выводит: val map : ('a -> 'b) -> 'a list -> 'b list *)
let rec map f lst = match lst with
  | [] -> []
  | x :: xs -> f x :: map f xs

(* Полиморфная функция с выводом типов *)
(* Компилятор выводит: val apply_twice : ('a -> 'a) -> 'a -> 'a *)
let apply_twice f x = f (f x)

(* Использование - типы выводятся автоматически *)
let result1 = apply_twice ((+) 1) 10  (* int -> int, result: 12 *)
let result2 = apply_twice String.uppercase_ascii "hello"  (* string -> string *)

(* Сложный вывод типов с generics *)
(* Компилятор выводит: val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a *)
let rec fold_left f acc = function
  | [] -> acc
  | x :: xs -> fold_left f (f acc x) xs

(* Компилятор выводит тип Option автоматически *)
(* val find : ('a -> bool) -> 'a list -> 'a option *)
let rec find predicate = function
  | [] -> None
  | x :: xs -> if predicate x then Some x else find predicate xs

(* Вывод типов для функций высшего порядка *)
(* val pipe : 'a -> ('a -> 'b) -> 'b *)
let pipe x f = f x

(* Вывод типов с constraint - компилятор понимает что нужен числовой тип *)
let sum_of_squares x y = x * x + y * y  (* int -> int -> int *)
```

```fsharp
// F# - вывод типов Хиндли-Милнера на .NET

// Компилятор выводит: val identity : 'a -> 'a
let identity x = x

// Компилятор выводит: val compose : ('b -> 'c) -> ('a -> 'b) -> 'a -> 'c
let compose f g x = f (g x)

// Компилятор выводит: val map : ('a -> 'b) -> 'a list -> 'b list
let rec map f lst =
    match lst with
    | [] -> []
    | x :: xs -> f x :: map f xs

// Полиморфная функция
// Компилятор выводит: val applyTwice : ('a -> 'a) -> 'a -> 'a
let applyTwice f x = f (f x)

// Использование - типы автоматически
let result1 = applyTwice ((+) 1) 10        // int, result: 12
let result2 = applyTwice String.toUpper "hello"  // string

// Вывод generic типов
// Компилятор выводит: val foldLeft : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
let rec foldLeft f acc lst =
    match lst with
    | [] -> acc
    | x :: xs -> foldLeft f (f acc x) xs

// Option type выводится автоматически
// val find : ('a -> bool) -> 'a list -> 'a option
let rec find predicate lst =
    match lst with
    | [] -> None
    | x :: xs ->
        if predicate x then Some x
        else find predicate xs

// Pipeline с выводом типов
// val processData : int list -> int
let processData data =
    data
    |> List.filter (fun x -> x % 2 = 0)  // компилятор выводит int list
    |> List.map (fun x -> x * 2)         // int list
    |> List.sum                          // int

// Вывод типов с числовыми операциями
let sumOfSquares x y = x * x + y * y  // int -> int -> int

// Вывод типов для tuple
let swap (x, y) = (y, x)  // 'a * 'b -> 'b * 'a

// Компилятор выводит наиболее общий тип
let rec length lst =
    match lst with
    | [] -> 0
    | _ :: tail -> 1 + length tail
// val length : 'a list -> int
```

### 6. Ленивые вычисления

**Как помогает:** Выражения не вычисляются до необходимости. Бесконечные структуры, улучшенная производительность.

**Поддержка:**

| Язык           | Стратегия | Ленивые структуры                | Бесконечные потоки |
|----------------|-----------|----------------------------------|--------------------|
| **OCaml**      | Строгая   | Lazy.t, Seq                      | ✓                  |
| **F#**         | Строгая   | Seq, lazy                        | ✓                  |
| **Clojure**    | Ленивая   | lazy sequences (по умолчанию)    | ✓                  |
| **Scala**      | Строгая   | LazyList, lazy val               | ✓                  |
| **Ruby**       | Строгая   | Enumerator::Lazy                 | ✓                  |
| **Rust**       | Строгая   | Iterator (ленивые)               | ✓                  |
| **Go**         | Строгая   | Channels                         | Частично           |
| **JavaScript** | Строгая   | Generators                       | ✓                  |
| **TypeScript** | Строгая   | Generators                       | ✓                  |
| **Python**     | Строгая   | generators, itertools            | ✓                  |
| **Java**       | Строгая   | Stream API                       | ✓                  |
| **C++**        | Строгая   | Ranges (C++20)                   | ✓                  |

**Примеры:**

```ocaml
(* OCaml - Seq для ленивых последовательностей *)

(* Бесконечная последовательность натуральных чисел *)
let naturals =
  let rec gen n () = Seq.Cons (n, gen (n + 1)) in
  gen 0

(* Ленивая обработка - вычисляется только необходимое *)
let first_10_evens =
  naturals
  |> Seq.filter (fun n -> n mod 2 = 0)
  |> Seq.take 10
  |> Seq.to_list

(* Отложенное вычисление *)
let expensive = lazy (
  (* Вычисляется только при первом доступе *)
  List.fold_left (+) 0 [1; 2; 3; 4; 5]
)
let result = Lazy.force expensive
```

```fsharp
// F# - seq для ленивых последовательностей

// Бесконечная последовательность
let naturals = Seq.initInfinite id

// Ленивая обработка
let firstTenEvens =
    naturals
    |> Seq.filter (fun n -> n % 2 = 0)
    |> Seq.take 10
    |> Seq.toList

// Отложенное вычисление
let expensive = lazy (
    // Вычисляется при первом доступе
    [1..1000000] |> List.sum
)
let result = expensive.Value
```

```clojure
;; Clojure - ленивые последовательности по умолчанию

;; Бесконечная последовательность
(def naturals (range))

;; Ленивая обработка - реализуется по требованию
(def first-ten-evens
  (->> naturals
       (filter even?)
       (take 10)))

;; Явная отложенность через lazy-seq
(defn fibonacci []
  (letfn [(fib [a b]
            (lazy-seq (cons a (fib b (+ a b)))))]
    (fib 0 1)))

;; Взять первые 10 чисел Фибоначчи
(take 10 (fibonacci))
;; => (0 1 1 2 3 5 8 13 21 34)
```

```scala
// Scala 3 - LazyList для ленивых последовательностей

// Бесконечная последовательность
val naturals: LazyList[Int] = LazyList.from(0)

// Ленивая обработка
val firstTenEvens =
  naturals
    .filter(_ % 2 == 0)
    .take(10)
    .toList

// Отложенное вычисление через lazy val
lazy val expensive = {
  // Вычисляется при первом доступе
  (1 to 1000000).sum
}

// Бесконечный поток Фибоначчи
def fibonacci: LazyList[BigInt] = {
  def fib(a: BigInt, b: BigInt): LazyList[BigInt] =
    a #:: fib(b, a + b)
  fib(0, 1)
}
```

```ruby
# Ruby - Enumerator::Lazy

# Бесконечная последовательность
naturals = (0..).lazy

# Ленивая обработка
first_ten_evens = naturals
  .select { |n| n.even? }
  .take(10)
  .to_a

# Enumerator для отложенных вычислений
fibonacci = Enumerator.new do |yielder|
  a, b = 0, 1
  loop do
    yielder << a
    a, b = b, a + b
  end
end.lazy

# Взять первые 10 чисел Фибоначчи
fibonacci.take(10).to_a
# => [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

```rust
// Rust - Iterator trait (ленивые по умолчанию)

// Бесконечная последовательность
let naturals = 0u64..;

// Ленивая обработка - вычисляется только при collect()
let first_ten_evens: Vec<u64> = naturals
    .filter(|n| n % 2 == 0)
    .take(10)
    .collect();

// Кастомный бесконечный итератор Фибоначчи
struct Fibonacci {
    a: u64,
    b: u64,
}

impl Iterator for Fibonacci {
    type Item = u64;

    fn next(&mut self) -> Option<u64> {
        let current = self.a;
        self.a = self.b;
        self.b = current + self.b;
        Some(current)
    }
}

let fib = Fibonacci { a: 0, b: 1 };
let first_ten: Vec<u64> = fib.take(10).collect();
```

```go
// Go - channels для потоковой обработки

// Генератор бесконечной последовательности
func naturals() <-chan int {
    ch := make(chan int)
    go func() {
        for i := 0; ; i++ {
            ch <- i
        }
    }()
    return ch
}

// Фильтр
func filter(in <-chan int, predicate func(int) bool) <-chan int {
    out := make(chan int)
    go func() {
        for n := range in {
            if predicate(n) {
                out <- n
            }
        }
    }()
    return out
}

// Использование
nums := naturals()
evens := filter(nums, func(n int) bool { return n%2 == 0 })

// Взять первые 10
var firstTenEvens []int
for i := 0; i < 10; i++ {
    firstTenEvens = append(firstTenEvens, <-evens)
}
```

```javascript
// JavaScript - generators для ленивых последовательностей

// Бесконечная последовательность
function* naturals() {
  let n = 0;
  while (true) {
    yield n++;
  }
}

// Ленивый фильтр
function* filter(iterable, predicate) {
  for (const item of iterable) {
    if (predicate(item)) {
      yield item;
    }
  }
}

// Взять N элементов
function* take(iterable, n) {
  let count = 0;
  for (const item of iterable) {
    if (count++ >= n) break;
    yield item;
  }
}

// Использование
const evens = filter(naturals(), n => n % 2 === 0);
const firstTenEvens = [...take(evens, 10)];

// Fibonacci generator
function* fibonacci() {
  let [a, b] = [0, 1];
  while (true) {
    yield a;
    [a, b] = [b, a + b];
  }
}
```

```typescript
// TypeScript - generators с типами

// Бесконечная последовательность
function* naturals(): Generator<number, never, undefined> {
  let n = 0;
  while (true) {
    yield n++;
  }
}

// Ленивый фильтр с generic типом
function* filter<T>(
  iterable: Iterable<T>,
  predicate: (item: T) => boolean
): Generator<T, void, undefined> {
  for (const item of iterable) {
    if (predicate(item)) {
      yield item;
    }
  }
}

// Взять N элементов
function* take<T>(
  iterable: Iterable<T>,
  n: number
): Generator<T, void, undefined> {
  let count = 0;
  for (const item of iterable) {
    if (count++ >= n) break;
    yield item;
  }
}

// Использование
const evens = filter(naturals(), n => n % 2 === 0);
const firstTenEvens = [...take(evens, 10)];
```

```python
# Python - generators и itertools

from itertools import count, islice

# Бесконечная последовательность
naturals = count(0)

# Ленивая обработка через generator expression
evens = (n for n in count(0) if n % 2 == 0)

# Взять первые 10
first_ten_evens = list(islice(evens, 10))

# Fibonacci generator
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

# Взять первые 10 чисел Фибоначчи
fib_numbers = list(islice(fibonacci(), 10))
# [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

```java
// Java - Stream API для ленивых операций

import java.util.stream.*;

// Бесконечная последовательность
Stream<Integer> naturals = Stream.iterate(0, n -> n + 1);

// Ленивая обработка
List<Integer> firstTenEvens = naturals
    .filter(n -> n % 2 == 0)
    .limit(10)
    .collect(Collectors.toList());

// Fibonacci через Stream.generate
class FibSupplier implements Supplier<Long> {
    private long a = 0, b = 1;

    public Long get() {
        long current = a;
        a = b;
        b = current + b;
        return current;
    }
}

List<Long> fibNumbers = Stream.generate(new FibSupplier())
    .limit(10)
    .collect(Collectors.toList());
```

```cpp
// C++20 - Ranges для ленивых вычислений

#include <ranges>
#include <vector>
#include <iostream>

namespace views = std::ranges::views;

// Бесконечная последовательность
auto naturals = views::iota(0);

// Ленивая обработка
auto first_ten_evens = naturals
    | views::filter([](int n) { return n % 2 == 0; })
    | views::take(10);

std::vector<int> result(first_ten_evens.begin(), first_ten_evens.end());

// Fibonacci через кастомный view (упрощенно)
auto fibonacci = views::iota(0)
    | views::transform([cache = std::vector<long>{0, 1}](int n) mutable {
        while (cache.size() <= n) {
            cache.push_back(cache[cache.size()-1] + cache[cache.size()-2]);
        }
        return cache[n];
    });

auto first_ten_fib = fibonacci | views::take(10);
```

### 7. Изоляция эффектов

**Как помогает:** Явное отделение чистой логики от эффектных операций. Максимизация чистоты, изоляция эффектов на границах.

**Инструменты:**

| Язык           | Подход                   | IO Monad            | Result/Either            |
|----------------|--------------------------|---------------------|--------------------------|
| **OCaml**      | Effect handlers          | Нет встроенного     | Result встроен           |
| **F#**         | Computation expressions  | Async               | Result встроен           |
| **Clojure**    | Конвенции, STM           | ✗                   | Библиотеки               |
| **Scala**      | IO, ZIO                  | ✓ Cats Effect, ZIO  | Either встроен           |
| **Ruby**       | Конвенция                | ✗                   | Dry-monads               |
| **Rust**       | Типы                     | ✗                   | Result, Option встроены  |
| **Go**         | Конвенция                | ✗                   | error встроен            |
| **JavaScript** | Promise                  | ✗                   | Библиотеки               |
| **TypeScript** | Promise                  | ✗                   | Библиотеки (fp-ts)       |
| **Python**     | Конвенция                | ✗                   | Кастомный/Returns        |
| **Java**       | Try, Optional            | Vavr Future         | Either (Vavr)            |
| **C++**        | RAII                     | ✗                   | expected (C++23)         |

**Примеры:**

```ocaml
(* OCaml - Result для обработки ошибок *)

(* Чистая логика *)
let validate_age age =
  if age < 0 then Error "Age cannot be negative"
  else if age > 150 then Error "Age too large"
  else Ok age

let calculate_retirement_year age =
  Result.map (fun a -> 2024 + (65 - a)) (validate_age age)

(* Композиция через Result *)
let process_user_input input =
  input
  |> int_of_string_opt
  |> Option.to_result ~none:"Invalid number"
  |> Result.bind validate_age
  |> Result.map (fun age -> Printf.sprintf "Valid age: %d" age)

(* Effect handlers (OCaml 5.0+) для IO *)
effect Read : string
effect Write : string -> unit

let program () =
  perform (Write "Enter your name: ");
  let name = perform Read in
  perform (Write ("Hello, " ^ name))
```

```fsharp
// F# - Result и computation expressions

// Чистая логика
let validateAge age =
    if age < 0 then Error "Age cannot be negative"
    elif age > 150 then Error "Age too large"
    else Ok age

let calculateRetirementYear age =
    2024 + (65 - age)

// Computation expression для Result
let processUser input =
    result {
        let! age =
            match System.Int32.TryParse(input) with
            | true, n -> Ok n
            | false, _ -> Error "Invalid number"
        let! validAge = validateAge age
        let retirementYear = calculateRetirementYear validAge
        return sprintf "Retirement year: %d" retirementYear
    }

// Async для изоляции IO
let fetchUserAsync userId =
    async {
        // Эффектная операция изолирована
        let! data = fetchFromDbAsync userId
        // Чистая трансформация
        return processData data
    }
```

```clojure
;; Clojure - конвенции и явное разделение

;; Чистая логика
(defn validate-age [age]
  (cond
    (< age 0) {:error "Age cannot be negative"}
    (> age 150) {:error "Age too large"}
    :else {:ok age}))

(defn calculate-retirement-year [age]
  (+ 2024 (- 65 age)))

;; Композиция с Either-подобной структурой
(defn process-user [input]
  (let [age-result (try
                     {:ok (Integer/parseInt input)}
                     (catch Exception e
                       {:error "Invalid number"}))]
    (if-let [error (:error age-result)]
      {:error error}
      (validate-age (:ok age-result)))))

;; STM для изоляции мутабельного состояния
(def account-balance (ref 1000))

(defn transfer [amount]
  (dosync
    (alter account-balance - amount)))
```

```scala
// Scala - IO monad через Cats Effect

import cats.effect.IO
import cats.implicits._

// Чистая логика
def validateAge(age: Int): Either[String, Int] =
  if age < 0 then Left("Age cannot be negative")
  else if age > 150 then Left("Age too large")
  else Right(age)

def calculateRetirementYear(age: Int): Int =
  2024 + (65 - age)

// Композиция через Either
def processUser(input: String): Either[String, String] =
  for
    age <- input.toIntOption.toRight("Invalid number")
    validAge <- validateAge(age)
    retirementYear = calculateRetirementYear(validAge)
  yield s"Retirement year: $retirementYear"

// IO для изоляции эффектов
def program: IO[Unit] = for
  _ <- IO.println("Enter your name:")
  name <- IO.readLine
  _ <- IO.println(s"Hello, $name")
yield ()

// ZIO для продвинутой изоляции эффектов
import zio._

val zioProgram: ZIO[Console, IOException, Unit] = for
  _ <- Console.printLine("Enter your name:")
  name <- Console.readLine
  _ <- Console.printLine(s"Hello, $name")
yield ()
```

```ruby
# Ruby - dry-monads для изоляции эффектов

require 'dry/monads'
include Dry::Monads[:result, :do]

# Чистая логика
def validate_age(age)
  return Failure("Age cannot be negative") if age < 0
  return Failure("Age too large") if age > 150
  Success(age)
end

def calculate_retirement_year(age)
  2024 + (65 - age)
end

# Композиция через do-notation
def process_user(input)
  age = yield parse_int(input)
  valid_age = yield validate_age(age)
  retirement_year = calculate_retirement_year(valid_age)
  Success("Retirement year: #{retirement_year}")
end

def parse_int(str)
  Integer(str)
  Success(Integer(str))
rescue ArgumentError
  Failure("Invalid number")
end

# Конвенция: методы с ! для эффектных операций
def save_user!(user)
  # Эффектная операция - изменение БД
  database.insert(user)
end

def create_user(data)
  # Чистая валидация
  validate_user(data)
end
```

```rust
// Rust - Result и Option для изоляции ошибок

// Чистая логика
fn validate_age(age: i32) -> Result<i32, String> {
    if age < 0 {
        Err("Age cannot be negative".to_string())
    } else if age > 150 {
        Err("Age too large".to_string())
    } else {
        Ok(age)
    }
}

fn calculate_retirement_year(age: i32) -> i32 {
    2024 + (65 - age)
}

// Композиция через ? operator
fn process_user(input: &str) -> Result<String, String> {
    let age = input.parse::<i32>()
        .map_err(|_| "Invalid number".to_string())?;
    let valid_age = validate_age(age)?;
    let retirement_year = calculate_retirement_year(valid_age);
    Ok(format!("Retirement year: {}", retirement_year))
}

// Типы для изоляции IO
use std::io::{self, Write};

fn program() -> io::Result<()> {
    print!("Enter your name: ");
    io::stdout().flush()?;

    let mut name = String::new();
    io::stdin().read_line(&mut name)?;

    println!("Hello, {}", name.trim());
    Ok(())
}
```

```go
// Go - error возвращаемое значение

import "fmt"

// Чистая логика
func validateAge(age int) error {
    if age < 0 {
        return fmt.Errorf("age cannot be negative")
    }
    if age > 150 {
        return fmt.Errorf("age too large")
    }
    return nil
}

func calculateRetirementYear(age int) int {
    return 2024 + (65 - age)
}

// Композиция через проверку ошибок
func processUser(input string) (string, error) {
    var age int
    _, err := fmt.Sscanf(input, "%d", &age)
    if err != nil {
        return "", fmt.Errorf("invalid number")
    }

    if err := validateAge(age); err != nil {
        return "", err
    }

    retirementYear := calculateRetirementYear(age)
    return fmt.Sprintf("Retirement year: %d", retirementYear), nil
}

// Конвенция: явное разделение чистых и эффектных функций
func fetchUser(id int) (*User, error) {
    // Эффектная операция
    return db.Query("SELECT * FROM users WHERE id = ?", id)
}
```

```javascript
// JavaScript - Promise для изоляции асинхронных эффектов

// Чистая логика
const validateAge = (age) => {
  if (age < 0) return { type: 'error', message: 'Age cannot be negative' };
  if (age > 150) return { type: 'error', message: 'Age too large' };
  return { type: 'ok', value: age };
};

const calculateRetirementYear = (age) => 2024 + (65 - age);

// Композиция через Either-подобную структуру
const processUser = (input) => {
  const age = parseInt(input);
  if (isNaN(age)) {
    return { type: 'error', message: 'Invalid number' };
  }

  const validation = validateAge(age);
  if (validation.type === 'error') {
    return validation;
  }

  const retirementYear = calculateRetirementYear(validation.value);
  return { type: 'ok', value: `Retirement year: ${retirementYear}` };
};

// Promise для изоляции IO
const program = async () => {
  const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise((resolve) => {
    readline.question('Enter your name: ', (name) => {
      console.log(`Hello, ${name}`);
      readline.close();
      resolve();
    });
  });
};
```

```typescript
// TypeScript - fp-ts для функциональной изоляции эффектов

import { Either, left, right, chain, map } from 'fp-ts/Either';
import { pipe } from 'fp-ts/function';

// Чистая логика
const validateAge = (age: number): Either<string, number> => {
  if (age < 0) return left('Age cannot be negative');
  if (age > 150) return left('Age too large');
  return right(age);
};

const calculateRetirementYear = (age: number): number => 2024 + (65 - age);

// Композиция через pipe и Either
const processUser = (input: string): Either<string, string> => {
  const parseNumber = (s: string): Either<string, number> => {
    const n = parseInt(s);
    return isNaN(n) ? left('Invalid number') : right(n);
  };

  return pipe(
    parseNumber(input),
    chain(validateAge),
    map(calculateRetirementYear),
    map(year => `Retirement year: ${year}`)
  );
};

// IO type для изоляции эффектов (fp-ts)
import { IO } from 'fp-ts/IO';

const print = (message: string): IO<void> =>
  () => console.log(message);

const readLine = (): IO<string> =>
  () => require('readline-sync').question('Enter your name: ');

const program: IO<void> = pipe(
  readLine(),
  chain(name => print(`Hello, ${name}`))
);
```

```python
# Python - returns library для изоляции эффектов

from returns.result import Result, Success, Failure
from returns.pipeline import flow
from returns.pointfree import bind

# Чистая логика
def validate_age(age: int) -> Result[int, str]:
    if age < 0:
        return Failure("Age cannot be negative")
    if age > 150:
        return Failure("Age too large")
    return Success(age)

def calculate_retirement_year(age: int) -> int:
    return 2024 + (65 - age)

# Композиция через Result
def process_user(input_str: str) -> Result[str, str]:
    try:
        age = int(input_str)
    except ValueError:
        return Failure("Invalid number")

    return validate_age(age).map(
        lambda a: f"Retirement year: {calculate_retirement_year(a)}"
    )

# IO container для изоляции эффектов
from returns.io import IO

def print_message(msg: str) -> IO[None]:
    return IO(lambda: print(msg))

def read_input(prompt: str) -> IO[str]:
    return IO(lambda: input(prompt))

def program() -> IO[None]:
    return read_input("Enter your name: ").bind(
        lambda name: print_message(f"Hello, {name}")
    )
```

```java
// Java - Optional, Try (Vavr) для изоляции эффектов

import io.vavr.control.Try;
import io.vavr.control.Either;
import java.util.Optional;

// Чистая логика
Either<String, Integer> validateAge(int age) {
    if (age < 0) return Either.left("Age cannot be negative");
    if (age > 150) return Either.left("Age too large");
    return Either.right(age);
}

int calculateRetirementYear(int age) {
    return 2024 + (65 - age);
}

// Композиция через Either (Vavr)
Either<String, String> processUser(String input) {
    return Try.of(() -> Integer.parseInt(input))
        .toEither("Invalid number")
        .flatMap(this::validateAge)
        .map(this::calculateRetirementYear)
        .map(year -> "Retirement year: " + year);
}

// IO через Vavr Future для асинхронных эффектов
import io.vavr.concurrent.Future;

Future<User> fetchUser(int userId) {
    return Future.of(() -> {
        // Эффектная операция изолирована
        return database.query(userId);
    });
}

// Optional для представления отсутствия значения
Optional<User> findUserByEmail(String email) {
    return userRepository.findByEmail(email);
}
```

```cpp
// C++23 - std::expected для изоляции ошибок

#include <expected>
#include <string>
#include <format>

// Чистая логика
std::expected<int, std::string> validate_age(int age) {
    if (age < 0) {
        return std::unexpected("Age cannot be negative");
    }
    if (age > 150) {
        return std::unexpected("Age too large");
    }
    return age;
}

int calculate_retirement_year(int age) {
    return 2024 + (65 - age);
}

// Композиция через and_then
std::expected<std::string, std::string> process_user(const std::string& input) {
    try {
        int age = std::stoi(input);
        return validate_age(age)
            .transform([](int a) { return calculate_retirement_year(a); })
            .transform([](int year) {
                return std::format("Retirement year: {}", year);
            });
    } catch (...) {
        return std::unexpected("Invalid number");
    }
}

// RAII для изоляции ресурсов
class File {
    FILE* handle;
public:
    explicit File(const char* path) : handle(fopen(path, "r")) {
        if (!handle) throw std::runtime_error("Cannot open file");
    }
    ~File() { if (handle) fclose(handle); }

    // Автоматическая очистка через RAII
};
```

---

## Общая сводная таблица

### Фундаментальные свойства

**Преимущественно функциональные языки:**

| Свойство                       | OCaml  | F#     | Clojure | Scala  |
|--------------------------------|--------|--------|---------|--------|
| **Функции первого класса**     | ✓✓✓    | ✓✓✓    | ✓✓✓     | ✓✓✓    |
| **Чистые функции**             | ✓✓✓    | ✓✓✓    | ✓✓      | ✓✓     |
| **Иммутабельность**            | ✓✓✓    | ✓✓✓    | ✓✓✓     | ✓✓     |
| **Декларативность**            | ✓✓✓    | ✓✓✓    | ✓✓✓     | ✓✓✓    |
| **Выражения**                  | ✓✓✓    | ✓✓✓    | ✓✓✓     | ✓✓✓    |

**Интерпретируемые функционально-ОО языки:**

| Свойство                       | Ruby   | Python |
|--------------------------------|--------|--------|
| **Функции первого класса**     | ✓✓     | ✓✓✓    |
| **Чистые функции**             | ✓      | ✓      |
| **Иммутабельность**            | ✓      | ✓✓     |
| **Декларативность**            | ✓✓✓    | ✓✓✓    |
| **Выражения**                  | ✓✓✓    | ✓      |

**Системные и коммерческие языки с сильной поддержкой ФП:**

| Свойство                       | Rust   | Go     | Java   | C++    |
|--------------------------------|--------|--------|--------|--------|
| **Функции первого класса**     | ✓✓✓    | ✓✓     | ✓✓     | ✓✓     |
| **Чистые функции**             | ✓✓✓    | ✓✓     | ✓✓     | ✓✓     |
| **Иммутабельность**            | ✓✓✓    | ✓      | ✓✓     | ✓      |
| **Декларативность**            | ✓✓     | ✓      | ✓✓     | ✓      |
| **Выражения**                  | ✓✓✓    | ✗      | ✓✓     | ✓      |

**Веб-ориентированные языки:**

| Свойство                       | JavaScript | TypeScript |
|--------------------------------|------------|------------|
| **Функции первого класса**     | ✓✓✓        | ✓✓✓        |
| **Чистые функции**             | ✓          | ✓✓         |
| **Иммутабельность**            | ✓          | ✓          |
| **Декларативность**            | ✓✓✓        | ✓✓✓        |
| **Выражения**                  | ✓          | ✓          |

### Вспомогательные свойства

**Преимущественно функциональные языки:**

| Свойство                       | OCaml  | F#     | Clojure | Scala  |
|--------------------------------|--------|--------|---------|--------|
| **Композиция**                 | ✓✓✓    | ✓✓✓    | ✓✓✓     | ✓✓✓    |
| **TCO**                        | ✓✓✓    | ✓✓✓    | ✓       | ✓✓     |
| **Паттерн-матчинг**            | ✓✓✓    | ✓✓✓    | ✓       | ✓✓✓    |
| **АТД**                        | ✓✓✓    | ✓✓✓    | ✓       | ✓✓✓    |
| **Статическая типизация**      | ✓✓✓    | ✓✓✓    | ✗       | ✓✓✓    |
| **Ленивость**                  | ✓      | ✓✓     | ✓✓✓     | ✓✓     |
| **Изоляция эффектов**          | ✓✓     | ✓✓✓    | ✓✓      | ✓✓✓    |

**Интерпретируемые функционально-ОО языки:**

| Свойство                       | Ruby   | Python |
|--------------------------------|--------|--------|
| **Композиция**                 | ✓✓     | ✓✓     |
| **TCO**                        | ✗      | ✗      |
| **Паттерн-матчинг**            | ✓      | ✓✓     |
| **АТД**                        | ✗      | ✗      |
| **Статическая типизация**      | ✗      | ✗      |
| **Ленивость**                  | ✓      | ✓      |
| **Изоляция эффектов**          | ✓      | ✓      |

**Системные и коммерческие языки с сильной поддержкой ФП:**

| Свойство                       | Rust   | Go     | Java   | C++    |
|--------------------------------|--------|--------|--------|--------|
| **Композиция**                 | ✓✓     | ✗      | ✓✓     | ✓      |
| **TCO**                        | ✓✓     | ✗      | ✗      | ✓      |
| **Паттерн-матчинг**            | ✓✓✓    | ✗      | ✓✓     | ✓      |
| **АТД**                        | ✓✓✓    | ✗      | ✓✓     | ✓✓     |
| **Статическая типизация**      | ✓✓✓    | ✓✓     | ✓✓✓    | ✓✓✓    |
| **Ленивость**                  | ✓✓     | ✓      | ✓      | ✓      |
| **Изоляция эффектов**          | ✓✓✓    | ✓      | ✓✓     | ✓✓     |

**Веб-ориентированные языки:**

| Свойство                       | JavaScript | TypeScript |
|--------------------------------|------------|------------|
| **Композиция**                 | ✓          | ✓✓         |
| **TCO**                        | ✗          | ✗          |
| **Паттерн-матчинг**            | ✓          | ✓          |
| **АТД**                        | ✗          | ✓✓         |
| **Статическая типизация**      | ✗          | ✓✓✓        |
| **Ленивость**                  | ✓          | ✓          |
| **Изоляция эффектов**          | ✓          | ✓          |

### Производительность и экосистема

**Преимущественно функциональные языки:**

| Критерий                       | OCaml  | F#     | Clojure | Scala    |
|--------------------------------|--------|--------|---------|----------|
| **Производительность**         | ✓✓✓    | ✓✓     | ✓✓      | ✓✓       |
| **Экосистема ФП**              | ✓✓✓    | ✓✓✓    | ✓✓✓     | ✓✓✓      |
| **Community**                  | ✓✓     | ✓✓     | ✓✓      | ✓✓✓      |
| **Learning curve**             | Крутая | Средняя | Средняя | Средняя |

**Интерпретируемые функционально-ОО языки:**

| Критерий                       | Ruby   | Python |
|--------------------------------|--------|--------|
| **Производительность**         | ✓      | ✓      |
| **Экосистема ФП**              | ✓      | ✓✓     |
| **Community**                  | ✓✓✓    | ✓✓✓    |
| **Learning curve**             | Пологая | Пологая |

**Системные и коммерческие языки с сильной поддержкой ФП:**

| Критерий                       | Rust   | Go     | Java   | C++      |
|--------------------------------|--------|--------|--------|----------|
| **Производительность**         | ✓✓✓    | ✓✓✓    | ✓✓     | ✓✓✓      |
| **Экосистема ФП**              | ✓✓     | ✗      | ✓✓     | ✓        |
| **Community**                  | ✓✓✓    | ✓✓✓    | ✓✓✓    | ✓✓✓      |
| **Learning curve**             | Крутая | Пологая | Средняя | Крутая |

**Веб-ориентированные языки:**

| Критерий                       | JavaScript | TypeScript |
|--------------------------------|------------|------------|
| **Производительность**         | ✓          | ✓          |
| **Экосистема ФП**              | ✓✓         | ✓✓✓        |
| **Community**                  | ✓✓✓        | ✓✓✓        |
| **Learning curve**             | Пологая    | Средняя    |

**Легенда:** ✓✓✓ Отлично | ✓✓ Хорошо | ✓ Базово | ✗ Нет

---

## Выводы и рекомендации

### Когда использовать каждый язык

**OCaml** — для:
- Компиляторов и интерпретаторов
- Формальной верификации
- Проектов с максимальными гарантиями корректности
- Обучения чистому ФП (мультипарадигменный: ФП + мощная ООП-подсистема)

**F#** — для:
- Корпоративных проектов на .NET
- Data science и финансового моделирования
- Постепенной миграции с C#
- Прагматичного ФП с интеграцией ООП (родственник OCaml для .NET)

**Clojure** — для:
- JVM-проектов с акцентом на простоту и иммутабельность
- REPL-driven development и интерактивной разработки
- Data-oriented приложений с фокусом на трансформацию данных
- Конкурентного программирования с STM (Software Transactional Memory)
- Проектов где важна гибкость Lisp с производительностью JVM

**Scala** — для:
- Корпоративных проектов на JVM
- Постепенной миграции с Java
- Data engineering (Spark, Flink)
- Балансировки ФП и ООП

**Ruby** — для:
- Web-разработки (Rails)
- Скриптов и автоматизации
- DSL разработки
- Проектов где читаемость важнее производительности

**Rust** — для:
- Системного программирования с гарантиями безопасности
- WebAssembly и высокопроизводительного веба
- Критичных к безопасности приложений
- Замены C/C++ с современной эргономикой

**Go** — для:
- Микросервисов и облачных приложений
- Сетевых сервисов и API
- CLI-инструментов
- Проектов где простота важнее выразительности

**JavaScript** — для:
- Frontend-разработки (обязателен для браузера)
- Full-stack разработки (Node.js)
- Быстрого прототипирования веб-приложений
- Проектов где важна простота входа

**TypeScript** — для:
- Масштабируемых frontend-приложений
- Корпоративных веб-проектов с большими командами
- Проектов где важна типобезопасность в веб-экосистеме
- Постепенной миграции с JavaScript

**Python** — для:
- Data Science и ML
- Быстрого прототипирования
- Научных вычислений
- Обучения программированию

**Java** — для:
- Enterprise-приложений
- Android-разработки
- Микросервисов
- Долгосрочной поддержки

**C++** — для:
- Системного программирования
- Игровых движков
- Высокопроизводительных вычислений
- Встраиваемых систем

### Рекомендации по изучению

**Для изучения ФП:**
1. **Начните с:** Python (простота) или Scala (баланс)
2. **Продолжите:** OCaml (чистота) или Haskell
3. **Практикуйте:** Проекты на языке вашей платформы

**Для продакшена:**
- **JVM:** Scala с постепенным внедрением ФП
- **.NET:** F# для функционального стиля на платформе Microsoft
- **Web Frontend:** TypeScript (типобезопасность) или JavaScript (простота)
- **Web Backend:** Ruby/Python с функциональным стилем
- **Системы:** Rust (безопасность) или C++ (совместимость)
- **Облако:** Go (простота) или Rust (производительность)
- **Корректность:** OCaml, F# или Haskell

### Общий принцип

Используйте функциональные возможности вашего языка, даже если он не чисто функциональный. **Пять фундаментальных
свойств ФП улучшают код на любом языке.**

---

## Ресурсы для дополнительного изучения

### Академические курсы и учебники

**Классические курсы:**
- [CS 3110: Data Structures and Functional Programming (Cornell University)](https://cs3110.github.io/textbook/) - учебник по ФП на OCaml
- [Real World OCaml](https://dev.realworldocaml.org/) - практическое руководство по OCaml
- [Learn You a Haskell for Great Good](http://learnyouahaskell.com/) - введение в Haskell
- [F# for Fun and Profit](https://fsharpforfunandprofit.com/) - F# и функциональные паттерны

**Функциональное программирование на мейнстримных языках:**
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala) - классический учебник
- [Scala with Cats](https://underscore.io/books/scala-with-cats/) - практическое применение функциональных паттернов
- [Functional Programming in JavaScript](https://mostly-adequate.gitbook.io/mostly-adequate-guide/) - FP концепции в JavaScript
- [Functional Programming in Python](https://docs.python.org/3/howto/functional.html) - официальная документация Python

### Функциональные библиотеки по языкам

**Эти opensource-библиотеки являются референсными реализациями функциональных паттернов и могут служить образцами для изучения.**

**OCaml:**
- Стандартная библиотека: `Result.t`, модули высшего порядка, функторы
- [Jane Street Base](https://github.com/janestreet/base) - production-grade альтернативная стандартная библиотека
- [Jane Street Core](https://github.com/janestreet/core) - расширенная функциональная библиотека
- [Lwt](https://github.com/ocsigen/lwt) - асинхронное программирование с монадами
- [ppx_let](https://github.com/janestreet/ppx_let) - синтаксис для монадических операций

**F#:**
- Встроенная поддержка: `Result<'T, 'TError>`, computation expressions, discriminated unions
- [FSharpPlus](https://github.com/fsprojects/FSharpPlus) - расширения для функционального программирования
- [FsToolkit.ErrorHandling](https://github.com/demystifyfp/FsToolkit.ErrorHandling) - утилиты для обработки ошибок

**Clojure:**
- Встроенная поддержка: persistent data structures, STM, lazy sequences
- [core.async](https://github.com/clojure/core.async) - асинхронное программирование через CSP (Communicating Sequential Processes)
- [Manifold](https://github.com/clj-commons/manifold) - унифицированная абстракция для асинхронных операций
- [cats](https://github.com/funcool/cats) - категорная теория и функциональные абстракции для Clojure

**Scala:**
- Стандартная библиотека: `Option`, `Either`, `Try`, immutable collections
- [Cats](https://typelevel.org/cats/) ([GitHub](https://github.com/typelevel/cats)) - эталонная библиотека для функционального программирования
- [Cats Effect](https://typelevel.org/cats-effect/) ([GitHub](https://github.com/typelevel/cats-effect)) - система управления эффектами
- [ZIO](https://zio.dev/) ([GitHub](https://github.com/zio/zio)) - современная библиотека эффектов

**Ruby:**
- [dry-rb](https://dry-rb.org/) ([GitHub](https://github.com/dry-rb)) - полная экосистема функциональных гемов
- [dry-monads](https://dry-rb.org/gems/dry-monads/) - монады (Maybe, Result, Try)
- [dry-types](https://dry-rb.org/gems/dry-types/) - система типов с композицией

**Rust:**
- Стандартная библиотека: `Result<T, E>`, `Option<T>`, `Iterator` trait
- [itertools](https://github.com/rust-itertools/itertools) - расширенная работа с итераторами
- [anyhow](https://github.com/dtolnay/anyhow) - эргономичная обработка ошибок
- [thiserror](https://github.com/dtolnay/thiserror) - derive-макросы для типов ошибок

**Go:**
- Стандартная библиотека: встроенная обработка ошибок через `error` интерфейс
- Минимальная поддержка ФП, акцент на простоту и идиомы языка

**JavaScript / TypeScript:**
- [fp-ts](https://gcanti.github.io/fp-ts/) ([GitHub](https://github.com/gcanti/fp-ts)) - полноценное функциональное программирование для TypeScript
- [Ramda](https://ramdajs.com/) ([GitHub](https://github.com/ramda/ramda)) - практичные функциональные утилиты
- [Sanctuary](https://sanctuary.js.org/) ([GitHub](https://github.com/sanctuary-js/sanctuary)) - типобезопасная ФП библиотека
- [NeverThrow](https://github.com/supermacro/neverthrow) - Railway-Oriented Programming

**Python:**
- Стандартная библиотека: `functools`, `itertools`, `typing`
- [returns](https://github.com/dry-python/returns) - типобезопасные монады и railway-oriented programming
- [toolz](https://toolz.readthedocs.io/) ([GitHub](https://github.com/pytoolz/toolz)) - функциональная стандартная библиотека
- [PyMonad](https://github.com/jasondelaat/pymonad) - монады для Python

**Java:**
- Стандартная библиотека (Java 8+): `Optional`, `Stream API`, `CompletableFuture`
- [Vavr](https://www.vavr.io/) ([GitHub](https://github.com/vavr-io/vavr)) - функциональная библиотека для Java
- [Cyclops](https://github.com/aol/cyclops) - интеграция различных FP библиотек

**C++:**
- **C++ STL как референс:** STL (Standard Template Library) является образцом функционального программирования в C++
  - `std::optional` (C++17) - представление опциональных значений
  - `std::expected` (C++23) - обработка ошибок в функциональном стиле
  - `std::variant` (C++17) - типы-суммы (discriminated unions)
  - `<algorithm>` - функции высшего порядка (transform, accumulate, filter)
  - `<ranges>` (C++20) - композируемые ленивые преобразования
- [range-v3](https://github.com/ericniebler/range-v3) - прототип стандартных ranges, расширенная функциональность
- [Boost.Hof](https://github.com/boostorg/hof) - функции высшего порядка
- [expected-lite](https://github.com/martinmoene/expected-lite) - backport `std::expected` для C++11/14/17

### Теория и концепции

- [Category Theory for Programmers](https://bartoszmilewski.com/2014/10/28/category-theory-for-programmers-the-preface/) - Bartosz Milewski
- [Монады для программистов](https://habr.com/ru/articles/183150/) - статья на Хабре
- [Understanding Monads](https://en.wikibooks.org/wiki/Haskell/Understanding_monads) - Wikibooks
