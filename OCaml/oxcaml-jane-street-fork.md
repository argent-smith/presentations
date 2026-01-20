# OxCaml: экспериментальный форк OCaml от Jane Street

Компания Jane Street, торгующая триллионами долларов и использующая более **12 миллионов строк OCaml-кода**, официально представила **14 июня 2025 года** свой production-компилятор под брендом OxCaml. Это не просто форк — это лаборатория расширений для performance-oriented программирования, где каждое изменение проходит боевое крещение на реальных торговых системах.

Ключевая философия проекта: «безопасный, удобный, предсказуемый контроль над производительностью — но только там, где это нужно, и всё ещё в OCaml». Любая валидная OCaml-программа остаётся валидной OxCaml-программой. Расширения — opt-in, а не обязательство.

## Философия и статус проекта

OxCaml существует в двойственном состоянии: это одновременно **production-компилятор Jane Street** и **экспериментальный язык**. Расширения не гарантируют обратную совместимость между версиями, однако базовая совместимость с upstream OCaml сохраняется полностью. Репозиторий `ocaml-flambda/ocaml-jst` содержит более **30 000 коммитов** от **306 контрибьюторов**.

Основные авторы — **Leo White** (фронтенд компилятора, система типов), **Stephen Dolan** (дизайн системы modes), **Richard Eisenberg** (unboxed types, kinds), **Max Slater** (бэкенд, performance analysis). Активно участвует команда Tarides во главе с **KC Sivaramakrishnan** — именно они помогли upstream'ить multicore OCaml в версию 5.0.

В октябре 2025 на ICFP/SPLASH **Yaron Minsky** объявил, что production-серверы Jane Street перешли на runtime OCaml 5 — важная веха, подтверждающая зрелость технологии.

---

## Modes: сердце системы типов OxCaml

Modes — это глубокие свойства значений, описывающие не *что* это за данные, а *как* их можно использовать. Типы отвечают на вопрос «что?», modes — на вопрос «как?». Каждый mode принадлежит определённой оси и образует решётку с отношением субтипирования.

### Locality: стек vs куча

Ось locality определяет, может ли значение «сбежать» из своего региона памяти. Режим `local` означает, что значение можно разместить на стеке, а режим `global` — что оно может жить на куче сколь угодно долго.

```ocaml
(* local-значение размещается на стеке и не может покинуть функцию *)
let process_locally () =
  let x @ local = stack_ { foo = 42; bar = "test" } in
  compute x  (* x не может быть возвращён или сохранён в глобальную переменную *)

(* Аннотация в сигнатуре *)
val process : 'a @ local -> unit

(* exclave_ позволяет вернуть local-значение в регион вызывающего *)
let make_pair a = exclave_
  let result = stack_ (a, a + 1) in
  result
```

Типы вроде `int`, которые никогда не аллоцируются на куче, свободно «пересекают» locality — их можно использовать в любом контексте.

### Portability: безопасность для параллелизма

Ось portability контролирует возможность передачи значения между потоками. Функции, захватывающие изменяемое состояние, автоматически становятся `nonportable`.

```ocaml
(* Этот счётчик захватывает мутабельный ref — он nonportable *)
let counter =
  let count = ref 0 in
  fun () -> count := !count + 1; !count

(* Parallel.fork_join требует portable-функции *)
val parallel_map : f:('a -> 'b) @ portable -> 'a array -> 'b array

(* Ошибка компиляции: gensym захватывает состояние *)
let gensym_n par n =
  Par_array.init par n ~f:(fun _ -> gensym ())
  (* Error: gensym is nonportable *)
```

### Contention: предотвращение data races

Ось contention отслеживает, было ли значение разделено между потоками. Иерархия: `uncontended` < `shared` < `contended`. Изменяемые поля можно читать и писать только у `uncontended`-значений.

```ocaml
type person = { name: string; mutable mood: mood }

(* Contended-значение: можно читать иммутабельные поля *)
let get_name (t @ contended) = t.name  (* OK *)

(* Contended-значение: нельзя модифицировать *)
let cheer_up (t @ contended) = t.mood <- Happy  (* Ошибка компиляции! *)

(* Только uncontended позволяет мутацию *)
let update (t @ uncontended) = t.mood <- Happy  (* OK *)
```

