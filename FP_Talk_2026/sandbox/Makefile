.DEFAULT_GOAL := help

help:
	@echo "Цели:"
	@echo "  make build — скомпилировать Rust-примеры (запустить один раз)"
	@echo "  make p1    — Свойство 1: функции как значения"
	@echo "  make p2    — Свойство 2: ссылочная прозрачность"
	@echo "  make p3    — Свойство 3: иммутабельность"
	@echo "  make p4    — Свойство 4: декларативность"
	@echo "  make p5    — Свойство 5: выражения вместо инструкций"
	@echo "  make all   — запустить все свойства подряд"

build:
	mkdir -p bin
	@for dir in 0*/; do \
		name=$$(basename $$dir); \
		rustc "$${dir}rust.rs" -o "bin/$${name}" 2>/dev/null \
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

.PHONY: help build p1 p2 p3 p4 p5 all
