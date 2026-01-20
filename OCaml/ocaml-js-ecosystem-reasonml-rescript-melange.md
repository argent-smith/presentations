# OCaml, ReasonML, ReScript и Melange: полный обзор экосистемы ML для JavaScript

В 2020 году единая экосистема ML-языков для веб-разработки раскололась на два независимых направления: **ReScript** для JavaScript-разработчиков и **Melange** для OCaml-сообщества. Сегодня это полностью разделённые миры с разными целями, инструментарием и перспективами. OCaml остаётся фундаментом, а ReasonML — лишь альтернативным синтаксисом в режиме поддержки.

## От ML к современной экосистеме: 50 лет эволюции

История начинается в **1972-73 годах**, когда **Робин Милнер** создал ML (Meta Language) в Эдинбургском университете как язык для proof assistant LCF. Милнер формализовал систему типов Хиндли-Милнера с выводом полиморфных типов — эта инновация определила развитие функциональных языков на десятилетия вперёд.

**OCaml** появился в 1996 году в INRIA благодаря **Xavier Leroy, Jérôme Vouillon, Damien Doligez** и команде. Он вырос из линейки Caml (1987) → Caml Light (1990) → Caml Special Light (1995) и добавил объектно-ориентированный слой со статической типизацией. В 2023 году компилятор OCaml получил премию ACM SIGPLAN Programming Languages Software Award.

Веб-история началась в **2011 году** с **Js_of_ocaml** — компилятора байт-кода OCaml в JavaScript, созданного для максимальной совместимости с экосистемой. Подход работал, но генерировал трудночитаемый JavaScript с ограниченным FFI.

**BuckleScript** (2015-2016) изменил правила игры. **Hongbo Zhang** в Bloomberg создал компилятор, работающий на более ранней стадии компиляции OCaml и генерирующий читаемый JavaScript — один `.js` файл на модуль. В мае 2016 года Bloomberg открыл исходный код.

**ReasonML** (2016) — творение **Jordan Walke** из Facebook, создателя React (первый прототип которого был написан на Standard ML). Reason — это JavaScript-подобный синтаксис поверх OCaml, не отдельный язык. К 2018 году **50% кода Facebook Messenger** было написано на Reason с BuckleScript, с полной пересборкой за ~2 секунды.

**Август 2020 года** — переломный момент. BuckleScript переименовывается в **ReScript** и начинает расходиться с OCaml: новый синтаксис, отказ от совместимости, фокус исключительно на JavaScript. Через несколько недель **António Monteiro** форкает BuckleScript и начинает работу над **Melange** — альтернативой, сохраняющей интеграцию с OCaml-экосистемой через Dune.

```
ML (1972) → Standard ML → Caml (1987) → OCaml (1996)
                                              │
                                              ├── Js_of_ocaml (2011)
                                              │
                                              └── BuckleScript (2015) + ReasonML (2016)
                                                         │
                                                         ├── ReScript (2020) — отдельный язык
                                                         └── Melange (2020)  — OCaml-совместимый
```

## Технические различия: три философии компиляции в JavaScript

### Синтаксис и языковые конструкции

**OCaml** использует классический ML-синтаксис с `let...in`, `match...with`, `->` для функций и `;;` для разделения выражений в REPL:

```ocaml
let add x y = x + y
match person with
| Teacher -> "Hey Professor!"
| Student name -> "Hello " ^ name
```

**ReasonML** переосмыслил синтаксис для JavaScript-разработчиков: фигурные скобки, `=>` для функций, `switch` вместо `match`, `++` для конкатенации строк, встроенный JSX:

```reason
let add = (x, y) => x + y;
switch (person) {
| Teacher => "Hey Professor!"
| Student(name) => "Hello " ++ name
};
```

**ReScript** эволюционировал дальше — добавил нативный `async/await`, опциональные поля записей с `@optional`, убрал каррирование по умолчанию (v11), изменил синтаксис дженериков на `<>`:

```rescript
let greetUser = async (userId) => {
  let name = await getUserName(userId)
  "Hello " ++ name
}
type config = {name: string, @optional age: int}
let ids: list<int> = list{1, 4, 8}
```

**Melange** поддерживает как OCaml-синтаксис (`.ml`), так и Reason (`.re`), что позволяет командам выбирать предпочтительный стиль.

### Система типов: одна основа, разные версии

Все четыре технологии используют систему типов OCaml с выводом Хиндли-Милнера, номинальной типизацией записей и вариантов, полиморфными вариантами и модулями первого класса. Критическое различие — в версии компилятора:

