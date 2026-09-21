#!/usr/bin/env python3
"""Прогоняет настоящие бинарники и складывает реальный вывод в assets/term.json.

Отчёт рисует из этого JSON терминальные окна вектором (функция terminal()
в template/oaip.typ) — растр не нужен. Если вывод начался не с ожидаемого
приглашения или программа вернула неожидаемый код возврата, генерация
падает, чтобы рисунки не врали.

stdin запускается без псевдотерминала, поэтому эхо набранного ввода в
stdout не попадает, а приглашение printf печатается без перевода строки —
строки вывода «приглашение + ответ» склеены. Экран настоящего терминала
собирается функцией screen_lines: эхо ввода вставляется после каждого
приглашения, как это выглядело бы при наборе с клавиатуры.
"""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent  # home/
ASSETS = ROOT / "report" / "assets"
TITLE = "sehaxe@cachyos: ~/ОАиП-Лаба2/home"


def screen_lines(prompt: str | None, user_input: str, out_lines: list[str]) -> list[dict]:
    """Финальный экран сессии: эхо ввода на местах приглашений.

    stdout режется на группы по строкам, начинающимся с приглашения
    (само приглашение остаётся эху); k-я группа отвечает вводу k-й
    строки и рисуется сразу после его эха.
    """
    inputs = user_input.split("\n") if user_input else []
    if prompt is None:
        return [{"out": line} for line in out_lines]
    groups: list[list[str]] = []
    for line in out_lines:
        if line.startswith(prompt):
            groups.append([])
        groups[-1].append(line)
    if len(groups) > len(inputs):
        raise RuntimeError(f"приглашений {len(groups)} больше, чем строк ввода {len(inputs)}")
    lines: list[dict] = []
    for k, group in enumerate(groups):
        lines.append({"echo": {"prompt": prompt, "input": inputs[k]}})
        for text in group:
            body = text[len(prompt):] if text.startswith(prompt) else text
            if body:
                lines.append({"out": body})
    return lines


def run_task(n: int, prompt: str | None, runs: list[str]) -> list[dict]:
    """Сессия одной задачи: список раннов {cmd, lines}."""
    session = []
    for user_input in runs:
        proc = subprocess.run(
            [f"./{n}/main"],
            input=user_input + "\n",
            capture_output=True,
            text=True,
            cwd=ROOT,
        )
        if proc.returncode not in (0, 1):
            raise RuntimeError(f"task {n}: неожидаемый код возврата {proc.returncode}")
        if prompt is not None and not proc.stdout.startswith(prompt):
            raise RuntimeError(f"task {n}: вывод начался не с приглашения: {proc.stdout!r}")
        session.append({
            "cmd": f"./{n}/main",
            "lines": screen_lines(prompt, user_input, proc.stdout.splitlines()),
        })
    return session


# (приглашение до ввода, наборы вводов); None — программа ввода не читает.
# Программы с проверкой ввода при неверном значении запрашивают повторный,
# поэтому после плохого набора идёт хороший: сессия показывает и ошибку, и ответ.
SESSIONS = {
    1: ("Введите коэффициент: ", ["2", "-1\n2"]),
    2: (None, [""]),
    3: ("Введите числа a и b: ", ["48 36", "0 5\n48 36"]),
}

if __name__ == "__main__":
    ASSETS.mkdir(parents=True, exist_ok=True)
    data = {}
    for n, (prompt, runs) in SESSIONS.items():
        data[str(n)] = {"title": TITLE, "runs": run_task(n, prompt, runs)}
        print(f"ok: задача {n} ({len(runs)} запуска)")
    out = ASSETS / "term.json"
    out.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"ok: {out.relative_to(ROOT)}")