### Uniqueness: отслеживание единственной ссылки

Режим `unique` означает, что на значение существует ровно одна ссылка. Это открывает путь к безопасному освобождению памяти и in-place модификациям.

```ocaml
(* API безопасного аллокатора *)
module type S = sig
  type 'a t
  val alloc : 'a -> 'a t @ unique
  val free : 'a t @ unique -> unit  (* Требует уникальную ссылку *)
  val get : 'a t @ unique -> 'a Modes.Aliased.t * 'a t @ unique
  val set : 'a t @ unique -> 'a -> 'a t @ unique
end

(* Использование: free консюмирует ссылку *)
let okay r =
  let v, r = get r in
  let r = set r 20 in
  free r  (* r больше недоступен — use-after-free невозможен *)
```

### Linearity: контроль количества вызовов

Режим `once` означает, что функцию можно вызвать максимум один раз. Это особенно важно, когда замыкание захватывает unique-значение.

```ocaml
let make_disposer (resource @ unique) =
  fun () -> free resource  (* Замыкание становится once *)

let danger () =
  let t = alloc 42 in
  let f () = free t in
  f ();  (* OK *)
  f ()   (* Ошибка: f уже вызван, повторный вызов запрещён *)
```

### Дополнительные оси modes

OxCaml определяет ещё несколько осей: **visibility** (`read_write` / `read` / `immutable`) контролирует доступ к полям, **statefulness** (`stateless` / `observing` / `stateful`) отслеживает побочные эффекты замыканий, **forkable** и **yielding** управляют поведением при fork/join.

---

## Unboxed types и система layouts

### Unboxed числовые типы

OxCaml предоставляет типы, хранящиеся без указателей — напрямую в регистрах или inline в структурах данных.

```ocaml
(* Unboxed типы с суффиксом # *)
type float#     (* 64-bit float, layout float64 *)
type int32#     (* 32-bit integer, layout bits32 *)
type int64#     (* 64-bit integer, layout bits64 *)
type float32#   (* 32-bit float, layout float32 *)

(* SIMD-векторы для 128-битных операций *)
type float64x2# (* 2 × float64, layout vec128 *)
type int32x4#   (* 4 × int32, layout vec128 *)

(* Литералы используют префикс # *)
let pi = #3.14159           (* float# *)
let answer = #42l           (* int32# *)
let big = -#9999999999L     (* int64# *)
```

### Unboxed products: кортежи и записи без аллокаций

Unboxed tuples и records позволяют группировать данные без создания объекта на куче.

```ocaml
(* Unboxed tuple — элементы передаются в регистрах *)
type point = #(float# * float#)

let flip : #(int * float# * lbl:string) -> #(lbl:string * float# * int) =
  fun #(x, y, ~lbl:z) -> #(~lbl:z, y, x)

(* Unboxed record *)
type vec = #{ x : float#; y : float# }

let add #{ x = x1; y = y1 } #{ x = x2; y = y2 } =
  #{ x = Float_u.add x1 x2; y = Float_u.add y1 y2 }

(* Проекция поля через .# *)
let get_x t = t.#x
```

### or_null: Option без аллокации

Тип `or_null` использует null-указатель для представления отсутствия значения, избегая аллокации.

```ocaml
type ('a : value) or_null : value_or_null

let none : string or_null = Null
let some : string or_null = This "hello"

let process x = match x with
  | Null -> "nothing"
  | This s -> String.uppercase_ascii s

(* Нельзя вкладывать or_null: string or_null or_null — ошибка *)
```

### Система layouts

Каждый тип имеет layout — описание его представления в памяти. Layout образует иерархию: `immediate` < `immediate64` < `value` < `value_or_null`. Независимые layouts: `float64`, `bits32`, `bits64`, `vec128`, `word`, `void`.

```ocaml
(* Layout-аннотации на типовых переменных *)
type ('a : immediate) atomic_ref
type ('a : float64) fast_array
type ('a : bits32, 'b : value) mixed

(* Layout в сигнатурах модулей *)
module type FloatOps = sig
  type t : float64
  val add : t -> t -> t
  val mul : t -> t -> t
end
```

---

## Система kinds: классификация типов

