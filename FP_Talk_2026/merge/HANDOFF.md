# Handoff: презентация merge/presentation.pptx

## Контекст

Порт доклада «Древняя магия в повседневном коде» с конференции Стачка на конференцию **Merge 2026** (Иннополис, 17–18 апреля).

Источник контента: `FP_Talk_2026/nastachku/presentation.pptx`.
Целевой файл: `FP_Talk_2026/merge/presentation.pptx`.

Git-ветка: `fp-talk-merge`.

---

## Структура презентации (26 слайдов)

| Слайд | Содержимое |
|-------|------------|
| 1–6   | Оригинальные (title, speaker, intro, таблица языков, тезис декларативности) |
| 7–11  | Build-серия «Декларативность» (revealed 0–4) |
| 12    | «Декларативность» — все языки открыты (эталон секции) |
| 13    | Тезисный «Выражения вместо инструкций» |
| 14–18 | Build-серия «Выражения» (revealed 0–4) |
| 19    | «Выражения» — все языки открыты (эталон секции) |
| 20    | Тезисный «Функции как значения» |
| 21    | Build-серия «Функции как значения» — 0 revealed (all dim) |
| 22    | Build — OCaml revealed |
| 23    | Build — OCaml + Scala revealed |
| 24    | Build — OCaml + Scala + Rust revealed |
| 25    | Build — OCaml + Scala + Rust + Python revealed |
| 26    | «Функции как значения» — все языки открыты (эталон секции, named shapes) |

---

## Незавершённые задачи на момент handoff

### ✅ Секция «Функции как значения» — ЗАВЕРШЕНА

- Испавлен namespace-баг (`a:txBody` → `p:txBody`) в 60 узлах
- Синтаксическая подсветка кода: KW=E06C75, TY=61AFEF, NUM=E5C07B, DEF=D0D0D0
- Геометрия и кегль sz=900 синхронизированы с пользовательским эталоном (slide26)
- Распространение всех языков из slide26 на build-слайды 21–25
- JS-блок: позиционный pPr для корректных межстрочных интервалов
- Слайд 25 (Python) восстановлен (был удалён случайно)
- Dim-логика: единый DIM-run на параграф с явным srgbClr=2A2A2A

### 1. Исправить смысловые выделения в тезисном слайде 20 («Функции как значения»)

По аналогии со slide13 («Выражения»): префикс серый `A7A7A7` Montserrat Thin Bold, акцент белый `FFFFFF` Montserrat Thin Black. Правильная структура буллетов:

```
• Функция —           [серый]  first-class value: передаётся аргументом, ...  [белый жирный]
• HOF —               [серый]  принимает или возвращает функцию: map, filter, fold  [белый жирный]
• Замыкание —         [серый]  захват лексического окружения  [белый жирный]
• Каррирование —      [серый]  f(a, b) → f(a)(b)  [белый жирный]
```

Эталон: slide13.

### 2. Добавить разделы «Чистота функций» и «Иммутабельность»

По аналогии с готовыми секциями. Источник: nastachku slides 30–45.

**«Чистота функций»** (nastachku 30–37):
- Задача: функция скидки — чистая и нечистая версии
- Тезисный слайд: «Чистая функция: возвращаемое значение зависит только от аргументов»

**«Иммутабельность»** (nastachku 38–45):
- Задача: обновить одно поле записи без изменения оригинала
- Тезисный слайд: «const/val — запрет перезаписи переменной»

### 3. Добавить итоговый слайд и бонус-трек

nastachku slides 46–58.

---

## Технические детали

### Среда

```fish
# Python
/opt/homebrew/bin/python3  # python-pptx v1.0.2

# Рендеринг для проверки
/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf FILE.pptx --outdir /tmp/
pdftoppm -r 120 -f N -l N /tmp/presentation.pdf /tmp/slN
magick /tmp/slN-NN.ppm -resize 1600x900 /tmp/slide_N.png
```

### Подход к редактированию PPTX

Файл редактируется как ZIP через `zipfile` + `lxml.etree` напрямую — **не через python-pptx API**. python-pptx дублирует имена в ZIP при `duplicate_slide`.

```python
with zipfile.ZipFile(PPTX, 'r') as z:
    data = {n: z.read(n) for n in z.namelist()}
    order = list(z.namelist())

# ... изменения ...

with zipfile.ZipFile(PPTX, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
    for name in order:
        if name in data: zout.writestr(name, data[name])
```

### Паттерн build-слайдов (накопительное раскрытие)