| Технология | Версия OCaml | Последние возможности |
|------------|--------------|----------------------|
| **OCaml** | 5.3 (Jan 2025) | Effect handlers, multicore, binding operators |
| **Melange** | 4.14, 5.1+ | Binding operators (`let*`), современный stdlib |
| **ReScript** | 4.06 (заморожен) | Собственный AST с v12, без GADTs, без `let*` |

ReScript **12.0** (ноябрь 2025) полностью отказался от OCaml AST и перешёл на собственное представление, убрав поддержку `.ml` файлов и OCaml-операторов (`|>`, `@@`).

### Инструментарий и экосистема

**Build-системы** разошлись принципиально. Melange интегрировался с **Dune** (стандарт OCaml) начиная с Dune 3.8, получив полную поддержку монорепозиториев, инкрементальной сборки и виртуальных библиотек для шаринга кода. ReScript развивает собственную систему: **Rewatch** (Rust-based) в v12 заменил Ninja-based bsb, с улучшенной поддержкой монорепозиториев.

**Package managers**: ReScript работает исключительно через npm. Melange использует opam для OCaml-пакетов и npm для JavaScript-зависимостей. Это ключевое различие: Melange имеет доступ ко всей экосистеме opam с ~4000+ пакетов.

**Editor support**: Melange использует OCaml LSP Server и Merlin — зрелые инструменты с рефакторингом, type lenses, поддержкой PPX. ReScript развивает собственное VSCode-расширение с custom LSP.

### JavaScript interop

Обе технологии используют `external` декларации, но с разными атрибутами:

**ReScript** (декораторы с `@`):
```rescript
@module("react-hot-toast")
external toaster: unit => React.element = "Toaster"

@val @scope("localStorage")
external getItem: string => Js.Nullable.t<string> = "getItem"
```

**Melange** (атрибуты `[@mel.xxx]`):
```ocaml
external clearTimeout : timeoutId -> unit = "clearTimeout" [@@mel.val]
external john : person = "john" [@@mel.module "MySchool"]
```

Melange 5.0 добавил `Js.import` для динамических импортов и `@mel.this` для связывания `this`.

### OCaml interop: ключевое различие

**ReScript не совместим с OCaml-экосистемой**: нельзя использовать opam-пакеты, PPX ограничены и требуют pre-built бинарников, нет шаринга кода с нативным OCaml.

**Melange полностью интегрирован**: доступны все ppxlib PPX (ppx_deriving, ppx_yojson_conv, styled-ppx), source-based дистрибуция через opam, Dune virtual libraries позволяют писать код, компилируемый и в нативный OCaml, и в JavaScript.

## Кто использует эти технологии в production

### OCaml: финансы, инфраструктура, исследования

**Jane Street** — крупнейший пользователь с **500+ OCaml-программистами** и **30+ миллионами строк** кода. Всё — от торговых систем до исследовательских инструментов и бухгалтерии — написано на OCaml. Компания выпустила ~1 миллион строк open-source кода включая Dune, Base, Core. В июне 2025 анонсировала **OxCaml** — форк OCaml с фокусом на производительность и fearless concurrency.

**Meta (Facebook)** использует OCaml для **Flow** (type checker для JavaScript, 22k+ GitHub stars), **Infer** (статический анализатор), **Pyre** (type checker для Python), **Hack** (PHP с типизацией). Messenger был частично написан на Reason/BuckleScript.

**Bloomberg** создал BuckleScript для внутренних нужд — управление рисками финансовых деривативов. **Docker** использует OCaml в десктопных версиях через MirageOS. **Tezos** (блокчейн), **Citrix** (XenServer), **LexiFi** (финансовые контракты) — все на OCaml.

### Melange: OCaml-компании с веб-фронтендами

**Ahrefs** — крупнейший спонсор и пользователь Melange. Компания обрабатывает петабайты данных веб-краулинга, использует OCaml на бэкенде с ранних дней, а в 2023 году мигрировала фронтенд на Melange. У них десятки библиотек с `(modes melange)` в dune-файлах, они строят React Server Components на OCaml + Melange.

Melange выбирают компании с существующей OCaml-инфраструктурой, которым нужен единый стек для бэкенда и фронтенда с возможностью шарить код.

### ReScript: JavaScript-команды со строгой типизацией

ReScript позиционируется как альтернатива TypeScript для команд, которым нужна **sound type system** и быстрая компиляция. После ребрендинга часть Reason-пользователей мигрировала на ReScript, часть — на Melange. Конкретные компании реже публикуют кейсы, но экосистема активна: форум, Discord, ежегодные ReScript Retreat (Вена, 2024-2025).

