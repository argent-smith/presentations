# OCaml vs F#: Детальный технический разбор

## Введение: общее наследие, разные судьбы

F# начинался как порт OCaml на .NET (2002-2003), но за 20+ лет развился в отдельный язык с собственными фичами. Оба делят ML-корень (Hindley-Milner type inference, ADTs, pattern matching), но расходятся в модульной системе, async-модели, метапрограммировании и интеграции с экосистемами.

---

## 1. Синтаксис и базовые конструкции

### 1.1 Let bindings и scope

**OCaml** требует `in` для локальных bindings:
```ocaml
let x = 10 in
let y = 20 in
x + y
```

**F#** делает `in` опциональным (почти никогда не используется):
```fsharp
let x = 10
let y = 20
x + y
```

F# позволяет top-level выражения без binding к `()`, OCaml требует:
```ocaml
let () = printf "hello\n"
let () = printf "world\n"
```

### 1.2 Мутабельность

**OCaml**: 
```ocaml
let x = ref 10
x := !x + 5  (* dereferencing с ! и assignment с := *)
```

**F#**: 
```fsharp
let mutable x = 10
x <- x + 5   (* чище, с operator <- *)
```

F# подход ближе к Rust и даёт compiler error при попытке mutate non-mutable.

### 1.3 Pattern matching

Синтаксис практически идентичен, но есть нюанс — **active patterns в F#** (см. раздел 3.4).

**OCaml**:
```ocaml
match x with
| Some v -> v
| None -> 0
```

**F#**:
```fsharp
match x with
| Some v -> v
| None -> 0
```

### 1.4 Records и Variants

**Records**: почти идентичны

OCaml:
```ocaml
type person = { name : string; age : int }
let p = { name = "Alice"; age = 30 }
```

F#:
```fsharp
type Person = { Name : string; Age : int }
let p = { Name = "Alice"; Age = 30 }
```

Небольшая разница: F# требует uppercase для типов и конструкторов.

**Variants / Discriminated Unions**: 

OCaml:
```ocaml
type shape =
  | Circle of float
  | Rectangle of float * float
```

F#:
```fsharp
type Shape =
  | Circle of float
  | Rectangle of float * float
```

---

## 2. Система типов

### 2.1 GADTs (Generalized Algebraic Data Types)

**OCaml поддерживает нативно с 4.00 (2012)**, F# — **НЕТ**.

GADTs позволяют конструкторам специфицировать точные типы:

```ocaml
(* OCaml *)
type _ term =
  | Int : int -> int term
  | Bool : bool -> bool term
  | Add : int term * int term -> int term
  | If : bool term * 'a term * 'a term -> 'a term

let rec eval : type a. a term -> a = function
  | Int n -> n
  | Bool b -> b
  | Add (x, y) -> eval x + eval y
  | If (cond, t, e) -> if eval cond then eval t else eval e
```

В F# это приходится делать через **типы-свидетели или phantom types**, что громоздко:

```fsharp
// F# workaround — не эквивалентно
type Term<'a> = 
  | Int of int
  | Bool of bool
  (* проверки типов на runtime *)
```

**Практическое применение GADTs**: type-safe DSL, typed AST для компиляторов, embedding strongly-typed languages. Jane Street активно использует для торговых систем.

### 2.2 Polymorphic Variants (только OCaml)

**OCaml** имеет полиморфные варианты — варианты **без предварительного объявления типа**:

