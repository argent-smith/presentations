# Сборка слайдов доклада «На вкус и цвет все фломастеры разные».
# Тонкая обёртка над build.sh (сам движок — закреплённый по версии образ
# Marp CLI в Docker, см. build.sh и README.md).

.DEFAULT_GOAL := help
.PHONY: pdf html all serve clean help

pdf: ## Собрать presentation.pdf
	./build.sh pdf

html: ## Собрать presentation.html
	./build.sh html

all: ## Собрать оба формата — pdf и html
	./build.sh all

serve: ## Живой предпросмотр с автоперезагрузкой (http://localhost:8080)
	./build.sh serve

clean: ## Удалить промежуточный presentation.html
	rm -f presentation.html

help: ## Показать список целей
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'
