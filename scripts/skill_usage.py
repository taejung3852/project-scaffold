#!/usr/bin/env python3
"""
skill_usage.py — skills/.usage.json 읽기/쓰기 전담
Usage:
  python3 scripts/skill_usage.py track <skill-name>
  python3 scripts/skill_usage.py list
  python3 scripts/skill_usage.py get <skill-name>
"""
import json
import subprocess
import sys
from datetime import date
from pathlib import Path

USAGE_FILE = Path("skills/.usage.json")


def load() -> dict:
    if USAGE_FILE.exists():
        return json.loads(USAGE_FILE.read_text())
    return {"skills": {}}  # 파일 없음 — 초기 상태 반환


def save(data: dict):
    USAGE_FILE.parent.mkdir(parents=True, exist_ok=True)
    USAGE_FILE.write_text(json.dumps(data, ensure_ascii=False, indent=2))


def track(name: str):
    data = load()
    today = date.today().isoformat()
    if name not in data["skills"]:
        data["skills"][name] = {"count": 0, "last_used": today, "first_used": today}
    entry = data["skills"][name]
    entry["count"] += 1
    entry["last_used"] = today
    save(data)
    subprocess.run(
        ["python3", "scripts/prompt_builder.py", "update"],
        capture_output=True,
    )


def cli():
    if len(sys.argv) < 2:
        print("Usage: skill_usage.py <track|list|get> [skill-name]")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "track":
        if len(sys.argv) < 3:
            print("Usage: skill_usage.py track <skill-name>")
            sys.exit(1)
        track(sys.argv[2])

    elif cmd == "list":
        data = load()
        if not data["skills"]:
            print("사용 기록 없음.")
            return
        for name, info in sorted(data["skills"].items(), key=lambda x: -x[1]["count"]):
            print(f"{name}: {info['count']}회 | 최근 {info['last_used']}")

    elif cmd == "get":
        if len(sys.argv) < 3:
            print("Usage: skill_usage.py get <skill-name>")
            sys.exit(1)
        data = load()
        name = sys.argv[2]
        if name not in data["skills"]:
            print(f"'{name}' 기록 없음.")
            sys.exit(1)
        print(json.dumps(data["skills"][name], ensure_ascii=False, indent=2))

    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)


if __name__ == "__main__":
    cli()