```ocaml
let color_to_string = function
  | `Red -> "red"
  | `Green -> "green"
  | `Blue -> "blue"
  (* автоматический инфер типа: [< `Red | `Green | `Blue ] -> string *)

(* можно расширять "на лету" *)
let extended_color = function
  | `Red -> "red"
  | `Green -> "green"
  | `Blue -> "blue"
  | `Alpha a -> Printf.sprintf "alpha %f" a
```

**Типы с `<` и `>`:**
- `[> `A | `B]` — "эти теги или более" (open для extension)
- `[< `A | `B]` — "эти теги или меньше" (closed, для pattern matching)

**F# НЕ имеет полиморфных вариантов**. Все discriminated unions должны быть объявлены явно.

**Недостатки polymorphic variants**:
- Более слабая дисциплина типов
- Легче допустить ошибку (тайпо в `\`Red` vs `\`Rde`)
- Меньше оптимизаций

**Когда они полезны**: библиотеки с extensible error types, быстрое прототипирование.

### 2.3 Units of Measure (только F#)

**F# имеет встроенную поддержку units of measure** — compile-time dimensional analysis:

```fsharp
[<Measure>] type m   // meters
[<Measure>] type s   // seconds
[<Measure>] type kg  // kilograms

let distance = 100.0<m>
let time = 10.0<s>
let speed = distance / time  // автоматически 10.0<m/s>

[<Measure>] type N = kg * m / s^2  // derived units

let mass = 5.0<kg>
let acceleration = 2.0<m/s^2>
let force = mass * acceleration  // 10.0<N>
```

**Units стираются в runtime** (zero-cost abstraction), но проверяются в compile-time.

**OCaml НЕ имеет units of measure**. Можно эмулировать через phantom types, но громоздко:

```ocaml
type 'a meter = Meter of float
type 'a second = Second of float

(* сложно и неудобно *)
```

**Killer use case**: scientific computing, physics engines, embedded systems (Mars Climate Orbiter погиб из-за unit mismatch).

### 2.4 Type Inference

Оба языка используют **Hindley-Milner**, но с различиями:

**OCaml**:
- Более строгий value restriction (из-за mutable refs)
- Polymorphic recursion требует явных аннотаций
- GADTs требуют locally abstract types: `let rec f : type a. a term -> a = ...`

**F#**:
- Мягче с value restriction
- Automatic generalization в большинстве случаев
- **Operator overloading** (через static member constraints) требует явных аннотаций

```fsharp
let inline add x y = x + y  // работает для любого типа с (+)
```

OCaml не имеет operator overloading напрямую — нужны functors или manual ad-hoc.

---

## 3. Продвинутые языковые фичи

### 3.1 Модульная система

**OCaml: Functors** — параметризация модуля модулем:

```ocaml
module type ORDERED = sig
  type t
  val compare : t -> t -> int
end

module Make_set (Ord : ORDERED) = struct
  type elt = Ord.t
  type t = elt list
  
  let empty = []
  let add x s = if List.mem x s then s else x :: s
  let mem = List.mem
end

module IntSet = Make_set(struct
  type t = int
  let compare = Int.compare
end)
```

**F# НЕ имеет functors**. Вместо этого — **generic interfaces**:

```fsharp
type IOrdered<'T> =
  abstract Compare : 'T -> 'T -> int

type Set<'T>(comparer: IOrdered<'T>) =
  (* runtime dispatch через interface *)
  member _.Add x = ...
```

**Разница критична:**
- Functors — compile-time, monomorphization, no runtime overhead
- Interfaces — runtime dispatch, vtable lookup

Jane Street использует functors для zero-cost abstractions в HFT.

**First-class modules в OCaml** (с 3.12):

```ocaml
module type S = sig type t val show : t -> string end

let print_it (type a) (module M : S with type t = a) (x : a) =
  print_endline (M.show x)

(* можно передавать модули как значения *)
let modules = [
  (module Int_module : S);
  (module String_module : S);
]
```

F# не имеет first-class modules, но это менее критично из-за .NET OOP.

### 3.2 Objects (OCaml) vs .NET Classes (F#)

**OCaml имеет native объектную систему** (structural typing):

```ocaml
class point x_init =
  object (self)
    val mutable x = x_init
    method get_x = x
    method move d = x <- x + d
  end

let p = new point 0
let _ = p#move 5
```

Structural typing:
```ocaml
let get_x obj = obj#get_x  (* работает для любого объекта с методом get_x *)
```

**F# использует .NET классы** (nominal typing):

```fsharp
type Point(xInit: int) =
  let mutable x = xInit
  member _.GetX() = x
  member _.Move(d) = x <- x + d

let p = Point(0)
p.Move(5)
```

OCaml objects почти не используются в practice (Jane Street избегает). F# classes — стандартный способ OOP для .NET interop.

### 3.3 Computation Expressions (F#) vs Monadic Syntax (OCaml)

**F# computation expressions** — мощная синтаксическая абстракция:

```fsharp
type MaybeBuilder() =
  member _.Bind(x, f) = Option.bind f x
  member _.Return(x) = Some x

let maybe = MaybeBuilder()

let compute = maybe {
  let! x = Some 5
  let! y = Some 10
  return x + y
}  // Some 15
```

Computation expressions не привязаны к монадам — поддерживают:
- Monads (`let!` / `Bind`)
- Applicatives (`let! ... and! ...` / `BindReturn`)
- Monoids (`for ... yield` / `Combine`)
- Custom control flow (`try/with`, `while`)

**OCaml syntax для монад** появился в 4.08 (2019):

```ocaml
let* x = Some 5 in
let* y = Some 10 in
return (x + y)

(* требует определить operators *)
let ( let* ) = Option.bind
let return x = Some x
```

OCaml syntax проще, но менее гибкий:
- Только монады (`let*`)
- Аппликативы (`let+`, `and+`)
- Нет custom control flow

**F# также поддерживает `async` и `task` computation expressions** — native async/await без монад.

### 3.4 Active Patterns (только F#)

**Active patterns** — extensible pattern matching:

```fsharp
// Partial active pattern
let (|Even|Odd|) n =
  if n % 2 = 0 then Even else Odd

match 5 with
| Even -> "even"
| Odd -> "odd"

// Parameterized active pattern
let (|DivisibleBy|_|) divisor n =
  if n % divisor = 0 then Some() else None

match 15 with
| DivisibleBy 3 -> "divisible by 3"
| _ -> "not divisible"
```

**OCaml НЕ имеет active patterns**. Приходится делать через функции:

```ocaml
let is_even n = n mod 2 = 0

match n with
| n when is_even n -> "even"
| _ -> "odd"
```

Active patterns полезны для:
- Parsing (regex patterns)
- View patterns (decomposing complex types)
- API cleanup

### 3.5 Metaprogramming: PPX (OCaml) vs Type Providers (F#)

**OCaml: PPX** — AST rewriting на уровне Parsetree:

```ocaml
type person = {
  name : string;
  age : int;
} [@@deriving show, yojson]

(* ppx_deriving генерирует *)
val show_person : person -> string
val person_of_yojson : Yojson.Safe.t -> person
val person_to_yojson : person -> Yojson.Safe.t
```

PPX работает как компилятор-к-компилятору трансформация. Популярные ppx:
- `ppx_deriving` — boilerplate generation
- `ppx_sexp_conv` — s-expression serialization (Jane Street)
- `ppx_jane` — full Jane Street stack
- `ppx_blob` — embedding files

**F# Type Providers** — code generation на основе внешних схем:

```fsharp
type WorldBank = WorldBankDataProvider<"World Development Indicators", Asynchronous=true>

let data = WorldBank.GetDataContext()
let france = data.Countries.France
let gdp = france.Indicators.``GDP (current US$)``
```

Type providers генерируют типы из:
- SQL databases
- JSON/XML/CSV schemas
- REST APIs (Swagger/OpenAPI)
- R/MATLAB data sources

**Сравнение:**
- PPX: compile-time AST rewriting, работает на OCaml AST
- Type Providers: compile-time code generation из external schemas, работает на .NET metadata

Оба мощные, но применяются по-разному. PPX — для boilerplate, Type Providers — для interop с внешними данными.

### 3.6 Algebraic Effects (только OCaml 5+)

**OCaml 5.0 (2022)** добавил **algebraic effects and handlers**:

```ocaml
effect Yield : unit

let rec countdown n =
  if n = 0 then ()
  else begin
    Printf.printf "%d\n" n;
    perform Yield;
    countdown (n - 1)
  end

let () =
  try countdown 3 with
  | effect Yield k ->
      Printf.printf "yielding...\n";
      continue k ()
```

Output:
```
3
yielding...
2
yielding...
1
yielding...
```

**Effects используются для:**
- Cooperative concurrency (Eio library)
- Generators и coroutines
- Async I/O без монад
- Exception handlers с continuation

**F# НЕ имеет algebraic effects**. Async делается через computation expressions (`async { }`) — синтаксический сахар над .NET Task/Async.

Effects дают OCaml конкурентную edge — можно писать async код в direct-style без монад:

```ocaml
(* прямой стиль с effects *)
let fetch url =
  let response = Http.get url in
  let body = Http.read response in
  parse_json body

(* vs F# async *)
let fetch url = async {
  let! response = Http.getAsync url
  let! body = Http.readAsync response
  return parse_json body
}
```

Effects ещё "untyped" в OCaml (нет effect system), но Jane Street работает над typed effects.

---

## 4. Практические различия

### 4.1 Async и Concurrency

**F#**:
- `async { }` — computation expressions для async
- `task { }` (F# 6+) — native .NET Task support
- TPL (Task Parallel Library) — mature threading

```fsharp
let fetchData url = async {
  use client = new HttpClient()
  let! response = client.GetAsync(url) |> Async.AwaitTask
  let! content = response.Content.ReadAsStringAsync() |> Async.AwaitTask
  return content
}
```

**OCaml**:
- Исторически: **Lwt** vs **Async** (Jane Street) — несовместимы
- OCaml 5: **Eio** — effects-based I/O

```ocaml
(* Eio — прямой стиль *)
let fetch_data url =
  let response = Http.get url in
  Http.read_body response

(* Lwt — монадический *)
let fetch_data url =
  let open Lwt.Syntax in
  let* response = Http.get url in
  Http.read_body response
```

F# имеет **единый async подход** (хотя async/task — разные). OCaml имеет **3 несовместимых async библиотеки** (Lwt, Async, Eio) — фрагментация.

### 4.2 Interop с другими языками

**F#**: бесшовный .NET interop
```fsharp
open System.Collections.Generic

let dict = Dictionary<string, int>()
dict.Add("hello", 5)

// любая C# библиотека работает "из коробки"
```

**OCaml**: C bindings через ctypes
```ocaml
(* требует явного FFI *)
let c_function = 
  foreign "c_function" (int @-> returning int)
```

F# выигрывает для enterprise integration, OCaml — для low-level systems programming.

### 4.3 Error Handling

**Result types** — в обоих:

OCaml:
```ocaml
type ('a, 'e) result = Ok of 'a | Error of 'e

let divide x y =
  if y = 0 then Error "division by zero"
  else Ok (x / y)
```

F#:
```fsharp
type Result<'T, 'E> = Ok of 'T | Error of 'E

let divide x y =
  if y = 0 then Error "division by zero"
  else Ok (x / y)
```

F# добавляет **railway-oriented programming** через computation expressions:

```fsharp
type ResultBuilder() =
  member _.Bind(x, f) = Result.bind f x
  member _.Return(x) = Ok x

let result = ResultBuilder()

let workflow = result {
  let! x = divide 10 2
  let! y = divide x 2
  return y + 1
}
```

### 4.4 Memory representation и производительность

**OCaml**:
- Uniform representation (все значения — tagged pointer или immediate)
- Компактная memory layout
- Predictable GC pauses (generational GC)

**F#**:
- .NET CLR memory model
- Boxed value types для generics
- Более тяжёлый GC (но с concurrent GC в .NET Core)

Для CPU-bound однопоточных задач OCaml часто быстрее. Для параллелизма F# выигрывает (mature .NET threading).

---

## 5. Что можно в одном, но нельзя в другом

### Только в OCaml:
1. **GADTs** — typed AST, typed DSL, type-level programming
2. **Polymorphic variants** — extensible error types без boilerplate
3. **Functors** — zero-cost module parametrization
4. **First-class modules** — модули как значения
5. **Algebraic effects** (OCaml 5+) — direct-style async без монад
6. **Phantom types** — более мощные
7. **Modular implicits** (experimental) — type classes без runtime cost

### Только в F#:
1. **Units of measure** — dimensional analysis
2. **Active patterns** — extensible pattern matching
3. **Type providers** — codegen из external schemas
4. **Computation expressions** — гибкие монадические абстракции с control flow
5. **Operator overloading** — через static member constraints
6. **Native .NET interop** — бесшовная интеграция с C#/ecosystem
7. **LINQ support** — query expressions

---

## 6. Типичные задачи — как решать в каждом языке

### Задача: Type-safe AST для DSL

**OCaml (с GADTs)**:
```ocaml
type _ expr =
  | Int : int -> int expr
  | Bool : bool -> bool expr
  | Add : int expr * int expr -> int expr
  | Eq : 'a expr * 'a expr -> bool expr

let rec eval : type a. a expr -> a = function
  | Int n -> n
  | Bool b -> b
  | Add (x, y) -> eval x + eval y
  | Eq (x, y) -> eval x = eval y
```

**F# (workaround с runtime checks)**:
```fsharp
type Expr =
  | Int of int
  | Bool of bool
  | Add of Expr * Expr
  | Eq of Expr * Expr

let rec eval = function
  | Int n -> box n
  | Bool b -> box b
  | Add (x, y) -> 
      match eval x, eval y with
      | (:? int as a), (:? int as b) -> box (a + b)
      | _ -> failwith "type error"
  | Eq (x, y) -> box (eval x = eval y)
```

OCaml подход type-safe, F# требует runtime checks или более сложные workarounds.

### Задача: Monadic error handling

**OCaml (с let* syntax)**:
```ocaml
let ( let* ) = Result.bind

let workflow x y z =
  let* a = divide x y in
  let* b = divide a z in
  Ok (b + 1)
```

**F# (с computation expressions)**:
```fsharp
let result = ResultBuilder()

let workflow x y z = result {
  let! a = divide x y
  let! b = divide a z
  return b + 1
}
```

F# синтаксис более читаемый, OCaml — более explicit.

### Задача: Generic data structure с custom comparison

**OCaml (functors)**:
```ocaml
module Make_set(Ord : sig
  type t
  val compare : t -> t -> int
end) = struct
  type elt = Ord.t
  type t = elt list
  (* zero runtime cost *)
end
```

**F# (interfaces)**:
```fsharp
type Set<'T when 'T :> IComparable<'T>>() =
  (* runtime dispatch через vtable *)
```

OCaml — compile-time, F# — runtime overhead.

---

## 7. Миграция кода между языками

### Что переносится легко:
- Базовые функции (map, fold, filter)
- Pattern matching
- Records и простые ADT
- Большинство type inference

### Что требует переписывания:
- Модульная система (functors → interfaces)
- GADTs (нет эквивалента в F#)
- Async (3 библиотеки в OCaml vs `async { }` в F#)
- Objects (structural vs nominal typing)
- Metaprogramming (PPX vs Type Providers)

**F# имел "ML compatibility mode"** для компиляции OCaml подмножества, но это legacy feature.

---

## Заключение

**OCaml** — для тех, кто хочет:
- Мощную систему типов (GADTs, phantom types)
- Zero-cost abstractions (functors)
- Algebraic effects для concurrency
- Minimal runtime, предсказуемость
- Работать на формальной верификацией/компиляторами

**F#** — для тех, кто хочет:
- Доступ к .NET экосистеме
- Units of measure для scientific computing
- Computation expressions для readable async
- Active patterns для extensible matching
- Enterprise integration и готовые библиотеки

Оба языка прекрасны для функционального программирования, но решают разные классы задач в разных экосистемах.