- Слайды `N+0`: все языки затемнены (DIM)
- Слайды `N+1`: 1-й открыт, остальные DIM
- ...
- Слайды `N+4`: 4 открыты, последний DIM
- Слайд `N+5` (all-revealed): все открыты, имена shape — `lbl_OCaml/code_OCaml` и т.д.
- Build-слайды: имена shape — `lbl_0/code_0` ... `lbl_4/code_4`

Затемнение:
```python
def dim_txbody(tb):
    tb2 = copy.deepcopy(tb)
    for clr in tb2.findall('.//{NS_A}srgbClr'):
        clr.set('val', '2A2A2A')
    return tb2
```

Распространение с all-revealed на build:
```python
IDX_TO_LANG = ['OCaml', 'Scala', 'Rust', 'Python', 'JS']

# Читаем из all-revealed (lbl_OCaml → ref_geo['lbl_OCaml'])
# Применяем в build (lbl_0 → lang=IDX_TO_LANG[0]='OCaml')
# i < revealed_count → полный цвет, иначе dim
```

### Цветовая схема кода

```python
KW  = 'E06C75'  # keyword — коралловый
TY  = '61AFEF'  # type/method — голубой
NUM = 'E5C07B'  # number — янтарный
DEF = 'D0D0D0'  # default — светло-серый
DIM = '2A2A2A'  # dimmed — тёмно-серый (для скрытых блоков)
GRN = '48CC42'  # green — заголовки языков
```

### Построители run-ов (минимальный rPr)

```python
def r_plain(text):
    """Run без rPr — наследует из pPr.defRPr"""
    r = etree.Element('{NS_A}r')
    etree.SubElement(r, '{NS_A}t').text = text
    return r

def r_color(text, color):
    """Run с минимальным rPr (только solidFill)"""
    r = etree.Element('{NS_A}r')
    rPr = etree.SubElement(r, '{NS_A}rPr')
    sf = etree.SubElement(rPr, '{NS_A}solidFill')
    etree.SubElement(sf, '{NS_A}srgbClr').set('val', color)
    etree.SubElement(r, '{NS_A}t').text = text
    return r
```

**Важно:** явно не добавляй `sz`, `latin`, `ea`, `cs` в `rPr` run-ов — они наследуются из `pPr.defRPr`. Иначе LibreOffice рендерит неправильно (гарнитура не применяется).

### pPr кодового параграфа

```python
def make_pPr(defRPr_color, spcBef=False):
    pPr = etree.Element('{NS_A}pPr')
    lnSpc = etree.SubElement(pPr, '{NS_A}lnSpc')
    etree.SubElement(lnSpc, '{NS_A}spcPct').set('val', '60000')  # 60% межстрочный
    if spcBef:
        sb = etree.SubElement(pPr, '{NS_A}spcBef')
        etree.SubElement(sb, '{NS_A}spcPts').set('val', '400')
    dRPr = etree.SubElement(pPr, '{NS_A}defRPr')
    dRPr.set('sz', '1000')  # 10pt
    sf = etree.SubElement(dRPr, '{NS_A}solidFill')
    etree.SubElement(sf, '{NS_A}srgbClr').set('val', defRPr_color)
    for tag, face in [('latin','JetBrains Mono Regular'), ('ea','JetBrains Mono Regular'),
                      ('cs','JetBrains Mono Regular'), ('sym','JetBrains Mono Regular')]:
        etree.SubElement(dRPr, f'{{NS_A}}{tag}').set('typeface', face)
    return pPr
```

### endParaRPr

```python
def make_endPR():
    epr = etree.Element('{NS_A}endParaRPr')
    for tag, face in [('latin','+mj-lt'), ('ea','+mj-ea'), ('cs','+mj-cs'), ('sym','Helvetica')]:
        etree.SubElement(epr, f'{{NS_A}}{tag}').set('typeface', face)
    return epr
```

### Заголовок языка (lbl_*)

```python
def make_lbl_txBody(text):
    # lstStyle.lvl1pPr.defRPr: sz=1400, color=48CC42, JetBrains Mono Regular
    # bodyPr: lIns=tIns=rIns=bIns=0, anchor=ctr, spAutoFit
    # p → pPr (empty) → r → t = text
```

### Геометрия кодовых блоков

Слайд 9144000 × 5143500 EMU.

**Декларативность (slide12):**