### Где что применять

| Задача | Лучший выбор | Почему |
|--------|--------------|--------|
| **Веб-фронтенд (JavaScript background)** | ReScript | Простой toolchain, лучший JS interop, быстрая компиляция |
| **Веб-фронтенд (OCaml background)** | Melange | Единый стек с бэкендом, доступ к opam-экосистеме |
| **Full-stack с шарингом кода** | Melange + OCaml native | Dune virtual libraries компилируют код в оба таргета |
| **Бэкенд (высокая производительность)** | OCaml native | Multicore в 5.x, нативная производительность |
| **Системное ПО, CLI** | OCaml | Зрелая экосистема, стабильность |

## Текущее состояние и перспективы на 2025 год

### OCaml: отличное здоровье

**OCaml 5.3.0** вышел в январе 2025, **5.4 beta** — в октябре 2025. Шестимесячный цикл релизов, **23+ core-разработчика**, **41+ ecosystem-разработчик**. OCaml 5.x принёс революционные изменения: multicore parallelism, effect handlers, native Windows support через opam 2.2.

Финансирование стабильно: INRIA, OCaml Software Foundation, Jane Street, Tarides, OCamlPro, Ahrefs, LexiFi. Инструментарий активно развивается: Dune 3.18 с интегрированным package management, odoc 3.1, opam 2.3.0.

**Прогноз**: стабильный рост, сильнейшая институциональная поддержка среди всех ML-языков.

### ReScript: активное развитие, полное отделение от OCaml

**ReScript 12.0** (ноябрь 2025) — крупнейший релиз со времён ребрендинга. Новый build system **Rewatch** на Rust, unified operators (`+`/`-`/`*`/`/` для int/float/bigint), dict literals, regex literals, JSX preserve mode для React Compiler. Breaking changes масштабны: удалён OCaml-синтаксис, удалены curried функции, удалены OCaml-операторы.

Проект полностью community-driven через ReScript Association, спонсируется cca.io. Активный форум, Discord, ежегодные retreat.

**Прогноз**: стабильная ниша как "typed JavaScript" для команд, которым недостаточно TypeScript. Экосистема меньше TS, но качество типизации выше. Полный разрыв с OCaml завершён — это теперь отдельный язык.

### Melange: рост в OCaml-нише

**Melange 4.0** (2024) поддерживает OCaml 4.14 и 5.1. Релизы выходят регулярно: 1.0 (весна 2023), 2.0 (осень 2023), 3.0 (февраль 2024), 4.0 (май 2024). Maintainer — António Monteiro, основной спонсор — Ahrefs.

Сильные стороны: полная интеграция с Dune/opam, OCaml LSP, ppxlib-экосистема, возможность шарить код между native и JS. Слабые стороны: меньшее сообщество чем у ReScript, более сложный toolchain для новичков.

**Прогноз**: отличный выбор для OCaml-компаний, нуждающихся в JavaScript-фронтенде. Растёт вместе с OCaml-экосистемой.

### ReasonML: режим поддержки

**Reason 3.17.2** (ноябрь 2024) — updates только для совместимости с новыми версиями OCaml (5.3, 5.4). Maintainer — тот же António Monteiro. Проект "completely idle aside from occasional maintenance" по словам сообщества.

ReasonML теперь — просто альтернативный синтаксис для тех, кто предпочитает фигурные скобки. Используется с Melange или нативным OCaml, не с ReScript.

**Прогноз**: будет поддерживаться пока нужен Melange-пользователям, но новых features не ожидается.

## Рекомендации по выбору

**Выбирайте ReScript если**:
- Приходите из JavaScript/TypeScript
- Строите frontend-only приложения
- Хотите максимально простой toolchain (только npm)
- Не нужна совместимость с OCaml
- Цените скорость компиляции

**Выбирайте Melange если**:
- Уже используете OCaml на бэкенде
- Нужен шаринг кода между frontend и backend
- Хотите полную мощь OCaml (GADTs, binding operators, последний stdlib)
- Предпочитаете зрелый tooling (Dune, OCaml LSP)
- Планируете использовать PPX

**Выбирайте нативный OCaml если**:
- Строите серверы, CLI, системное ПО
- Нужен multicore parallelism
- Не нужен JavaScript output

Миграция между ReScript и Melange затруднена из-за расхождения синтаксиса и tooling. Миграция с Reason на Melange — естественный путь (тот же синтаксис, тот же maintainer). Экосистема стабилизировалась после раскола 2020 года, и сегодня это два параллельных мира с чёткой дифференциацией.