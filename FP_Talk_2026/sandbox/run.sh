#!/usr/bin/env bash

PROP="${1:?Usage: run.sh <property_number (1-5)>}"

DIRS=(01_functions 02_referential 03_immutability 04_declarative 05_expressions)
NAMES=(
  "Свойство 1: функции как значения"
  "Свойство 2: ссылочная прозрачность"
  "Свойство 3: иммутабельность"
  "Свойство 4: декларативность"
  "Свойство 5: выражения вместо инструкций"
)

IDX=$((PROP - 1))
DIR="${DIRS[$IDX]}"

SEP="════════════════════════════════════════════"
LANG_SEP="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "${SEP}"
echo "  ${NAMES[$IDX]}"
echo "${SEP}"

header() { echo ""; echo "━━━ $1 ${LANG_SEP:${#1}+4}"; }

header "OCaml"
ocaml "${DIR}/ocaml.ml" 2>&1 || true

header "Scala"
scala-cli "${DIR}/scala.sc" 2>&1 || true

header "Rust"
"./bin/${DIR}" 2>&1 || true

header "Python"
python3 "${DIR}/python.py" 2>&1 || true

header "JavaScript"
node "${DIR}/javascript.js" 2>&1 || true

echo ""
