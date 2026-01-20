# Алгебраические эффекты в OCaml 5: полное техническое руководство

Алгебраические эффекты — это механизм управления побочными эффектами, который позволяет писать код в прямом стиле, сохраняя модульность и возможность разной интерпретации одних и тех же операций. В OCaml 5.0 (декабрь 2022) эффекты появились как часть multicore-рантайма, и они меняют подход к написанию конкурентного кода: вместо монад и callback-ов — обычные функции, которые можно «приостановить» и «возобновить». Эта статья объясняет теоретические основы, детали реализации и практические паттерны использования эффектов для опытных функциональных программистов.

## Зачем нужны алгебраические эффекты

Классическая проблема функционального программирования — работа с побочными эффектами при сохранении композиционности. Монады решают её ценой изменения сигнатур всех функций и необходимости явного «протаскивания» контекста через `bind`. Алгебраические эффекты предлагают альтернативу: эффекты объявляются как операции, а их семантика определяется обработчиками (handlers) — отдельно от места использования.

Ключевая идея: эффект — это «возобновляемое исключение». Когда код выполняет `perform SomeEffect`, управление передаётся обработчику, который получает **делимитированное продолжение** (delimited continuation) — захваченный стек вычислений до точки обработки. Обработчик решает: возобновить вычисление с результатом, отбросить продолжение (как обычное исключение), или вызвать его несколько раз (для недетерминизма).

### Сравнение с монадами и трансформерами

Монадные трансформеры страдают от нескольких фундаментальных проблем:

**Проблема n² инстансов**: если у вас n трансформеров и n типоклассов, нужно n² реализаций. `StateT` должен реализовать `MonadReader`, `MonadError` и т.д.; `ReaderT` — `MonadState`, `MonadError`; каждая комбинация требует отдельного кода.

**Порядок композиции меняет семантику**: `StateT s (Either e) a` и `EitherT e (State s) a` — разные типы с разным поведением. Первый теряет состояние при ошибке, второй сохраняет. Разработчик должен помнить порядок стека и его последствия.

**Lift-пролиферация**: код пестрит `lift $ lift $ lift $ action`, что хрупко — добавление слоя ломает все вызовы.

Алгебраические эффекты решают эти проблемы:

```ocaml
(* Два независимых состояния — невозможно с одним StateT *)
module IntState = State(struct type t = int end)
module StrState = State(struct type t = string end)

let example () =
  let n = IntState.get () in
  let s = StrState.get () in
  IntState.put (n + 1);
  StrState.put (s ^ "!")

(* Обработчики вкладываются, порядок явный *)
let _ = IntState.run ~init:0 (fun () ->
  StrState.run ~init:"" example)
```

Нет n² инстансов: каждый эффект самодостаточен. Нет lift: все эффекты «живут» в одном монадическом контексте. Порядок обработчиков явный и понятный.

### Когда эффекты выигрывают у монад

Эффекты особенно эффективны в следующих сценариях:

- **Тестирование через моки**: один код с эффектом `FileSystem`, в продакшене — реальная ФС, в тестах — in-memory mock
- **Множественные экземпляры эффекта**: два независимых `State` в одной функции
- **Динамическая смена интерпретации**: обработчик можно подменить в runtime
- **Async/await без языковой поддержки**: асинхронность — библиотечный эффект, не примитив языка

## Теоретические основы

Формальные основы заложены в работе Гордона Плоткина и Матии Претнара «Handlers of Algebraic Effects» (2009/2013). Ключевые концепции:

**Сигнатура эффектов** — набор операций `op : α ⇀ β`, где α — тип параметра, β — арность (тип результата). Примеры: `raise : exc ⇀ 0` (нет продолжения), `get : unit ⇀ state`, `choose : unit ⇀ bool`.

**Обработчик** определяется как `H = {op x (k : β → C) ↦ M_op}` — для каждой операции указано, что делать с параметром `x` и продолжением `k`. Продолжение — функция, которая при вызове возобновляет приостановленное вычисление.

**Семантическая модель**: обработчики соответствуют **моделям эквациональных теорий**. Конструкция handling интерпретируется как единственный гомоморфизм из свободной модели в модель обработчика — это объясняет, почему обработчики композиционны и «алгебраичны».

### Deep vs Shallow handlers

