#!/usr/bin/env bash
#
# Сборка слайдов доклада «На вкус и цвет все фломастеры разные» через Marp CLI.
#
# Движок закреплён по версии образом Docker (marpteam/marp-cli:v4.5.1, см.
# docker-compose.yml) — как и всё остальное в эксперименте, дрейф версии
# инструмента исключается на уровне тега.
#
# Источник:  slides/slides.md + slides/theme.css + slides/assets/
# Результат:  presentation.pdf (коммитится), presentation.html (промежуточный, в .gitignore)
#
# Использование:
#   ./build.sh            собрать PDF (по умолчанию)
#   ./build.sh pdf        то же
#   ./build.sh html       собрать HTML
#   ./build.sh all        собрать оба формата
#   ./build.sh serve      живой предпросмотр с автоперезагрузкой на http://localhost:8080

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

export MARP_UID="$(id -u)"
export MARP_GID="$(id -g)"
export LANG="${LANG:-ru_RU.UTF-8}"

# Позиционный вход идёт первым; --theme-set (тип array в yargs) — последним,
# иначе он поглощает следующий за ним путь как ещё один элемент массива.
render() {
  local out="$1"
  docker compose run --rm marp \
    slides/slides.md -o "$out" \
    --html --allow-local-files \
    --theme-set slides/theme.css
}

case "${1:-pdf}" in
  pdf)
    render presentation.pdf
    echo "Готово: $HERE/presentation.pdf"
    ;;
  html)
    render presentation.html
    echo "Готово: $HERE/presentation.html"
    ;;
  all)
    render presentation.pdf
    render presentation.html
    echo "Готово: presentation.pdf, presentation.html"
    ;;
  serve)
    docker compose run --rm --service-ports marp \
      -s slides --html --theme-set slides/theme.css
    ;;
  *)
    echo "Использование: ./build.sh [pdf|html|all|serve]" >&2
    exit 2
    ;;
esac
