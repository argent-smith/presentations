COMPOSE = docker compose -f .devcontainer/docker-compose.yml

.DEFAULT_GOAL := help

help:
	@echo "Цели:"
	@echo "  make build       — собрать образы и скомпилировать Rust-примеры"
	@echo "  make p1          — Свойство 1: функции как значения"
	@echo "  make p2          — Свойство 2: ссылочная прозрачность"
	@echo "  make p3          — Свойство 3: иммутабельность"
	@echo "  make p4          — Свойство 4: декларативность"
	@echo "  make p5          — Свойство 5: выражения вместо инструкций"
	@echo "  make all         — запустить все свойства подряд"
	@echo "  make clean       — удалить скомпилированные Rust-файлы"
	@echo "  make repl-ocaml  — интерактивный REPL OCaml"
	@echo "  make repl-scala  — интерактивный REPL Scala"
	@echo "  make repl-python — интерактивный REPL Python"
	@echo "  make repl-js     — интерактивный REPL Node.js"

build:
	$(COMPOSE) build
	mkdir -p bin
	@for dir in 0*/; do \
		name=$$(basename $$dir); \
		$(COMPOSE) run --rm rust rustc "$${dir}rust.rs" -o "bin/$${name}" \
			&& echo "  compiled: $$name" \
			|| echo "  failed:   $$name"; \
	done

p1:
	./run.sh 1

p2:
	./run.sh 2

p3:
	./run.sh 3

p4:
	./run.sh 4

p5:
	./run.sh 5

all:
	@for i in 1 2 3 4 5; do ./run.sh $$i; done

clean:
	rm -f bin/*

repl-ocaml:
	$(COMPOSE) run --rm -it --no-deps ocaml utop

repl-scala:
	$(COMPOSE) run --rm -it --no-deps scala scala-cli repl

repl-python:
	$(COMPOSE) run --rm -it --no-deps python python3

repl-js:
	$(COMPOSE) run --rm -it --no-deps js node

.PHONY: help build p1 p2 p3 p4 p5 all clean repl-ocaml repl-scala repl-python repl-js