В OCaml реализованы оба вида обработчиков:

**Deep handlers** (модуль `Effect.Deep`) — при возобновлении продолжения обработчик **автоматически переустанавливается**. Семантически это катаморфизм (fold) по дереву вычислений. Идеальны когда все эффекты обрабатываются одинаково.

```ocaml
(* Deep: обработчик применяется ко всем perform внутри *)
try computation () with
| effect Yield, k ->
    (* Этот же обработчик будет применён при continue k *)
    continue k ()
```

**Shallow handlers** (модуль `Effect.Shallow`) — обрабатывают **только первый эффект**. Продолжение не включает обработчик; программист должен явно указать новый обработчик при возобновлении.

```ocaml
(* Shallow: контроль над каждым возобновлением *)
let rec loop state k =
  continue_with k ()
  { retc = Fun.id;
    exnc = raise;
    effc = fun eff -> match eff with
      | Send n -> Some (fun k ->
          (* Можем сменить обработчик или состояние *)
          loop_recv n k ())
      | _ -> None }
```

Ключевое различие в типах продолжений: у deep handlers тип `('a, 'b) continuation` где `'b` — результат обработчика; у shallow — `('a, 'r) continuation` где `'r` — результат исходного вычисления.

### Делимитированные продолжения

Эффекты реализованы через делимитированные продолжения — механизм захвата «среза» стека вызовов до определённой границы:

- `reset`/`prompt` — устанавливает границу (в OCaml это handler)
- `shift`/`control0` — захватывает продолжение до границы (в OCaml это perform)

Deep handlers соответствуют оператору `shift₀`, shallow — `control₀`. Эффекты предоставляют типизированный, безопасный интерфейс поверх raw-продолжений.

## Реализация в OCaml 5.x

### История появления

Проект Multicore OCaml стартовал в **2014 году** в OCaml Labs (Кембридж) под руководством Анила Мадхавапедди. KC Сивараамакришнан присоединился после PhD по multicore MLton. Ключевые вехи:

- **2015**: первые эксперименты с эффектами, «Effective Concurrency with Algebraic Effects»
- **2020**: «Retrofitting Parallelism onto OCaml» (ICFP, Distinguished Paper) — дизайн параллельного GC
- **2021**: «Retrofitting Effect Handlers onto OCaml» (PLDI) — формализация и имплементация эффектов
- **Декабрь 2022**: OCaml 5.0 — первый стабильный релиз с multicore и эффектами
- **Январь 2025**: OCaml 5.3 — нативный синтаксис для deep handlers
- **Октябрь 2025**: OCaml 5.4 — улучшения runtime и новые возможности

### Объявление эффектов через extensible variants

Эффекты объявляются расширением предопределённого типа `Effect.t`:

```ocaml
open Effect
open Effect.Deep

(* Эффект с параметром int, возвращает int *)
type _ Effect.t += Xchg : int -> int t

(* Эффект без параметров, возвращает unit *)
type _ Effect.t += Yield : unit t

(* Эффект с функцией-параметром *)
type _ Effect.t += Fork : (unit -> unit) -> unit t

(* Несколько эффектов в модуле *)
type _ Effect.t +=
  | Send : int -> unit Effect.t
  | Recv : int Effect.t
```

Параметр типа `'a` в `'a Effect.t` указывает тип возвращаемого значения при `perform`.

### API модулей Effect.Deep и Effect.Shallow

В OCaml 5.3+ рекомендуется использовать новый синтаксис `try...with | effect...` для deep handlers. Старый API с `match_with` и `try_with` остаётся доступным для обратной совместимости.

```ocaml
module Effect : sig
  type 'a t = 'a eff = ..  (* Extensible variant *)

  exception Unhandled : 'a t -> exn
  exception Continuation_already_resumed

  val perform : 'a t -> 'a

  module Deep : sig
    type ('a, 'b) continuation
    val continue : ('a, 'b) continuation -> 'a -> 'b
    val discontinue : ('a, 'b) continuation -> exn -> 'b

    type ('a, 'b) handler = {
      retc : 'a -> 'b;           (* Обработчик значения *)
      exnc : exn -> 'b;          (* Обработчик исключения *)
      effc : 'c. 'c Effect.t -> (('c, 'b) continuation -> 'b) option;
    }

    val match_with : ('c -> 'a) -> 'c -> ('a, 'b) handler -> 'b
    val try_with : ('b -> 'a) -> 'b -> 'a effect_handler -> 'a
  end

  module Shallow : sig
    type ('a, 'b) continuation
    val fiber : ('a -> 'b) -> ('a, 'b) continuation
    val continue_with : ('c, 'a) continuation -> 'c -> ('a, 'b) handler -> 'b
    val discontinue_with : ('c, 'a) continuation -> exn -> ('a, 'b) handler -> 'b
  end
end
```

