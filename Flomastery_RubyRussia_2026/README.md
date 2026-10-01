# На вкус и цвет все фломастеры разные. Особенно если вы пишете на Ruby

Доклад для RubyRussia 2026 (Москва, 2 октября 2026). Эмпирическая проверка
гипотезы о том, что ИИ-агенты неравнодушны к языку программирования не из-за
качеств языка, а из-за объёма его кода в обучающей выборке модели.

Сегодня в докладе — диагноз, дизайн эксперимента и первые наблюдения, не готовые
выводы. «Что делать на нелюбимом стеке» — тема отдельного доклада.

## Структура папки

- `slides/slides.md` — исходник презентации в формате Marp Markdown
- `slides/theme.css` — тема оформления (`flomastery`), расширяет встроенную `default`
- `slides/assets/` — изображения и векторные вставки
- `docker-compose.yml` — конфигурация контейнера Marp CLI (образ, монтирование, порт)
- `build.sh` — сборка через `docker compose run`
- `Makefile` — короткие цели для ручного запуска (`make help`)
- `presentation.pdf` — собранная презентация (коммитится)

Промежуточный `presentation.html` и прочие артефакты сборки в репозиторий не
попадают, см. `.gitignore`.

## Сборка

Движок — [Marp CLI](https://github.com/marp-team/marp-cli), закреплён образом
`marpteam/marp-cli:v4.5.1` в `docker-compose.yml`. Локально нужен только Docker.

```sh
./build.sh          # presentation.pdf
./build.sh html     # presentation.html
./build.sh all      # оба формата
./build.sh serve    # живой предпросмотр на http://localhost:8080

# то же через make
make pdf
make serve
```

Сборка идёт в контейнере (`docker compose run`), версия инструмента задана
тегом образа — результат не зависит от локального Chromium и набора шрифтов.

Если сборка PDF не завершилась за пару минут (контейнер Marp завис), остановите
контейнер (`docker stop`) и запустите сборку заново: повторный запуск обычно
проходит за секунды.

## QR-коды

QR на слайдах лежат в `slides/assets/`:

- `qr-repo.svg` — репозиторий эксперимента
  (<https://github.com/argent-smith/llm-lang-experiment>), слайд «Репозиторий»;
- `qr-slides.svg` — эта папка на GitHub
  (<https://github.com/argent-smith/presentations/tree/master/Flomastery_RubyRussia_2026>),
  финальный слайд: по ссылке открывается README и `presentation.pdf`;
- `qr-feedback.gif` — форма обратной связи по докладу, QR выдан организаторами,
  финальный слайд.

Векторные QR генерируются [segno](https://pypi.org/project/segno/):

```sh
python3 -m venv .venv-qr && .venv-qr/bin/pip install segno
.venv-qr/bin/python -c "import segno; segno.make('<URL>', error='m').save('slides/assets/qr-slides.svg', scale=8, border=3, dark='#0f141a', light='#ffffff', xmldecl=False)"
```

После правки QR пересоберите PDF и проверьте, что код читается: например,
отрисуйте слайд и прогоните через `cv2.QRCodeDetector` (OpenCV).

## Источник содержания

Тезисный план и данные, на которые опираются секции, — в репозитории
эксперимента `llm-lang-experiment`:

- `docs/TALK-OUTLINE-rubyrussia-2026.md` — по-секционный план
- `docs/CFP RubyRussia 2026.md` — текст заявки
- `docs/PILOT-COMPARISON-talk-languages.md` — сетки и ранги по четырём языкам доклада
- `docs/MARKET-PREVALENCE-experiment-languages.md` — объёмы корпусов, рыночный контекст

Слайды собраны по этому плану, готовая версия — `presentation.pdf`.
Репозиторий эксперимента: <https://github.com/argent-smith/llm-lang-experiment>.