Kinds в OxCaml имеют четыре компонента: **layout**, **modal bounds**, **with-bounds** и **non-modal bounds**.

```ocaml
(* Полный kind типа int (упрощённо) *)
(* value mod global contended portable aliased many ... *)

(* Kind-аннотация с modal bounds *)
type t : value mod portable contended

(* With-bounds для контейнеров *)
type 'a list : immutable_data with 'a
(* int list : immutable_data (int пересекает все оси) *)
(* (int -> int) ref list : value (ref не пересекает) *)

(* Non-modal bounds *)
type t : value mod non_null      (* не может быть null *)
type u : value mod separable     (* известно float или non-float *)
```

Предопределённые сокращения kinds упрощают использование: `immutable_data` означает `value mod contended portable many immutable stateless forkable unyielding`.

---

## Fearless concurrency: гарантии отсутствия data races

OxCaml статически исключает data races через систему типов. В отличие от OCaml 5, где data races возможны (хотя безопасны благодаря memory model), OxCaml гарантирует их отсутствие на этапе компиляции.

### Capsules: регионы с контролируемым доступом

Capsules — это регионы мутабельного состояния, доступ к которым контролируется через специальные токены.

```ocaml
(* Создание инкапсулированного состояния *)
let capsule_ref = Capsule.Data.create (fun () -> ref 0)
(* Type: (int ref, 'k) Capsule.Data.t *)

(* Три механизма доступа *)
type 'k Access.t    (* Доказательство текущего capsule *)
type 'k Password.t  (* Разрешение войти в capsule, всегда local *)
type 'k Key.t       (* Сам capsule, уникальный *)

(* Доступ через unwrap *)
let increment ~(access : 'k Capsule.Access.t) capsule_ref =
  let ref = Capsule.Data.unwrap ~access capsule_ref in
  ref := !ref + 1
```

### Fork-join параллелизм

Библиотека `Parallel` предоставляет fork-join API с гарантиями безопасности.

```ocaml
(* Сигнатура fork_join2 *)
val fork_join2 
  :  t @ local 
  -> (t @ local -> 'a) @ local once 
  -> (t @ local -> 'b) @ once portable 
  -> #('a * 'b)

(* Параллельный Fibonacci *)
let rec fib parallel n =
  match n with
  | 0 | 1 -> 1
  | n ->
    let #(a, b) = Parallel.fork_join2 parallel
      (fun parallel -> fib parallel (n - 1))
      (fun parallel -> fib parallel (n - 2))
    in a + b

(* Использование с мьютексами для shared state *)
let parallel_counter parallel =
  let (P key) = Capsule.create () in
  let mutex = Capsule.Mutex.create key in
  let counter = Capsule.Data.create (fun () -> ref 0) in
  Parallel.fork_join2 parallel
    (fun _ -> Capsule.Mutex.with_lock mutex
        ~f:(fun password -> 
          let r = Capsule.Data.unwrap ~password counter in
          r := !r + 1))
    (fun _ -> Capsule.Mutex.with_lock mutex
        ~f:(fun password -> 
          let r = Capsule.Data.unwrap ~password counter in
          r := !r + 1))
```

---

## Templates: полиморфизм по modes

OxCaml не имеет first-class полиморфизма по modes. Препроцессор `ppx_template` генерирует несколько версий функций с разными modes.

```ocaml
(* Определяем один раз, получаем версии для global и local *)
let%template id : 'a. 'a @ m -> 'a @ m = fun x -> x
  [@@mode m = (global, local)]

(* Развернётся в: *)
let id : 'a. 'a -> 'a = fun x -> x
let id__local : 'a. 'a @ local -> 'a @ local = fun x -> x

(* Инстанцирование конкретной версии *)
let f x = (id [@mode local]) x

(* Layout-полиморфизм *)
module%template [@kind k = (value, float64)] Float : sig
  type t : k
  val round_up : t -> t
end = Float [@kind k]

(* Defaults для целых модулей *)
[%%template:
  [@@@mode.default m = (global, local)]
  val min_inan : t @ m -> t @ m -> t @ m
  val max_inan : t @ m -> t @ m -> t @ m]
```

---

## Quality of Life расширения

### Polymorphic parameters

Позволяют параметрам функций иметь полиморфные типы напрямую, без обёрток.

