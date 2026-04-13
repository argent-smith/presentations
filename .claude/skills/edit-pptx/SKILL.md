---
name: edit-pptx
description: Редактирование PPTX-презентаций через python-pptx. Использовать при добавлении/изменении слайдов, синтаксической подсветке, управлении шрифтами и форматированием через XML.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [задача]
---

# Навык: редактирование PPTX через python-pptx

## Окружение

```fish
# Python
/opt/homebrew/bin/python3  # python-pptx v1.0.2

# Рендеринг для проверки
/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf FILE.pptx --outdir DIR/

# Слайд N (1-indexed) в PNG (не более 2000px по любой стороне)
pdftoppm -r 150 -f N -l N FILE.pdf /tmp/slide
magick /tmp/slide-N.ppm -resize 1920x1080 /tmp/slide.png
```

## Ключевые XML-элементы

```
a:p         — параграф
  a:pPr     — свойства параграфа (marL, indent, buNone, buChar...)
  a:r       — run (кусок текста с одним форматированием)
    a:rPr   — свойства run
      a:latin typeface="JetBrains Mono"
      a:ea    typeface="..."
      a:cs    typeface="..."
      a:solidFill → a:srgbClr val="rrggbb"
    a:t     — текст
```

## Боевые паттерны

### Дублирование слайда

```python
import copy
from pptx import Presentation

def duplicate_slide(prs, source_index):
    source = prs.slides[source_index]
    new_slide = prs.slides.add_slide(source.slide_layout)
    src_tree = source.shapes._spTree
    new_tree = new_slide.shapes._spTree
    for child in list(new_tree):
        new_tree.remove(child)
    for child in src_tree:
        new_tree.append(copy.deepcopy(child))
    return new_slide
```

### Вставка слайда на позицию

```python
def insert_slide_at(prs, position):
    # add_slide всегда добавляет в конец — переставляем
    sldIdLst = prs.slides._sldIdLst
    sldIds = list(sldIdLst)
    new_id = sldIds[-1]
    sldIdLst.remove(new_id)
    sldIdLst.insert(position, new_id)
```

### Удаление слайда (без orphan-ссылок)

```python
def delete_slide(prs, index):
    sldIdLst = prs.slides._sldIdLst
    sldId = list(sldIdLst)[index]
    rId = sldId.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id')
    sldIdLst.remove(sldId)
    try:
        prs.part._rels.pop(rId, None)
    except Exception:
        pass
```

### Получить template-параграф (с pPr, без runs)

```python
def get_template_para(txBody):
    from pptx.oxml.ns import qn
    for p in txBody.findall(qn('a:p')):
        if p.findall(qn('a:r')):
            tp = copy.deepcopy(p)
            for r in tp.findall(qn('a:r')):
                tp.remove(r)
            return tp
    from lxml import etree
    return etree.Element(qn('a:p'))
```

**Важно:** всегда копировать pPr из эталонного параграфа. Создание через `etree.SubElement` даёт пустой `a:p` без `a:pPr` — заголовок уедет вправо, переносы строк дадут hanging indent.

### Шрифты: явная установка typeface

Runs, созданные через `etree.SubElement`, не наследуют шрифт из лейаута. Нужно явно копировать `a:latin/ea/cs/sym` из эталонного слайда:

```python
def get_typeface_elements(slide, typeface='JetBrains Mono'):
    from pptx.oxml.ns import qn
    for shape in slide.shapes:
        if shape.has_text_frame and len(shape.text_frame.paragraphs) > 1:
            txBody = shape.text_frame._txBody
            for p in txBody.findall(qn('a:p')):
                for r in p.findall(qn('a:r')):
                    rPr = r.find(qn('a:rPr'))
                    if rPr is not None:
                        latin = rPr.find(qn('a:latin'))
                        if latin is not None and latin.get('typeface') == typeface:
                            return [copy.deepcopy(rPr.find(qn(t)))
                                    for t in ('a:latin','a:ea','a:cs','a:sym')]
    return []

def apply_typeface(rPr, typeface_elems):
    from pptx.oxml.ns import qn
    for tag in (qn('a:latin'), qn('a:ea'), qn('a:cs'), qn('a:sym')):
        for el in rPr.findall(tag): rPr.remove(el)
    sf = rPr.find(qn('a:solidFill'))
    insert_at = list(rPr).index(sf) if sf is not None else len(rPr)
    for j, elem in enumerate(typeface_elems):
        if elem is not None:
            rPr.insert(insert_at + j, copy.deepcopy(elem))
```

### Цвет и шрифт маркера буллета (buClr / buFont)