### Синтаксис OCaml 5.3+

В OCaml 5.3 появился нативный синтаксис для deep handlers:

```ocaml
(* Старый API-стиль (5.0-5.2) *)
open Effect.Deep

match_with comp1 ()
{ retc = Fun.id;
  exnc = raise;
  effc = fun (type a) (eff: a t) ->
    match eff with
    | Xchg n -> Some (fun (k: (a, _) continuation) -> continue k (n+1))
    | _ -> None }

(* Новый синтаксис (5.3+) *)
try comp1 () with
| effect (Xchg n), k -> continue k (n+1)

(* match-выражение с эффектами *)
let step (f : unit -> 'a) () : 'a status =
  match f () with
  | v -> Complete v
  | effect (Xchg msg), cont -> Suspended {msg; cont}
```

Для обратной совместимости флаг `-keywords 5.2` отключает `effect` как ключевое слово.

### Реализация на уровне runtime: fibers

Эффекты реализованы через **файберы** — сегменты стека, аллоцируемые на куче:

```
Структура стека программы:
+-----+     +-----+     +-----+
|     | <-- |     | <-- |     |
| baz |     | bar |     | foo | <-- stack_pointer
|     |     |     |     |     |
+-----+     +-----+     +-----+
   ^           ^           ^
handler     frames      frames
```

Каждый обработчик создаёт новый файбер. Стек программы — **связный список файберов**.

**Характеристики реализации:**

- **Начальный размер файбера**: 32 слова (минимизирует overhead handler-а)
- **Динамический рост**: стек увеличивается по необходимости
- **Red zone**: 16 слов для tail-функций (пропуск проверки переполнения)
- **Аллокация**: `malloc`/`free` с кэшем недавно освобождённых стеков

### Захват продолжения — zero-copy

При выполнении `perform`:

```
До захвата:                      После захвата:
+-----+ +-----+ +-----+         +-----+  +-----+ +-----+
| baz |<-| bar |<-| foo |       | baz |  | bar |<-| foo |<--[k]
+-----+ +-----+ +-----+         +-----+  +-----+ +-----+
                     ^sp             ^sp
```

Критически важно: захват продолжения **не копирует стековые фреймы**. Продолжение `k` — маленький объект на куче, указывающий на цепочку файберов. `continue`/`discontinue` просто перелинковывают файберы к текущему стеку.

### One-shot continuations

OCaml использует **однократные (линейные) продолжения**:

```ocaml
open Effect
open Effect.Deep

type _ Effect.t += Xchg : int -> int t

try perform (Xchg 0) with
| effect (Xchg n), k -> continue k 21 + continue k 21
(* Exception: Stdlib.Effect.Continuation_already_resumed *)
```

Это ограничение даёт несколько преимуществ:

- **Эффективность**: не нужно копировать стек для каждого вызова
- **Линейные ресурсы**: сокеты, файлы корректно закрываются
- **Предсказуемость**: проще рассуждать о состоянии программы

Для мультишотных продолжений (backtracking, недетерминизм) используется библиотека `ocaml-multicont`.

**Важно**: нет проверки «хотя бы один раз» — неиспользованные продолжения **утекают** (файберы + ресурсы). При необходимости используйте финализаторы.

### Ограничения

**Синхронность**: эффекты нельзя выполнять из signal handlers, finalisers, memprof callbacks, GC alarms.

**Несовместимость с C callbacks**: эффекты не могут пересекать границу `caml_callback`. Если C-код вызывает OCaml-код, который делает `perform` — получим `Effect.Unhandled`.

**Отсутствие статической типизации эффектов**: в отличие от Koka или Eff, OCaml не отслеживает эффекты в типах. Необработанный эффект — runtime exception.

## Практические примеры

### Кооперативный планировщик