```ocaml
type _ field = A : string field | B : int field
type t = { a : string; b : int }

(* Напрямую полиморфный параметр *)
let create (f : 'a. 'a field -> 'a) = { a = f A; b = f B }

let forty_two (type a) : a field -> a = function
  | A -> "forty two"
  | B -> 42

let r = create forty_two  (* { a = "forty two"; b = 42 } *)
```

### Labeled tuples

Именованные элементы кортежей для читаемости без накладных расходов записей.

```ocaml
let sum_and_product ints =
  let init = ~sum:0, ~product:1 in
  List.fold_left ints ~init ~f:(fun (~sum, ~product) elem ->
    ~sum:(elem + sum), ~product:(elem * product))

(* Тип: int list -> (sum:int * product:int) *)

(* Частичный паттерн-матчинг *)
let get_sum (t : sum:int * product:int) =
  let ~sum, .. = t in sum
```

### Immutable arrays

Массивы, которые нельзя изменить после создания — безопасны для параллелизма и ковариантны.

```ocaml
open Iarray.O

let arr : string iarray = [: "zero"; "one"; "two" :]
let first = arr.:(0)

(* Ковариантность — безопасное приведение типов *)
let coerced = (arr : string iarray :> string iarray)

(* Comprehensions работают *)
let pairs = [: (x, y) for x = 1 to 3 and y in [: "a"; "b" :] :]

(* Безопасны для параллелизма — не требуют uncontended *)
let sum_par par arr =
  Parallel.Sequence.of_iarray arr
  |> Parallel.Sequence.reduce par ~f:(+)
  |> Option.value ~default:0
```

### Include functor

Упрощает паттерн включения результата функтора.

```ocaml
(* Традиционный подход — требует вложенный модуль T *)
module M = struct
  module T = struct
    type t = ... [@@deriving compare, sexp]
  end
  include T
  include Comparable.Make(T)
end

(* С include functor — чище *)
module M = struct
  type t = ... [@@deriving compare, sexp]
  include functor Comparable.Make
end
```

---

## Производительность: Flambda2 и контроль аллокаций

### Flambda2: новое поколение оптимизатора

Flambda2 — CPS-based оптимизирующий middle-end, разработанный OCamlPro совместно с Jane Street. В отличие от Flambda1 (ANF-based, ~15 конструкторов IR), Flambda2 имеет всего **6 категорий** IR-конструкций и транслирует напрямую в CMM, минуя Clambda.

Jane Street полностью перешла на Flambda2 — в production **не осталось систем на Closure или Flambda1**.

Ключевые оптимизации: **speculative inlining** (inline с возможностью отката), **loopify** (преобразование tail-recursion в циклы), **constant propagation**, **dead code elimination**. Всё выполняется в единственном проходе благодаря CPS-представлению.

### Stack allocation: обход GC

Local-значения размещаются на отдельном стеке (не call stack), следующем layout minor heap. Память освобождается мгновенно при выходе из региона — без участия GC.

```ocaml
(* stack_ принудительно размещает на стеке *)
let process_fast data =
  let temp @ local = stack_ { x = data.x + 1; y = data.y * 2 } in
  compute temp  (* temp освобождается при возврате *)
```

Преимущества: одни и те же cache lines переиспользуются постоянно, аллокации никогда не триггерят GC, память немедленно доступна для переиспользования.

### Бенчмарки и production-результаты

Jane Street обрабатывает **миллионы multicast-сообщений в секунду на одном ядре**. При overhead 4 наносекунды на пакет и minor heap 256KB, аллокация даже 4 байт на сообщение вызывает GC каждые ~64 000 сообщений. Zero-alloc код критичен.

Типичные результаты перехода на Flambda: **снижение аллокаций на 20-30%**, аналогичное улучшение latency. При этом код становится «красивее и чище» — оптимизатор компенсирует абстракции.

---

## Экосистема и tooling

### Установка и платформы

OxCaml базируется на **OCaml 5.2.0** с патчами из более поздних версий. Поддерживаются **x86-64 и arm64 Linux**, **arm64 macOS**. Windows не поддерживается (рекомендуется WSL 2), как и musl-based Linux (Alpine).

