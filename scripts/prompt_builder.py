#!/usr/bin/env python3
"""
prompt_builder.py — 사용 데이터 기반 AGENT.md nudge 자동 갱신
Usage:
  python3 scripts/prompt_builder.py update
"""
import json
import re
import sys
from datetime import date, datetime
from pathlib import Path

USAGE_FILE = Path("skills/.usage.json")
AGENT_FILE = Path("AGENT.md")

STALE_DAYS = 30
CURATE_THRESHOLD = 50

START_MARKER = "<!-- prompt_builder_start -->"
END_MARKER = "<!-- prompt_builder_end -->"

# A 많이 쓰고 B 안 씀 → B 권장
SKILL_PAIRS = [
    ("capture", "ingest"),
    ("ingest", "query"),
    ("code-lint", "wiki-lint"),
]


def load_usage() -> dict:
    if USAGE_FILE.exists():
        return json.loads(USAGE_FILE.read_text())
    return {"skills": {}}


def build_nudge(data: dict) -> str:
    today = date.today()
    skills = data.get("skills", {})

    if not skills:
        return "(스킬 사용 기록 없음 — 스킬 실행 시 자동 갱신됩니다)"

    nudges = []

    for a, b in SKILL_PAIRS:
        a_count = skills.get(a, {}).get("count", 0)
        b_count = skills.get(b, {}).get("count", 0)
        if a_count >= 3 and b_count == 0:
            nudges.append(f"- `/{b}` 실행 권장: `/{a}`를 {a_count}회 사용했지만 `/{b}` 기록 없음")
        elif a_count > 0 and b_count > 0 and a_count >= b_count * 3:
            nudges.append(
                f"- `/{b}` 실행 권장: `/{a}`({a_count}회) 대비 `/{b}`({b_count}회) 사용 불균형"
            )

    for name, info in skills.items():
        last = datetime.strptime(info["last_used"], "%Y-%m-%d").date()
        d = (today - last).days
        if STALE_DAYS <= d < 90 and info["count"] >= 3:
            nudges.append(f"- `/{name}` stale: {d}일 미사용 (이전 {info['count']}회 사용)")

    total = sum(info["count"] for info in skills.values())
    if total >= CURATE_THRESHOLD:
        nudges.append(f"- `/curate` 실행 권장: 총 {total}회 호출 누적 — 스킬 진화 검토 시점")

    top = max(skills.items(), key=lambda x: x[1]["count"])
    nudges.append(f"- 최다 사용: `/{top[0]}` ({top[1]['count']}회)")

    lines = [f"_마지막 갱신: {today}_", "", *nudges]
    return "\n".join(lines)


def update():
    if not AGENT_FILE.exists():
        return

    content = AGENT_FILE.read_text()

    if START_MARKER not in content or END_MARKER not in content:
        return

    data = load_usage()
    nudge = build_nudge(data)
    new_block = f"{START_MARKER}\n{nudge}\n{END_MARKER}"

    updated = re.sub(
        rf"{re.escape(START_MARKER)}.*?{re.escape(END_MARKER)}",
        new_block,
        content,
        flags=re.DOTALL,
    )

    AGENT_FILE.write_text(updated)


def cli():
    if len(sys.argv) < 2:
        print("Usage: prompt_builder.py <update>")
        sys.exit(1)
    if sys.argv[1] == "update":
        update()
    else:
        print(f"Unknown: {sys.argv[1]}")
        sys.exit(1)


if __name__ == "__main__":
    cli()
