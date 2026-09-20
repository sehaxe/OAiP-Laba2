#!/usr/bin/env python3
"""Прогоняет настоящие бинарники и складывает реальный вывод в assets/term.json.

Отчёт рисует из этого JSON терминальные окна вектором (функция terminal()
в template/oaip.typ) — растр не нужен. Если вывод начался не с ожидаемого
приглашения или программа вернула неожидаемый код возврата, генерация
падает, чтобы рисунки не врали.
"""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent  # home/
ASSETS = ROOT / "report" / "assets"
TITLE = "sehaxe@cachyos: ~/ОАиП-Лаба2/home"


def run_task(n: int, prompt: str | None, runs: list[str]) -> list[dict]:
    """Сессия одной задачи: список раннов {cmd, prompt, input, out}."""
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
        out = proc.stdout
        if prompt is not None:
            if not out.startswith(prompt):
                raise RuntimeError(f"task {n}: вывод начался не с приглашения: {out!r}")
            body = out[len(prompt):]
        else:
            body = out
        lines = body.splitlines()
        # перевод строки из самого вывода завершает строку «приглашение + эхо»
        if prompt is not None and lines and lines[0] == "":
            lines = lines[1:]
        session.append({
            "cmd": f"./{n}/main",
            "prompt": prompt,
            "input": user_input,
            "out": lines,
        })
    return session


# (приглашение до ввода, наборы вводов); None — программа ввода не читает
SESSIONS = {
    1: ("Введите коэффициент: ", ["2", "-1"]),
    2: (None, [""]),
    3: ("Введите числа a и b: ", ["48 36", "0 5"]),
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