```ocaml
open Effect
open Effect.Deep

type _ Effect.t += Fork : (unit -> unit) -> unit Effect.t
                 | Yield : unit Effect.t

let fork f = perform (Fork f)
let yield () = perform Yield

let run main =
  let q = Queue.create () in
  let enqueue k v = Queue.push (fun () -> continue k v) q in
  let dequeue () = if Queue.is_empty q then () else Queue.pop q () in

  let rec spawn f =
    match f () with
    | v -> dequeue ()
    | exception e -> print_endline (Printexc.to_string e); dequeue ()
    | effect Yield, k -> enqueue k (); dequeue ()
    | effect (Fork f), k -> enqueue k (); spawn f
  in spawn main

(* Использование *)
let () = run (fun () ->
  fork (fun () -> print_endline "A1"; yield (); print_endline "A2");
  fork (fun () -> print_endline "B1"; yield (); print_endline "B2"))
(* A1, B1, A2, B2 *)
```

### Управление состоянием без монад

```ocaml
open Effect.Shallow

module State (S : sig type t end) = struct
  type t = S.t
  type _ Effect.t += Get : t Effect.t | Put : t -> unit Effect.t

  let get () = perform Get
  let put v = perform (Put v)

  let run f ~init =
    let rec loop : type a. t -> (a, _) continuation -> a -> _ =
      fun state k x ->
        continue_with k x {
          retc = Fun.id;
          exnc = raise;
          effc = fun (type b) (eff : b Effect.t) -> match eff with
            | Get -> Some (fun k -> loop state k state)
            | Put s' -> Some (fun k -> loop s' k ())
            | _ -> None
        }
    in loop init (fiber f) ()
end

(* Два независимых состояния *)
module IS = State(struct type t = int end)
module SS = State(struct type t = string end)

let example () =
  Printf.printf "%d, %s\n" (IS.get ()) (SS.get ());
  IS.put 42; SS.put "hello";
  Printf.printf "%d, %s\n" (IS.get ()) (SS.get ())

let () = IS.run ~init:0 (fun () -> SS.run ~init:"" example)
```

### Генераторы и ленивые последовательности

```ocaml
open Effect.Shallow

let generate (type elt) iter container : elt Seq.t =
  let module M = struct
    type _ Effect.t += Yield : elt -> unit Effect.t
  end in
  let yield v = perform (M.Yield v) in

  fun () ->
    let k = fiber (fun () -> iter yield container) in
    let rec next k =
      continue_with k () {
        retc = (fun () -> Seq.Nil);
        exnc = raise;
        effc = fun (type b) (eff : b Effect.t) -> match eff with
          | M.Yield v -> Some (fun k -> Seq.Cons (v, fun () -> next k))
          | _ -> None
      }
    in next k

(* Использование *)
let seq = generate List.iter [1; 2; 3]
let () = Seq.iter (Printf.printf "%d ") seq  (* 1 2 3 *)
```

### Async/await в прямом стиле

```ocaml
open Effect.Deep

type 'a promise = 'a _promise ref
and 'a _promise = Waiting of ('a, unit) continuation list | Done of 'a

type _ Effect.t += Async : (unit -> 'a) -> 'a promise Effect.t
                 | Await : 'a promise -> 'a Effect.t

let async f = perform (Async f)
let await p = perform (Await p)

let run main =
  let q = Queue.create () in
  let enqueue t = Queue.push t q in
  let dequeue () = if Queue.is_empty q then () else Queue.pop q () in

  let rec spawn pr f =
    match f () with
    | v ->
        let waiters = match !pr with Waiting l -> l | _ -> [] in
        pr := Done v;
        List.iter (fun k -> enqueue (fun () -> continue k v)) waiters;
        dequeue ()
    | exception e -> raise e
    | effect (Async f), k ->
        let pr = ref (Waiting []) in
        enqueue (fun () -> spawn pr f);
        continue k pr
    | effect (Await pr), k ->
        match !pr with
        | Done v -> continue k v
        | Waiting l -> pr := Waiting (k :: l); dequeue ()
  in spawn (ref (Waiting [])) main
```

### Эмуляция Lwt через эффекты

Lwt — классическая монадическая библиотека для асинхронности в OCaml. С эффектами можно получить тот же функционал в прямом стиле без монадных операторов.

