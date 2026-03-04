# Песочница для демонстрации примеров кода

Инструмент для живой демонстрации кода во время доклада
"Древняя магия в повседневном коде: пять принципов функционального программирования в пяти языках".

## Структура

```
sandbox/
├── .devcontainer/
│   ├── Dockerfile          # образ с пятью рантаймами
│   ├── docker-compose.yml  # монтирует sandbox/ в /sandbox, держит контейнер живым
│   └── devcontainer.json   # настройки VS Code devcontainer
├── Makefile                # основные команды
├── run.sh                  # runner для одного свойства
├── bin/                    # скомпилированные Rust-бинари (make build)
├── 01_functions/           # Свойство 1: функции как значения
├── 02_referential/         # Свойство 2: ссылочная прозрачность
├── 03_immutability/        # Свойство 3: иммутабельность
├── 04_declarative/         # Свойство 4: декларативность
└── 05_expressions/         # Свойство 5: выражения вместо инструкций
```

Каждая директория свойства содержит пять файлов:
`ocaml.ml`, `scala.sc`, `rust.rs`, `python.py`, `javascript.js`.

---

## Запуск из командной строки

Все команды выполняются из корня репозитория (папки `presentations/`).

### 1. Собрать образ

```bash
docker compose -f FP_Talk_2026/sandbox/.devcontainer/docker-compose.yml build
```

Выполняется один раз. При изменении Dockerfile — повторить.

### 2. Запустить контейнер в фоне

```bash
docker compose -f FP_Talk_2026/sandbox/.devcontainer/docker-compose.yml up -d
```

Контейнер держится живым (`sleep infinity`). Файлы `sandbox/` смонтированы
в `/sandbox` — изменения в файлах немедленно доступны внутри контейнера.

### 3. Скомпилировать Rust-примеры

```bash
docker compose -f FP_Talk_2026/sandbox/.devcontainer/docker-compose.yml \
  exec sandbox make build
```

Выполняется один раз перед докладом. Бинари сохраняются в `sandbox/bin/`
и доступны через bind mount при следующих запусках.

### 4. Запускать примеры

```bash
# Одно свойство
docker compose -f FP_Talk_2026/sandbox/.devcontainer/docker-compose.yml \
  exec sandbox make p1

# Все свойства подряд
docker compose -f FP_Talk_2026/sandbox/.devcontainer/docker-compose.yml \
  exec sandbox make all
```

### 5. Интерактивная оболочка

```bash
docker compose -f FP_Talk_2026/sandbox/.devcontainer/docker-compose.yml \
  exec sandbox bash
```

Внутри оболочки можно запускать файлы напрямую:

```bash
ocaml     01_functions/ocaml.ml
scala-cli 01_functions/scala.sc
./bin/01_functions
python3   01_functions/python.py
node      01_functions/javascript.js
```

### 6. Остановить контейнер

```bash
docker compose -f FP_Talk_2026/sandbox/.devcontainer/docker-compose.yml down
```

### Сокращённый вариант: работать из папки sandbox

```bash
cd FP_Talk_2026/sandbox

docker compose -f .devcontainer/docker-compose.yml up -d
docker compose -f .devcontainer/docker-compose.yml exec sandbox make build
docker compose -f .devcontainer/docker-compose.yml exec sandbox make p1
docker compose -f .devcontainer/docker-compose.yml down
```

---

## Запуск из VS Code (devcontainer)

### Требования

- VS Code с расширением [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Docker Desktop или Docker Engine с Compose

### Порядок действий

1. Открыть в VS Code папку `FP_Talk_2026/sandbox/` (не весь репозиторий).
2. VS Code обнаружит `.devcontainer/` и предложит "Reopen in Container" — согласиться.
   Либо вызвать команду палитры: `Dev Containers: Reopen in Container`.
3. При первом открытии образ собирается автоматически (~2–5 минут).
4. После запуска контейнера автоматически выполнится `make build` (компиляция Rust).

### Сценарий во время доклада

Рекомендуемый layout: две панели редактора + terminal.

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

Между свойствами: переключить файл в левой панели и набрать `make p2` и т.д.

---

## Команды Makefile

| Команда      | Действие                                    |
|--------------|---------------------------------------------|
| `make build` | скомпилировать Rust-примеры в `bin/`        |
| `make p1`    | Свойство 1: функции как значения            |
| `make p2`    | Свойство 2: ссылочная прозрачность          |
| `make p3`    | Свойство 3: иммутабельность                 |
| `make p4`    | Свойство 4: декларативность                 |
| `make p5`    | Свойство 5: выражения вместо инструкций     |
| `make all`   | запустить все пять свойств подряд           |
| `make`       | вывести справку                             |

`make pN` не перекомпилирует Rust — ожидает готовый исполняемый файл в `bin/`.
Если файлов в `bin/` нет, блок Rust упадёт, остальные четыре языка отработают нормально.

---

## Рантаймы в образе

| Язык       | Инструмент    | Стратегия запуска                        |
|------------|---------------|------------------------------------------|
| OCaml      | `ocaml`       | интерпретатор, без компиляции            |
| Scala      | `scala-cli`   | компилирует `.sc` на лету                |
| Rust       | `rustc`       | компилируется заранее через `make build` |
| Python     | `python3`     | интерпретатор                            |
| JavaScript | `node`        | интерпретатор                            |

Rust компилируется заранее, чтобы исключить задержку во время доклада.

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
