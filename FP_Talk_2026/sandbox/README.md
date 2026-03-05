# Песочница для демонстрации примеров кода

Инструмент для живой демонстрации кода во время доклада
"Древняя магия в повседневном коде: пять принципов функционального программирования в пяти языках".

## Структура

```
sandbox/
├── .devcontainer/
│   ├── Dockerfile           # all-in-one образ для VS Code devcontainer
│   ├── Dockerfile-ocaml     # alpine:3.21 + ocaml
│   ├── Dockerfile-scala     # Eclipse JRE 21 Alpine + glibc compat + scala-cli
│   ├── Dockerfile-rust      # rust:alpine
│   ├── Dockerfile-python    # python:3.12-alpine
│   ├── Dockerfile-js        # node:lts-alpine
│   ├── docker-compose.yml   # 5 языковых сервисов + dev (для devcontainer)
│   └── devcontainer.json    # VS Code devcontainer → сервис dev
├── Makefile                 # единственный интерфейс управления
├── run.sh                   # runner для одного свойства (вызывается из make)
├── bin/                     # скомпилированные Rust-бинари (make build)
├── 01_functions/            # Свойство 1: функции как значения
├── 02_referential/          # Свойство 2: ссылочная прозрачность
├── 03_immutability/         # Свойство 3: иммутабельность
├── 04_declarative/          # Свойство 4: декларативность
└── 05_expressions/          # Свойство 5: выражения вместо инструкций
```

Каждая директория свойства содержит пять файлов:
`ocaml.ml`, `scala.sc`, `rust.rs`, `python.py`, `javascript.js`.

---

## Архитектура

Каждый язык запускается в отдельном минимальном контейнере:

| Сервис   | Образ                                | Команда     |
|----------|--------------------------------------|-------------|
| `ocaml`  | `alpine:3.21`                        | `ocaml`     |
| `scala`  | Eclipse JRE 21 Alpine + glibc compat | `scala-cli` |
| `rust`   | `rust:alpine`                        | `rustc`     |
| `python` | `python:3.12-alpine`                 | `python3`   |
| `js`     | `node:lts-alpine`                    | `node`      |
| `dev`    | all-in-one (для devcontainer)        | —           |

`make pN` запускает пять контейнеров последовательно через `docker compose run --rm`.
Файлы `sandbox/` смонтированы во все контейнеры через bind mount.

---

## Подготовка (один раз)

Из папки `sandbox/`:

```bash
make build
```

Выполняет:

1. Сборку всех шести образов (`docker compose build`).
   Образ `scala` при сборке скачивает компилятор Scala — задержки во время доклада не будет.
2. Компиляцию Rust-примеров в `bin/` через контейнер `rust`.

---

## Использование во время доклада

```bash
make p1   # Свойство 1: функции как значения
make p2   # Свойство 2: ссылочная прозрачность
make p3   # Свойство 3: иммутабельность
make p4   # Свойство 4: декларативность
make p5   # Свойство 5: выражения вместо инструкций
```

Прогнать всё для проверки:

```bash
make all
```

Очистить скомпилированные Rust-файлы:

```bash
make clean
```

---

## Команды Makefile

| Команда      | Действие                                              |
|--------------|-------------------------------------------------------|
| `make build` | собрать образы + скомпилировать Rust в `bin/`         |
| `make p1`    | Свойство 1: функции как значения                      |
| `make p2`    | Свойство 2: ссылочная прозрачность                    |
| `make p3`    | Свойство 3: иммутабельность                           |
| `make p4`    | Свойство 4: декларативность                           |
| `make p5`    | Свойство 5: выражения вместо инструкций               |
| `make all`   | запустить все пять свойств подряд                     |
| `make clean` | удалить скомпилированные файлы из `bin/`              |
| `make`       | вывести справку                                       |

`make pN` не перекомпилирует Rust — ожидает готовый исполняемый файл в `bin/`.
Если файлов в `bin/` нет, блок Rust упадёт, остальные четыре языка отработают нормально.

---

## VS Code devcontainer

Для редактирования и запуска кода внутри VS Code:

### Требования

- VS Code с расширением [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Docker Desktop или Docker Engine с Compose

### Порядок действий

1. Открыть в VS Code папку `FP_Talk_2026/sandbox/`.
2. Принять предложение "Reopen in Container" или вызвать команду
   `Dev Containers: Reopen in Container`.
3. При первом открытии образ `dev` собирается автоматически (~2–5 минут).
4. После запуска автоматически выполнится `make build`.

Devcontainer использует сервис `dev` — all-in-one образ со всеми рантаймами.
Языковые контейнеры при этом не запускаются; `make pN` внутри devcontainer
запускает их через `docker compose run` так же, как и из CLI.

### Layout во время доклада

```
┌─────────────────────────────┬──────────────────────────────────┐
│  Explorer                   │  01_functions/ocaml.ml           │
│  ├ 01_functions/            │                                  │
│  │  ├ ocaml.ml       ←      │  let multiply factor x = ...     │
│  │  ├ scala.sc              │  let triple = multiply 3         │
│  │  ├ rust.rs               │  ...                             │
│  │  ├ python.py             ├──────────────────────────────────┤
│  │  └ javascript.js         │  TERMINAL                        │
│  ├ 02_referential/          │  $ make p1                       │
│  └ ...                      │  ════ Свойство 1 ════            │
│                             │  ━━━ OCaml ━━━━━━━━━━━━━━━━━━━   │
│                             │  3 6 9 12 15                     │
│                             │  ━━━ Scala ━━━━━━━━━━━━━━━━━━━   │
│                             │  List(3, 6, 9, 12, 15)           │
└─────────────────────────────┴──────────────────────────────────┘
```

---

## Интерактивный REPL

Четыре языка поддерживают интерактивный режим. Команды запускают соответствующий
контейнер и подключают терминал:

```bash
make repl-ocaml   # ocaml top-level
make repl-scala   # scala-cli repl
make repl-python  # python3
make repl-js      # node
```

Rust интерактивного REPL не имеет — примеры запускаются через `make pN`.

### Примеры для самостоятельного изучения

**OCaml** (`make repl-ocaml`):

```ocaml
let multiply factor x = factor * x;;
let triple = multiply 3;;
List.map triple [1; 2; 3; 4; 5];;
```

**Scala** (`make repl-scala`):

```scala
def multiply(factor: Int)(x: Int) = factor * x
val triple = multiply(3)
(1 to 5).toList.map(triple)
```

**Python** (`make repl-python`):

```python
from functools import partial
def multiply(factor, x): return factor * x
triple = partial(multiply, 3)
list(map(triple, [1, 2, 3, 4, 5]))
```

**JavaScript** (`make repl-js`):

```javascript
const multiply = factor => x => factor * x
const triple = multiply(3)
[1, 2, 3, 4, 5].map(triple)
```

---

## Ожидаемый вывод make p1

```
════════════════════════════════════════════
  Свойство 1: функции как значения
════════════════════════════════════════════

━━━ OCaml ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3 6 9 12 15

━━━ Scala ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
List(3, 6, 9, 12, 15)

━━━ Rust ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[3, 6, 9, 12, 15]

━━━ Python ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[3, 6, 9, 12, 15]

━━━ JavaScript ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[ 3, 6, 9, 12, 15 ]
```
