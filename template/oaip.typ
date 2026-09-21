// ============================================================================
// oaip.typ — шаблон отчёта по лабораторным работам по ОАиП (БГУИР).
// Титульный лист — по образцу кафедры; тело свёрстано как препринт arXiv
// (по мотивам пакета @preview/arkheion): New Computer Modern, шапка
// «линия — заголовок — линия», цель работы как аннотация, заголовки
// без прописных и без разрыва страниц, номер страницы снизу по центру.
// Прежний СТП-стиль живёт в oaip-legacy.typ.
//
// Использование — те же параметры, что и раньше:
//   #import "../../template/oaip.typ": *
//   #show: oaip.with(lab: 2, title: "Операторы цикла", ...)
// ============================================================================

// --- шрифты: Computer Modern (дефолт typst) + системный моноширинный --------

#let _mono = ("DejaVu Sans Mono", "Liberation Mono")

// --- геометрия страницы (по arkheion) ----------------------------------------

#let _margin = (top: 25mm, bottom: 30mm, left: 25mm, right: 25mm)
#let _text-width = 210mm - _margin.left - _margin.right   // 160 мм
#let _text-height = 297mm - _margin.top - _margin.bottom  // 242 мм
#let _land-width = 297mm - _margin.left - _margin.right   // 247 мм
#let _land-height = 210mm - _margin.top - _margin.bottom  // 155 мм
#let _fig-cap = 26pt  // запас под подпись рисунка при вписывании по высоте

// --- главный show-rule --------------------------------------------------------

#let oaip(
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

// Терминальное окно, нарисованное вектором прямо в PDF (не растр).
// Данные — JSON от report/make_screens.py: скрипт прогоняет настоящие
// бинарники и складывает в assets/term.json построчный экран каждой
// сессии (эхо ввода после каждого приглашения — как в настоящем
// терминале), поэтому текст на рисунке всегда настоящий; здесь он
// только отрисовывается.
#let terminal(json-path, n: 1, caption: none) = {
  let s = json(json-path).at(str(n))
  let user = text(fill: rgb("#1a7f37"), size: 8.5pt)[sehaxe]
  let host = text(fill: rgb("#6e7781"), size: 8.5pt)[\@cachyos:]
  let dir = text(fill: rgb("#0969da"), size: 8.5pt)[~/ОАиП-Лаба2/home]
  let dollar = text(fill: rgb("#8250df"), size: 8.5pt)[\$ ]
  let runs = s.runs.map(run => {
    let cmd = par[#user#host#dir#dollar#text(fill: rgb("#24292f"), size: 8.5pt, run.cmd)]
    let lines = run.lines.map(l => if l.at("echo", default: none) != none {
      // приглашение + эхо набранного ввода
      par[#text(fill: rgb("#24292f"), size: 8.5pt, l.echo.prompt)#text(fill: rgb("#bc4c00"), size: 8.5pt, l.echo.input)]
    } else {
      par[#text(fill: rgb("#24292f"), size: 8.5pt, l.out)]
    })
    (cmd,) + lines
  }).flatten()
  let body = if runs.len() > 0 { runs.first() } else { [] }
  for l in runs.slice(1) {
    body += v(7pt)
    body += l
  }
  figure(
    block(width: 100%, fill: white, stroke: 0.7pt + luma(201), radius: 7pt,
      inset: 0pt, {
        block(fill: luma(238), radius: (top-left: 7pt, top-right: 7pt,
          bottom-right: 0pt, bottom-left: 0pt), inset: (x: 10pt, y: 6pt))[
          #grid(columns: (auto, 1fr, auto), align: (left, center, right),
            grid(columns: (auto, auto, auto), gutter: 5pt,
              box(circle(radius: 4pt, fill: rgb("#ff5f56"))),
              box(circle(radius: 4pt, fill: rgb("#ffbd2e"))),
              box(circle(radius: 4pt, fill: rgb("#27c93f")))),
            text(fill: rgb("#6e7781"), size: 8pt)[#s.title],
            h(1pt),
          )
        ]
        block(width: 100%, inset: (top: 10pt, right: 14pt, bottom: 12pt, left: 12pt))[
          #set align(left)
          #set text(font: _mono, size: 8.5pt)
          #set par(justify: false, leading: 0.72em, spacing: 0.72em,
            first-line-indent: 0mm)
          #body
        ]
      }),
    caption: caption,
  )
}

// Блок-схемы gostpadi: пачка рисуется в одном масштабе (--no-split —
// схема одним листом), вставляем в натуральном размере; всё, что не
// влезает в колонку по ширине или в полосу по высоте, ужимается до неё.

#let scheme-scale = 0.05   // мм на пиксель PNG (старый python-gostpadi)

#let _svg-size(path) = {
  // ширина и высота из заголовка SVG (первое вхождение — корневой тег)
  let s = read(path)
  let w = s.slice(s.position("width=\"") + 7)
  let w = float(w.slice(0, w.position("pt\"")))
  let h = s.slice(s.position("height=\"") + 8)
  let h = float(h.slice(0, h.position("pt\"")))
  (w, h)
}

#let _png-px(path) = {
  let b = read(path, encoding: none)
  (
    int.from-bytes(b.slice(16, 20), endian: "big"),
    int.from-bytes(b.slice(20, 24), endian: "big"),
  )
}

// Коэффициент вставки и натуральная ширина: размер ужатый до
// max-w × max-h, но только вниз (мелкие схемы не растягиваются).
#let _fit-both(path, max-w, max-h) = {
  let (nat-w, nat-h) = if path.ends-with(".svg") {
    let (w, h) = _svg-size(path)
    (w * 1pt, h * 1pt)
  } else {
    let (wpx, hpx) = _png-px(path)
    (wpx * scheme-scale * 1mm, hpx * scheme-scale * 1mm)
  }
  (calc.min(1, max-w / nat-w, max-h / nat-h), nat-w)
}

#let flow(path, caption: none, max: 100%) = {
  let (s, nat-w) = _fit-both(path, _text-width * max, _text-height - _fig-cap)
  figure(align(center, image(path, width: s * nat-w)), caption: caption)
}

// Очень широкая схема: альбомный лист, масштаб пачки сохраняется.
#let flow-wide(path, caption: none) = page(
  flipped: true,
  numbering: "1",
  number-align: center,
  {
    let (s, nat-w) = _fit-both(path, _land-width * 0.98, _land-height - _fig-cap)
    set align(center)
    v(1fr)
    figure(align(center, image(path, width: s * nat-w)), caption: caption)
    v(1fr)
  },
)

// Русские псевдонимы — можно писать по-русски.
#let листинг = listing
#let скрин = shot
#let схема = flow