Keynote определяет цвет маркера из `defRPr` в `pPr`, но при наличии первого run с явным цветом (emphasized) — берёт цвет оттуда. Чтобы маркер всегда был серым/конкретным, нужно задавать `a:buClr` и `a:buFont` явно.

```python
from lxml import etree
from pptx.oxml.ns import qn

def set_bullet_style(pPr, color_hex='A7A7A7', typeface='Montserrat Thin Bold'):
    """Явно задать цвет и шрифт маркера, независимо от цвета первого run."""
    buClr = etree.Element(qn('a:buClr'))
    srgbClr = etree.SubElement(buClr, qn('a:srgbClr'))
    srgbClr.set('val', color_hex)

    buFont = etree.Element(qn('a:buFont'))
    buFont.set('typeface', typeface)

    # Вставить перед buSzPct или buChar
    buSzPct = pPr.find(qn('a:buSzPct'))
    buChar = pPr.find(qn('a:buChar'))
    anchor = buSzPct or buChar
    if anchor is not None:
        idx = list(pPr).index(anchor)
        pPr.insert(idx, buFont)
        pPr.insert(idx, buClr)
    else:
        pPr.append(buClr)
        pPr.append(buFont)
```

**Когда применять:** когда пункт списка начинается с выделенного текста (первый run — белый/Black), а маркер должен оставаться стандартным относительно всего списка (серым/Bold). Без явных `buClr`/`buFont` Keynote наследует цвет и шрифт маркера из первого run, что нарушает визуальную консистентность списка.

### Удаление буллета

```python
from lxml import etree
from pptx.oxml.ns import qn

pPr = p.find(qn('a:pPr'))
if pPr is None:
    pPr = etree.SubElement(p, qn('a:pPr'))
    p.insert(0, pPr)
etree.SubElement(pPr, qn('a:buNone'))
```

### Цвет run (solidFill)

```python
def set_run_color(run_elem, rgb):
    from pptx.oxml.ns import qn
    from lxml import etree
    rPr = run_elem.find(qn('a:rPr'))
    if rPr is None:
        rPr = etree.SubElement(run_elem, qn('a:rPr'))
        run_elem.insert(0, rPr)
    for sf in rPr.findall(qn('a:solidFill')):
        rPr.remove(sf)
    solidFill = etree.SubElement(rPr, qn('a:solidFill'))
    srgbClr = etree.SubElement(solidFill, qn('a:srgbClr'))
    srgbClr.set('val', '{:02x}{:02x}{:02x}'.format(*rgb))
```

## Стиль «ghost-строка» (контекст с предыдущего слайда)

Когда код разбит на два слайда, первая строка второго слайда — серый (dimmed) краткий итог предыдущего фрагмента. Визуально читается как «откуда мы пришли», не дублирует код дословно.

Цвет: `95a5a6` (тот же, что у обычных комментариев).

```python
# Добавить ghost-строку в начало кодового блока
def prepend_ghost_line(txBody, ghost_text, template):
    """template — эталонный параграф-комментарий (серый, с JetBrains Mono)"""
    p_ghost = copy.deepcopy(template)
    p_ghost.findall(qn('a:r'))[0].find(qn('a:t')).text = ghost_text
    paras = txBody.findall(qn('a:p'))
    for p in paras:
        if p.findall(qn('a:r')):
            txBody.insert(list(txBody).index(p), p_ghost)
            return
```

**Соглашение в этой презентации:** ghost-строка оформляется как комментарий на языке слайда:
```
// let triple: impl Fn(i32) -> i32 = multiply(3)   ← ghost (итог пред. слайда)
let base = 10;                                       ← первая «живая» строка
```

## Комментарии и пустые строки в кодовом блоке

Комментарии (серый цвет `95a5a6`) и пустые строки вставляются как параграфы через `copy.deepcopy` эталонного параграфа-комментария с соседнего слайда.

