// ============================================================================
// arxiv.typ — «предпечатный» стиль тела отчёта по ОАиП, образец — пакет
// @preview/arkheion (вёрстка arXiv-препринтов): New Computer Modern,
// шапка «линия — заголовок — линия», цель работы как аннотация, заголовки
// без прописных и без разрыва страниц, номер страницы снизу по центру.
//
// Титульный лист — по образцу кафедры, один в один как в oaip.typ
// (копия блока, стп-шаблон не тронут: старый стиль — замена одного импорта).
//
// Использование — те же параметры, что и у oaip.with(...):
//   #import "../../template/arxiv.typ": *
//   #show: arxiv.with(lab: 2, title: "Операторы цикла", ...)
// ============================================================================

// --- шрифты: Computer Modern (дефолт typst) + системный моноширинный --------

#let _mono = ("DejaVu Sans Mono", "Liberation Mono")

// --- геометрия страницы (по arkheion) ----------------------------------------

#let _margin = (top: 25mm, bottom: 30mm, left: 25mm, right: 25mm)
#let _text-width = 210mm - _margin.left - _margin.right   // 160 мм
#let _land-width = 297mm - _margin.left - _margin.right   // 247 мм

// --- главный show-rule --------------------------------------------------------

#let arxiv(
  lab: none,
  title: "",
  discipline: "Основы алгоритмизации и программирования",
  group: "",
  variant: none,
  student: "",
  teacher: "",
  city: "Минск",
  year: none,
  goal: none,   // цель работы — блок-аннотация на первой странице тела
  it,
) = {
  set document(
    title: if lab != none { "Отчёт по лабораторной работе №" + str(lab) + " — " + title } else { title },
    author: student,
  )

  // страница: А4, поля arkheion, номер снизу по центру
  set page(width: 21cm, height: 29.7cm, margin: _margin,
    numbering: "1", number-align: center)

  // ======================= титульный лист — вербатим из oaip.typ ============
  {
    set text(font: ("Times New Roman", "Liberation Serif", "Noto Serif"),
      size: 14pt, lang: "ru")
    set page(numbering: none)
    set par(first-line-indent: 0mm, justify: false, spacing: 0em)

    align(center)[
      #text(size: 14pt)[
        Министерство образования Республики Беларусь \
        г. Минск \
        Государственное учреждение образования \
        «Белорусский государственный университет \
        информатики и радиоэлектроники»
      ]
    ]

    v(1fr)

    align(center)[
      #text(size: 16pt, weight: "bold")[
        Лабораторная работа #if lab != none [№ #lab]
      ]

      #v(8pt)
      #text(size: 14pt, weight: "bold")[«#title»]

      #if discipline != none [
        #v(4pt)
        #text(size: 14pt)[по дисциплине «#discipline»]
      ]

      #if variant != none [
        #v(4pt)
        #text(size: 14pt, weight: "bold")[Вариант #variant]
      ]

      #v(12pt)
      #text(size: 14pt, weight: "bold")[Учебная группа #group]
    ]

    v(1fr)

    grid(
      columns: (1.15fr, 1fr),
      [],
      [*Выполнил:* #student \
       *Проверил:* #teacher],
    )

    v(1fr)

    align(center)[#city #year]

    pagebreak()
  }

  // титульник — страница 1 без номера
  counter(page).update(2)

  // ======================= тело в духе arXiv (по arkheion) ==================
  set text(font: "New Computer Modern", size: 11pt, lang: "ru", hyphenate: true)
  set par(justify: true, first-line-indent: (amount: 1.2em, all: true))

  // заголовки: нумерация «1», строчными, без разрыва страниц (arkheion)
  set heading(numbering: "1")
  show heading: it => {
    if it.level == 1 { pad(bottom: 10pt, it) }
    else if it.level == 2 { pad(bottom: 8pt, it) }
    else if it.level > 3 { text(11pt, weight: "bold", it.body + " ") }
    else { it }
  }

  // формулы: нумерация «(1)» справа, как в arkheion
  set math.equation(numbering: "(1)", number-align: right)
  show math.equation: set text(weight: 400)
  show math.equation: set block(spacing: 0.65em)

  // рисунки: подпись «Рис. 1: …» снизу, кегль чуть меньше текста
  set figure(supplement: [Рис.], numbering: "1", gap: 8pt)
  set figure.caption(position: bottom)
  show figure.caption: set text(size: 0.9em)
  show figure: set align(center)
  show figure: set par(first-line-indent: 0mm, justify: false)
  show figure: set block(breakable: false, above: 1em, below: 1em)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set align(left)

  // ===== первая страница тела: шапка препринта (линии, заголовок, аннотация)

  set par(first-line-indent: 0mm)

  line(length: 100%, stroke: 2pt)
  pad(bottom: 4pt, top: 4pt, align(center)[
    #block(text(weight: 500, 1.75em, title))
    #if lab != none [Лабораторная работа № #lab]
  ])
  line(length: 100%, stroke: 2pt)

  // авторская строка, как у arkheion: имя, аффилиация, дата
  pad(top: 0.5em, align(center)[
    #text(weight: "bold")[#student] \
    #discipline, группа #group \
    #if variant != none [вариант #variant · ]#city, #year
  ])

  // цель работы — блок-аннотация с smallcaps-заголовком (arkheion «Abstract»)
  if goal != none {
    pad(x: 3em, top: 1em, bottom: 0.4em, align(center)[
      #heading(outlined: false, numbering: none,
        text(0.85em, smallcaps[Цель работы]))
      #set par(justify: true)
      #set text(hyphenate: false)
      #align(left, goal)
    ])
  }

  // тело снова с абзацными отступами
  set par(first-line-indent: (amount: 1.2em, all: true))

  it
}

