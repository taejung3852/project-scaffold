#!/usr/bin/env python3
"""
curator.py — 스킬 상태 머신 + 진화 리포트
Usage:
  python3 scripts/curator.py report
  python3 scripts/curator.py archive
"""
import json
import shutil
import sys
from datetime import date, datetime
from pathlib import Path

USAGE_FILE = Path("skills/.usage.json")
SKILLS_DIR = Path("skills")
ARCHIVE_DIR = Path("skills/.archive")

STALE_DAYS = 30
ARCHIVE_DAYS = 90


def load_usage() -> dict:
    if USAGE_FILE.exists():
        return json.loads(USAGE_FILE.read_text())
    return {"skills": {}}


def days_since(last_used: str) -> int:
    return (date.today() - datetime.strptime(last_used, "%Y-%m-%d").date()).days


def classify(info: dict) -> str:
    d = days_since(info["last_used"])
    if d >= ARCHIVE_DAYS:
        return "archive"
    if d >= STALE_DAYS:
        return "stale"
    return "active"


def report():
    data = load_usage()
    today = date.today()
    buckets: dict[str, list] = {"active": [], "stale": [], "archive": []}

    for name, info in data["skills"].items():
        d = days_since(info["last_used"])
        state = classify(info)
        buckets[state].append({"name": name, "count": info["count"], "days_since": d})

    for lst in buckets.values():
        lst.sort(key=lambda x: x["count"], reverse=True)

    print(f"## curator.py 리포트 — {today}")
    print()

    print("### ✅ 활성")
    for s in buckets["active"]:
        print(f"- {s['name']}: {s['count']}회 | {s['days_since']}일 전 사용")
    if not buckets["active"]:
        print("- 없음")
    print()

    print("### 🟡 Stale (30일+ 미사용)")
    for s in buckets["stale"]:
        print(f"- {s['name']}: {s['count']}회 | {s['days_since']}일 미사용")
    if not buckets["stale"]:
        print("- 없음")
    print()

    print("### 🔴 Archive 대상 (90일+ 미사용)")
    for s in buckets["archive"]:
        print(f"- {s['name']}: {s['count']}회 | {s['days_since']}일 미사용")
    if not buckets["archive"]:
        print("- 없음")
    print()

    active_names = [s["name"] for s in buckets["active"]]
    if len(active_names) >= 2:
        print("### 클러스터링 힌트 (LLM 판단 대상)")
        print(f"활성 스킬 {len(active_names)}개: {', '.join(active_names)}")
        print("→ /curate 스킬이 이 목록을 읽고 통합 여부를 판단합니다.")
        print()

    total = sum(info["count"] for info in data["skills"].values())
    print(f"총 호출: {total}회 | 추적 스킬: {len(data['skills'])}개")


def archive_stale():
    data = load_usage()
    ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)

    active_on_disk = [
        name for name, info in data["skills"].items()
        if classify(info) != "archive" and (SKILLS_DIR / name).exists()
    ]

    if len(active_on_disk) <= 3:
        print(f"활성 스킬이 {len(active_on_disk)}개입니다. 아카이브를 건너뜁니다.")
        return

    archived = []
    for name, info in data["skills"].items():
        if classify(info) == "archive":
            skill_dir = SKILLS_DIR / name
            if skill_dir.exists():
                shutil.move(str(skill_dir), str(ARCHIVE_DIR / name))
                archived.append(name)
                print(f"✓ {name} → skills/.archive/{name}/")

    if not archived:
        print("아카이브할 스킬 없음.")
    else:
        print(f"\n{len(archived)}개 아카이브 완료.")


def cli():
    if len(sys.argv) < 2:
        print("Usage: curator.py <report|archive>")
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "report":
        report()
    elif cmd == "archive":
        archive_stale()
    else:
        print(f"Unknown: {cmd}")
        sys.exit(1)


if __name__ == "__main__":
    cli()