```python
import copy
from pptx.oxml.ns import qn

# Взять шаблон комментария с существующего слайда
def get_comment_template(slide):
    for shape in slide.shapes:
        if shape.has_text_frame and len(shape.text_frame.paragraphs) > 2:
            txBody = shape.text_frame._txBody
            for p in txBody.findall(qn('a:p')):
                runs = p.findall(qn('a:r'))
                if runs:
                    rPr = runs[0].find(qn('a:rPr'))
                    sf = rPr.find('.//' + qn('a:srgbClr')) if rPr is not None else None
                    if sf is not None and sf.get('val') == '95a5a6':
                        return copy.deepcopy(p)
    return None

# Вставить комментарий перед параграфом с заданным текстом
def insert_comment_before(txBody, text_before, comment_text, template):
    p_new = copy.deepcopy(template)
    p_new.findall(qn('a:r'))[0].find(qn('a:t')).text = comment_text
    paras = txBody.findall(qn('a:p'))
    for i, p in enumerate(paras):
        runs = p.findall(qn('a:r'))
        t = ''.join(r.find(qn('a:t')).text or '' for r in runs if r.find(qn('a:t')) is not None)
        if t.startswith(text_before):
            txBody.insert(list(txBody).index(p), p_new)
            return

# Пустая строка — копия шаблона без runs (с пустым run для сохранения высоты)
def insert_empty_line_before(txBody, text_before, template):
    p_empty = copy.deepcopy(template)
    for r in p_empty.findall(qn('a:r')):
        p_empty.remove(r)
    r_blank = copy.deepcopy(template.findall(qn('a:r'))[0])
    r_blank.find(qn('a:t')).text = ''
    p_empty.append(r_blank)
    paras = txBody.findall(qn('a:p'))
    for p in paras:
        runs = p.findall(qn('a:r'))
        t = ''.join(r.find(qn('a:t')).text or '' for r in runs if r.find(qn('a:t')) is not None)
        if t.startswith(text_before):
            txBody.insert(list(txBody).index(p), p_empty)
            return
```

**Важно:** runs в XML параграфа идут после `a:endParaRPr`. Порядок в `etree` может быть неожиданным — всегда проверять через `etree.tostring`.

## Синтаксическая подсветка

### Цветовая схема

```python
COLORS = {
    'keyword':  (0xc0, 0x39, 0x2b),  # красный
    'type':     (0x2c, 0x6f, 0xa6),  # синий
    'function': (0x2c, 0x6f, 0xa6),
    'number':   (0x7f, 0x8c, 0x8d),  # серый
    'string':   (0x7f, 0x8c, 0x8d),
    'comment':  (0x95, 0xa5, 0xa6),  # светло-серый
    'default':  (0x1a, 0x1a, 0x1a),
}
```

### Rust: lifetime аннотации

`'static`, `'a` — lifetime, а не string. Проверять раньше char-литерала:

```python
if line[i] == "'":
    m = re.match(r"'([a-zA-Z_][a-zA-Z0-9_]*)", line[i:])
    if m:
        tokens.append(('default', m.group())); i += len(m.group()); continue
    # иначе — char literal
    j = i + 1
    while j < len(line) and line[j] != "'":
        if line[j] == '\\': j += 1
        j += 1
    tokens.append(('string', line[i:j+1])); i = j + 1; continue
```

## Восстановление коррумпированного PPTX

PPTX — это ZIP. Если PowerPoint не открывает файл:

```python
import zipfile, shutil
from lxml import etree

# Распаковать
with zipfile.ZipFile('file.pptx', 'r') as z:
    z.extractall('/tmp/pptx_fix/unpacked/')

# Проверить дублирующиеся rId в ppt/_rels/presentation.xml.rels
# Исправить XML
# Запаковать обратно
shutil.make_archive('/tmp/fixed', 'zip', '/tmp/pptx_fix/unpacked/')
shutil.move('/tmp/fixed.zip', 'file_fixed.pptx')
```

При удалении слайда через ZIP:
1. Убрать `Relationship` из `presentation.xml.rels`
2. Убрать `sldId` из `presentation.xml`
3. Удалить физический `ppt/slides/slideN.xml` из ZIP

## Диагностика: сравнить XML двух слайдов

```python
from lxml import etree
from pptx.oxml.ns import qn

def dump_run_xml(slide, multi_para=True):
    for shape in slide.shapes:
        if shape.has_text_frame:
            if multi_para and len(shape.text_frame.paragraphs) <= 1:
                continue
            txBody = shape.text_frame._txBody
            for p in txBody.findall(qn('a:p')):
                for r in p.findall(qn('a:r')):
                    print(etree.tostring(r.find(qn('a:rPr')), pretty_print=True).decode())
                return

dump_run_xml(prs.slides[8])   # рабочий
dump_run_xml(prs.slides[16])  # проблемный
```

## Размер шрифта

Размер задаётся атрибутом `sz` в `a:rPr` (в сотых долях пункта: `2300` = 23pt, `2800` = 28pt).

```python
# Прочитать текущий размер
rPr = run.find(qn('a:rPr'))
sz = int(rPr.get('sz', 0)) if rPr is not None else 0  # 0 = унаследован

# Установить размер всем runs в shape
def set_font_size(code_shape, sz_val):
    from pptx.oxml.ns import qn
    txBody = code_shape.text_frame._txBody
    for p in txBody.findall(qn('a:p')):
        epr = p.find(qn('a:endParaRPr'))
        if epr is not None:
            epr.set('sz', str(sz_val))
        for r in p.findall(qn('a:r')):
            rPr = r.find(qn('a:rPr'))
            if rPr is not None:
                rPr.set('sz', str(sz_val))
```