**Lwt-стиль (монады):**

```ocaml
open Lwt.Syntax

let fetch_and_process url =
  let* response = Http.get url in
  let* data = Http.read_body response in
  let processed = process data in
  Lwt.return processed
```

**Effect-based стиль (прямой):**

```ocaml
open Effect.Deep

type _ Effect.t +=
  | Async : (unit -> 'a) -> 'a Effect.t
  | Sleep : float -> unit Effect.t

let async f = perform (Async f)
let sleep duration = perform (Sleep duration)

(* Код выглядит синхронным, но выполняется асинхронно *)
let fetch_and_process url =
  let response = async (fun () -> Http.get url) in
  let data = async (fun () -> Http.read_body response) in
  let processed = process data in
  processed

(* Lwt-подобный планировщик с временем *)
let run main =
  let ready_queue = Queue.create () in
  let sleep_queue = ref [] in (* (wakeup_time, continuation) list *)

  let enqueue k v = Queue.push (fun () -> continue k v) ready_queue in
  let get_time () = Unix.gettimeofday () in

  let rec schedule () =
    (* Проверяем sleep_queue *)
    let now = get_time () in
    let (woken, still_sleeping) =
      List.partition (fun (time, _) -> time <= now) !sleep_queue in
    sleep_queue := still_sleeping;
    List.iter (fun (_, k) -> enqueue k ()) woken;

    (* Запускаем следующую задачу *)
    if Queue.is_empty ready_queue then
      (* Если нет готовых, но есть спящие — ждём *)
      match !sleep_queue with
      | [] -> ()
      | (next_wake, _) :: _ ->
          let wait_time = next_wake -. now in
          if wait_time > 0.0 then Unix.sleepf wait_time;
          schedule ()
    else
      (Queue.pop ready_queue) ()

  and spawn f =
    match f () with
    | v -> schedule ()
    | exception e -> raise e
    | effect (Async f), k ->
        enqueue k (f ());
        schedule ()
    | effect (Sleep duration), k ->
        let wake_time = get_time () +. duration in
        sleep_queue := (wake_time, k) :: !sleep_queue;
        schedule ()
  in
  spawn main

(* Пример использования *)
let example () =
  Printf.printf "Task 1: start\n";
  sleep 1.0;
  Printf.printf "Task 1: after 1s\n";

  let result = async (fun () ->
    Printf.printf "Task 2: computing\n";
    sleep 0.5;
    Printf.printf "Task 2: done\n";
    42
  ) in

  Printf.printf "Task 1: got %d\n" result

let () = run example
(* Output:
   Task 1: start
   Task 2: computing
   Task 2: done
   Task 1: after 1s
   Task 1: got 42
*)
```

**Ключевые отличия от Lwt:**

| Аспект | Lwt | Effects |
|--------|-----|---------|
| **Стиль** | Монадический (`let*`, `>>=`) | Прямой (как sync код) |
| **Композиция** | Через `bind` и `map` | Обычные функции |
| **Backtraces** | Теряются через bind | Сохраняются полностью |
| **Обработка ошибок** | `Lwt.catch`, специальные комбинаторы | Обычный `try/with` |
| **Интеграция** | Весь код должен быть в `Lwt.t` | Эффекты изолированы в handler |

Эффекты позволяют писать асинхронный код, который выглядит и ведёт себя как обычный синхронный, но при этом не блокирует выполнение.

### Транзакционная память

```ocaml
open Effect.Deep

type _ Effect.t += Update : 'a ref * 'a -> unit Effect.t

let update r v = perform (Update (r, v))

let atomically f =
  let comp = match f () with
    | x -> (fun _ -> x)
    | exception e -> (fun rb -> rb (); raise e)
    | effect (Update (r, v)), k ->
        let old = !r in
        r := v;
        (fun rb -> continue k () (fun () -> r := old; rb ()))
  in comp (fun () -> ())

(* При исключении все изменения откатываются *)
let () =
  let r = ref 10 in
  (try atomically (fun () ->
    update r 20;
    update r 30;
    failwith "abort"
  ) with _ -> ());
  assert (!r = 10)  (* Откат сработал *)
```

### Eio: production-ready I/O

Eio — рекомендованная библиотека для I/O в OCaml 5. Внутри использует эффекты для неблокирующего ввода-вывода:

