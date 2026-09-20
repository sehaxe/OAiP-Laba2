#!/usr/bin/env python3
"""Генерирует скриншоты результатов (assets/term_taskN.png) из реальных запусков программ.

Каждая сессия прогоняется через настоящий бинарник: если вывод начался не с
ожидаемого приглашения или программа вернула неожидаемый код возврата,
генерация падает, чтобы скриншоты не врали.

Приглашение без перевода строки, поэтому ввод рисуется в одну строку с ним —
как эхо настоящего терминала.
"""
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent  # home/
ASSETS = ROOT / "report" / "assets"

# символов в строке -> пунктов: DejaVu Sans Mono, advance 0.602em
CHAR_PT = 5.45
SIZE = 9
MIN_WIDTH = 420


def escape(s: str) -> str:
    for ch in "\\#*_`$@<>[]":
        s = s.replace(ch, "\\" + ch)
    return s


def run_task(n: int, prompt: str | None, runs: list[str]) -> tuple[str, int]:
    """Терминальные строки одной задачи + ширина окна в пунктах."""
    lines = []
    maxlen = 0
    for i, user_input in enumerate(runs):
        proc = subprocess.run(
            [f"./{n}/main"],
            input=user_input + "\n",
            capture_output=True,
            text=True,
            cwd=ROOT,
        )
        if proc.returncode not in (0, 1):
            raise RuntimeError(f"task {n}: неожидаемый код возврата {proc.returncode}")
        out = proc.stdout
        if i > 0:
            lines.append("#v(7pt)")
        lines.append(f"#cmdline[./{n}/main] \\")
        if prompt is not None:
            if not out.startswith(prompt):
                raise RuntimeError(f"task {n}: вывод начался не с приглашения: {out!r}")
            body = out[len(prompt):]
            maxlen = max(maxlen, len(prompt) + len(user_input))
        else:
            body = out
        rest = body.splitlines()
        # перевод строки из самого вывода завершает строку «приглашение + эхо»
        if prompt is not None and rest and rest[0] == "":
            rest = rest[1:]
        if prompt is not None:
            lines.append(f"#oline[{escape(prompt)}]#iline[{escape(user_input)}] \\")
        elif user_input:
            lines.append(f"#iline[{escape(user_input)}] \\")
        for l in rest:
            lines.append(f"#oline[{escape(l)}] \\")
            maxlen = max(maxlen, len(l))
    width = max(MIN_WIDTH, round(maxlen * CHAR_PT) + 32)
    return " \n".join(lines), width


TEMPLATE = r'''#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: ("DejaVu Sans Mono", "Noto Sans CJK TC"), size: 9pt, lang: "ru")
#let dots = grid(columns: (auto, auto, auto), gutter: 5pt,
  box(circle(radius: 4pt, fill: rgb("#ff5f56"))),
  box(circle(radius: 4pt, fill: rgb("#ffbd2e"))),
  box(circle(radius: 4pt, fill: rgb("#27c93f"))))
#let cmdline(t) = {
  text(fill: rgb("#1a7f37"))[sehaxe]
  text(fill: rgb("#6e7781"))[\@cachyos:]
  text(fill: rgb("#0969da"))[\~/ОАиП-Лаба2/home]
  text(fill: rgb("#8250df"))[\$ ]
  text(fill: rgb("#24292f"))[#t]
}
#let oline(t) = text(fill: rgb("#24292f"))[#t]
#let iline(t) = text(fill: rgb("#bc4c00"))[#t]
#block(fill: white, stroke: 0.7pt + rgb("#c9c9c9"), radius: 7pt, width: {width}pt, inset: 0pt)[
  #block(fill: rgb("#eeeef0"), radius: (top-left: 7pt, top-right: 7pt, bottom-right: 0pt, bottom-left: 0pt), inset: (x: 10pt, y: 6pt))[
    #grid(columns: (auto, 1fr, auto), align: (left, center, right),
      dots,
      text(fill: rgb("#6e7781"), size: 8pt)[sehaxe\@cachyos: \~/ОАиП-Лаба2/home],
      h(1pt),
    )
  ]
  #block(inset: (top: 10pt, right: 14pt, bottom: 12pt, left: 12pt))[
{body}
  ]
]
'''

# (приглашение до ввода, наборы вводов); None — программа ввода не читает
SESSIONS = {
    1: ("Введите коэффициент: ", ["2", "-1"]),
    2: (None, [""]),
    3: ("Введите числа a и b: ", ["48 36", "0 5"]),
}

if __name__ == "__main__":
    ASSETS.mkdir(parents=True, exist_ok=True)
    for n, (prompt, runs) in SESSIONS.items():
        body, width = run_task(n, prompt, runs)
        typ_path = ASSETS / f"term_task{n}.typ"
        typ_path.write_text(
            TEMPLATE.replace("{width}", str(width)).replace("{body}", body),
            encoding="utf-8",
        )
        subprocess.run(
            ["typst", "compile", str(typ_path), str(ASSETS / f"term_task{n}.png"),
             "--format", "png", "--ppi", "192"],
            check=True,
        )
        print(f"ok: assets/term_task{n}.png (width {width}pt)")