**Типичные значения для кодовых слайдов:**
- `2300` (23pt) — стандарт; умещает ~55 символов в строку
- `2000` (20pt) — длинные строки (~63 символа)
- `1800` (18pt) — очень длинные строки; читаемость падает

**Когда уменьшать:** если код переносится на следующую строку или выезжает за границу shape. Проверять после рендера.

## Единицы измерения

```python
# EMU (English Metric Units)
# 1 cm ≈ 360 000 EMU
# ~1 символ JetBrains Mono ≈ 200 000 EMU

shape.left    # отступ слева
shape.top     # отступ сверху
shape.width
shape.height
```

## Вставка mermaid-диаграммы в слайд

### Рендеринг

```fish
# 1. Рендер (mmdc игнорирует -H — высота определяется содержимым)
/opt/homebrew/bin/mmdc -i diag.mmd -o diag_raw.png -b '#191919' -w 1400

# 2. Добавить вертикальные поля через ImageMagick
magick diag_raw.png -bordercolor '#191919' -border 0x80 diag.png

# 3. Проверить реальный размер перед вставкой
python3 -c "from PIL import Image; print(Image.open('diag.png').size)"
```

**Важно:** никогда не задавать пропорции вручную — брать из `Image.open().size`.

### Вставка с сохранением пропорций (letterbox)

```python
from pptx import Presentation
from PIL import Image

def insert_diagram(pptx_path, img_path, slide_index,
                   frame_left=300_000, frame_top=1_380_000,
                   frame_right=8_844_000, frame_bottom=5_100_000):
    prs = Presentation(pptx_path)
    slide = prs.slides[slide_index]

    # Удалить старую диаграмму (все Picture кроме Google-шаблонных)
    for s in list(slide.shapes):
        if s.name.startswith('Picture') and 'Google' not in s.name:
            s._element.getparent().remove(s._element)

    img_w_px, img_h_px = Image.open(img_path).size
    aspect = img_w_px / img_h_px
    frame_w = frame_right - frame_left
    frame_h = frame_bottom - frame_top

    img_w = frame_w
    img_h = int(img_w / aspect)
    if img_h > frame_h:          # letterbox по вертикали
        img_h = frame_h
        img_w = int(img_h * aspect)

    left = frame_left + (frame_w - img_w) // 2
    top  = frame_top  + (frame_h - img_h) // 2

    slide.shapes.add_picture(img_path, left, top, img_w, img_h)
    prs.save(pptx_path)
```

### Шейпы mermaid (event storming нотация)

| Роль         | Mermaid-синтаксис | Вид               |
|--------------|-------------------|-------------------|
| Актор        | `id(["text"])`    | Stadium/pill      |
| Команда      | `id["text"]`      | Прямоугольник     |
| Событие      | `id("text")`      | Rounded rectangle |
| Политика     | `id("text")`      | Rounded rectangle |
| Error Bus    | `id(("text"))`    | Круг/эллипс       |
| БД/хранилище | `id[("text")]`    | Цилиндр           |

### Паттерн темной темы (dark background)

```
background:       #191919
команды/сервисы:  fill:#3a7fc1, stroke:#2e75b6  (синий)
success-узлы:     fill:#1e3a1e, stroke:#48CC42  (зелёный)
failure-узлы:     fill:#3a1e1e, stroke:#cc4242  (красный)
события:          fill:#e67e22, stroke:#ca6f1e  (оранжевый)
обработчики:      fill:#8e44ad, stroke:#7d3c98  (фиолетовый)
акторы:           fill:#f5d76e, stroke:#c8a000, color:#222222
success-стрелки:  stroke:#48CC42, stroke-width:2px
failure-стрелки:  stroke:#c0392b, stroke-width:2px
нейтральные:      stroke:#888888
```

## Чек-лист при создании нового кодового слайда

1. Дублировать эталонный слайд через `duplicate_slide` (не создавать с нуля)
2. Заменить заголовок — копировать pPr из эталонного title-параграфа
3. Заменить контент — копировать template_para (с pPr) для каждой строки
4. Явно применить typeface (JetBrains Mono) ко всем runs
5. Применить синтаксическую подсветку
6. Вставить на нужную позицию через `insert_slide_at`
7. Отрендерить через LibreOffice, проверить PNG