| Shape | x | y | cx | cy |
|-------|---|---|----|----|
| title | 404973 | 938037 | 5824548 | 342901 |
| sub | 381660 | 1355700 | 8200002 | 228601 |
| lbl_OCaml | 386755 | 1791579 | 713743 | 241301 |
| code_OCaml | 386759 | 2097651 | 3540758 | 1335813 |
| lbl_Scala | 3710061 | 1774624 | 713741 | 241301 |
| code_Scala | 3710058 | 2080691 | 2430386 | 1335814 |
| lbl_Rust | 6260843 | 1774624 | 591821 | 241301 |
| code_Rust | 6260843 | 2080690 | 2760597 | 1365669 |
| lbl_Python | 1981074 | 3513156 | 835662 | 241301 |
| code_Python | 1981075 | 3819223 | 2032001 | 1108251 |
| lbl_JS | 5296265 | 3513156 | 347981 | 241301 |
| code_JS | 5296265 | 3819223 | 2978178 | 979167 |

**Функции как значения (slide27):**

| Shape | x | y | cx | cy |
|-------|---|---|----|----|
| lbl_OCaml | 386755 | 1791579 | 800000 | 241301 |
| code_OCaml | 386755 | 2097651 | 2700000 | 1365000 |
| lbl_Scala | 3710061 | 1791579 | 800000 | 241301 |
| code_Scala | 3710061 | 2097651 | 2400000 | 1365000 |
| lbl_Rust | 6260843 | 1791579 | 800000 | 241301 |
| code_Rust | 6260843 | 2097651 | 2870000 | 1365000 |
| lbl_Python | 1981075 | 3513156 | 800000 | 241301 |
| code_Python | 1981075 | 3819223 | 2700000 | 1100000 |
| lbl_JS | 4881075 | 3513156 | 800000 | 241301 |
| code_JS | 4881075 | 3819223 | 3350000 | 1100000 |

### Структура XML тезисного буллета (эталон slide13)

```xml
<a:p>
  <a:pPr marL="150394" indent="-150394">
    <a:lnSpc><a:spcPct val="133302"/></a:lnSpc>
    <a:buSzPct val="150000"/>
    <a:buChar char="•"/>
    <a:defRPr sz="1500">
      <a:solidFill><a:srgbClr val="A7A7A7"/></a:solidFill>
      <a:latin typeface="Montserrat Thin Bold"/>
      ...
    </a:defRPr>
  </a:pPr>
  <!-- Серый префикс — наследует defRPr -->
  <a:r>
    <a:t>Инструкции — </a:t>
  </a:r>
  <!-- Белый акцент -->
  <a:r>
    <a:rPr>
      <a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill>
      <a:latin typeface="Montserrat Thin Black"/>
      ...
    </a:rPr>
    <a:t>производят эффект</a:t>
  </a:r>
</a:p>
```

### Регистрация нового слайда в PPTX

```python
# 1. Добавить файл слайда и его rels
data[f'ppt/slides/slide{n}.xml'] = xml_bytes
data[f'ppt/slides/_rels/slide{n}.xml.rels'] = slide6_rels  # копируем rels от slide6

# 2. Зарегистрировать в ppt/_rels/presentation.xml.rels
rel = etree.SubElement(prs_rels, '{PKG_NS}Relationship')
rel.set('Id', f'rId{max_rid+1}')
rel.set('Type', 'http://...relationships/slide')
rel.set('Target', f'slides/slide{n}.xml')

# 3. Зарегистрировать в ppt/presentation.xml → sldIdLst
sldId = etree.SubElement(sldIdLst, '{NS_P}sldId')
sldId.set('id', str(max_sld_id+1))
sldId.set('{NS_REL}id', f'rId{max_rid+1}')
```

### Шаблон кодового слайда

Новые кодовые слайды строятся на основе `slide12.xml`:
1. Парсим slide12 через `etree.fromstring(data['ppt/slides/slide12.xml'])`
2. Меняем заголовок и текст задачи in-place
3. Удаляем старые `sp` с именами `lbl_OCaml/code_OCaml` и т.д. из `spTree`
4. Добавляем новые shape через `make_sp_shape()`
5. Сериализуем через `etree.tostring(..., xml_declaration=True, encoding='UTF-8', standalone=True)`

Шаблон тезисного слайда — `slide13.xml`, меняем `title` и `bullets` in-place.

---

## Правило git

Коммитить только по явной команде пользователя («закоммить», «коммить», «commit»). Не коммитить автоматически.

---

## Источник контента

`/Users/paul/work/presentations/FP_Talk_2026/nastachku/presentation.pptx`

| nastachku слайды | Раздел |
|------------------|--------|
| 5–13 | Декларативность |
| 14–21 | Выражения вместо инструкций |
| 22–29 | Функции как значения |
| 30–37 | Чистота функций |
| 38–45 | Иммутабельность |
| 46 | Итог: пять свойств × пять языков |
| 47 | Задание на дом |
| 48–58 | Бонус-трек: ФП в production (Ruby DDD) |
| 59 | Финальный слайд |