// --- помощники для отчёта (как в oaip.typ, но в препечатной стилистике) -----

// Листинг: моноширинный на светло-серой плашке, подпись «Листинг N: …» снизу.
// source — строка с кодом (например, read("../1/main.c")).
#let listing(source, caption: none, lang: "c", line-numbers: true, size: 0.75em) = figure(
  kind: "listing",
  supplement: [Листинг],
  numbering: "1",
  caption: caption,
  block(width: 100%, fill: luma(248), radius: 4pt, inset: 10pt, {
    set align(left)
    set text(font: _mono, size: size)
    set par(justify: false, leading: 0.62em, spacing: 0.62em, first-line-indent: 0mm)
    set raw(align: left, tab-size: 4)
    show raw.line: it => if line-numbers {
      box(width: 1.9em, align(right, text(fill: luma(120), str(it.number)))) + h(6pt) + it
    } else {
      it
    }
    raw(source, lang: lang)
  }),
)

// Скриншот результата: по центру, подпись «Рис. N: …» снизу.
#let shot(path, caption: none, width: 88%) = figure(
  image(path, width: width),
  caption: caption,
)

// Блок-схемы gostpadi: пачка рисуется в одном масштабе, поэтому вставляем
// в натуральном размере (SVG несёт его в заголовке, PNG — через scheme-scale);
// всё, что шире колонки, ужимается до неё.

#let scheme-scale = 0.05   // мм на пиксель PNG (старый python-gostpadi)

#let _svg-pt(path) = {
  let s = read(path)
  let a = s.position("width=\"") + 7
  let tail = s.slice(a)
  float(tail.slice(0, tail.position("pt\"")))
}

#let _png-px(path) = {
  let b = read(path, encoding: none)
  (
    int.from-bytes(b.slice(16, 20), endian: "big"),
    int.from-bytes(b.slice(20, 24), endian: "big"),
  )
}

#let _fit-width(path, max) = {
  let natural = if path.ends-with(".svg") {
    _svg-pt(path) * 1pt
  } else {
    let (wpx, _) = _png-px(path)
    wpx * scheme-scale * 1mm
  }
  calc.min(natural, max)
}

#let flow(path, caption: none, max: 100%) = figure(
  image(path, width: _fit-width(path, _text-width * max)),
  caption: caption,
)

// Очень широкая схема: альбомный лист, масштаб пачки сохраняется.
#let flow-wide(path, caption: none) = page(
  flipped: true,
  numbering: "1",
  number-align: center,
  {
    set align(center)
    v(1fr)
    figure(
      image(path, width: _fit-width(path, _land-width * 0.98)),
      caption: caption,
    )
    v(1fr)
  },
)

// Русские псевдонимы — можно писать по-русски.
#let листинг = listing
#let скрин = shot
#let схема = flow