```ocaml
open Eio.Std

let main env =
  let clock = Eio.Stdenv.clock env in

  Fiber.both
    (fun () ->
      traceln "Task 1 starting";
      Eio.Time.sleep clock 1.0;
      traceln "Task 1 done")
    (fun () ->
      traceln "Task 2 starting";
      Eio.Time.sleep clock 0.5;
      traceln "Task 2 done")

let () = Eio_main.run main
```

Принципы Eio:

- **Прямой стиль**: код выглядит синхронным, но выполняется асинхронно
- **Capability-based**: ресурсы (сеть, FS, время) передаются явно через `env`
- **Множество бэкендов**: io_uring (Linux), kqueue (BSD/macOS), libuv

## Сравнение с другими языками

### Koka: типизированные эффекты с row polymorphism

```koka
effect yield
  ctl yield(i : int) : bool

fun traverse(xs : list<int>) : yield ()
  match xs
    Nil -> ()
    Cons(x, rest) -> yield(x); traverse(rest)

fun main()
  with handler
    return(x) -> []
    ctl yield(i) -> Cons(i, resume(True))
  traverse([1,2,3])  // [1, 2, 3]
```

Koka отслеживает эффекты в типах: `τ →⟨ε⟩ τ'`. Пустой эффект `⟨⟩` означает чистую функцию. Компилятор гарантирует, что все эффекты обработаны.

### Unison: abilities

```unison
ability Store v where
  get : v
  put : v -> ()

increment : '{Store Nat} ()
increment = 'let
  x = Store.get
  Store.put (x + 1)
```

Unison использует «abilities» — их термин для эффектов. Shallow handlers по умолчанию. Интеграция с content-addressed storage.

### Eff: исследовательский язык

Eff — язык Матии Претнара для экспериментов с семантикой эффектов. Поддерживает мультишотные продолжения «из коробки»:

```eff
effect Choice : unit -> bool

let choose_all = handler
  | effect Choice () k -> k true @ k false
  | val x -> [x]
```

### Различия в типизации

| Язык | Представление эффектов | Полиморфизм | Вывод типов |
|------|----------------------|-------------|-------------|
| **OCaml 5** | Extensible variants, нет в типах | Нет | N/A |
| **Koka** | Row types `⟨eff₁, eff₂ \| μ⟩` | Row polymorphism | Полный |
| **Unison** | Ability sets `{Ability}` | Set-based | Bidirectional |
| **Eff** | Effect signatures | Параметрический | Частичный |

OCaml сознательно выбрал отсутствие типизации эффектов ради обратной совместимости: код без эффектов остаётся валидным, а интеграция с существующими библиотеками проще.

## Заключение: когда использовать эффекты

Алгебраические эффекты в OCaml 5 — это не замена монадам, а дополнительный инструмент с другими trade-offs. Эффекты лучше подходят для concurrency и I/O в прямом стиле, динамической интерпретации операций и случаев, когда нужны множественные экземпляры одного эффекта.

Ключевые практические рекомендации:

- Используйте **Eio** для production I/O — не изобретайте свои эффекты для сетевого кода
- **Deep handlers** — default choice для большинства задач
- **Shallow handlers** — когда семантика меняется между вызовами (протоколы, state machines)
- Помните об **one-shot ограничении** — каждое продолжение используется ровно один раз
- Для **мультишотных** сценариев (backtracking, SAT) используйте `ocaml-multicont`

Формальные основы из работ Плоткина и Претнара обеспечивают эффектам прочный теоретический фундамент. Реализация в OCaml 5 через файберы даёт низкий overhead (**менее 1%** на коде без эффектов согласно PLDI 2021) и эффективное переключение контекста без участия ядра ОС. Для функционального программиста, уже знакомого с монадами, эффекты — естественное развитие идей о модульности и композиции побочных эффектов.

**Ключевые ресурсы для дальнейшего изучения:**

- Официальная документация: https://ocaml.org/manual/5.3/effects.html
- PLDI 2021 paper: «Retrofitting Effect Handlers onto OCaml» (KC Sivaramakrishnan et al.)
- Tutorial: https://github.com/ocaml-multicore/ocaml-effects-tutorial
- Примеры: https://github.com/ocaml-multicore/effects-examples
- Eio: https://github.com/ocaml-multicore/eio