```bash
# Установка через opam
opam switch create 5.2.0+ox \
  --repos ox=git+https://github.com/oxcaml/opam-repository.git,default

# Tooling
opam install ocamlformat merlin ocaml-lsp-server utop
```

### Библиотеки Jane Street

Библиотеки Base, Core и другие выпускаются в двух вариантах: **default branch** для upstream OCaml и **with-extensions branch** для OxCaml с полной поддержкой расширений.

```bash
opam install core_unix parallel base
```

---

## Upstreaming в OCaml

### Уже в OCaml 5.4 (октябрь 2025)

В upstream попали **immutable arrays** (`'a iarray`, модуль `Iarray`) и **labeled tuples** — обе фичи разработаны в OxCaml и перенесены при участии Tarides.

### Планируется в OCaml 5.5

**Include functor**, **polymorphic parameters** и **module strengthening** находятся в процессе upstreaming'а.

### Пока не готово для upstream

Modes, stack allocation, unboxed types, layouts, capsules, SIMD, comprehensions, templates — «слишком свежие и слишком в процессе изменений» (лето 2025). Планируется повторить многолетний путь upstreaming'а Multicore OCaml.

---

## Сравнение с Rust

Jane Street выбрала путь расширения OCaml вместо перехода на Rust по нескольким причинам.

**Garbage collection**: Rust требует явного управления памятью везде, OxCaml сохраняет GC по умолчанию с opt-in контролем. **Type inference**: lifetime-полиморфизм Rust делает inference неразрешимым для higher-order функций, modes OxCaml не влияют на inference. **Существующая кодовая база**: 12+ млн строк OCaml невозможно переписать, OxCaml 100% обратно совместим.

Ключевая цитата Jane Street: «Отказ от garbage collection требует тщательного учёта lifetime и ownership по всей кодовой базе. Акцент на lifetime-полиморфизме также делает type inference неразрешимым — такой design choice не подходит OCaml».

При этом OxCaml заимствует концепции из Rust: `unique` mode аналогичен ownership, linearity (`once`) напоминает `Drop` trait, capsules обеспечивают data race freedom подобно Send/Sync.

---

## Академическая база

Расширения OxCaml опираются на peer-reviewed публикации в топовых venues.

**«Oxidizing OCaml with Modal Memory Management»** (ICFP 2024) — Lorenzen, White, Dolan, Eisenberg, Lindley. Формально описывает modes для locality, uniqueness, affinity. Доказывает полную обратную совместимость и сохранение inference.

**«Data Race Freedom à la Mode»** (POPL 2025, **Distinguished Paper Award**) — Georges, Peters, Elbeheiry, White, Dolan, Eisenberg, Casinghino, Pottier, Dreyer. Расширяет modes осями contention и portability, вводит Capsules API. Включает **формальные Coq-доказательства** безопасности в framework Iris.

Артефакты верификации доступны на Zenodo для независимой проверки.

---

## Когда использовать OxCaml

**Подходит для**: high-performance систем с жёсткими latency requirements, финансовых вычислений, обработки потоков данных в реальном времени, проектов с большой существующей OCaml-кодовой базой, команд, желающих Rust-like гарантии без полного переписывания.

**Не подходит для**: проектов, требующих стабильного API расширений, Windows-разработки, небольших скриптов и прототипов (overhead изучения не оправдан), команд без опыта OCaml.

**Learning curve**: для знающего OCaml — умеренная. Modes инферятся автоматически, явные аннотации нужны редко. Основная сложность — понимание взаимодействия осей modes и их влияния на API design. Для знающего Rust — многие концепции знакомы, но механизмы отличаются.

## Заключение

OxCaml представляет уникальный подход к performance engineering: вместо отказа от GC и высокоуровневых абстракций (путь Rust), он добавляет opt-in контроль поверх существующей модели OCaml. Система modes позволяет постепенно «затягивать гайки» там, где это критично, сохраняя простоту везде остальном.

Успешный production-опыт Jane Street и академическая верификация (Coq-доказательства, награды POPL) подтверждают жизнеспособность подхода. Постепенный upstreaming фич в mainline OCaml обещает, что экосистема не останется изолированной. Для команд с существующими OCaml-проектами и потребностью в предсказуемой производительности OxCaml — наиболее прагматичный путь к Rust-like гарантиям без Rust-like компромиссов.