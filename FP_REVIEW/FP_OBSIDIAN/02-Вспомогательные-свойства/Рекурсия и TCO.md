---
title: Рекурсия вместо итерации и TCO
type: supporting-property
tags:
  - вспомогательное
  - рекурсия
  - tco
  - хвостовая-рекурсия
created: 2025-10-15
---

# Рекурсия вместо итерации и TCO

← [[README|Главная]] | [[02-Вспомогательные-свойства/Композиция функций|Композиция]]


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



---

← [[02-Вспомогательные-свойства/Композиция функций|Композиция]] | Следующее: [[02-Вспомогательные-свойства/АТД|АТД]] →
