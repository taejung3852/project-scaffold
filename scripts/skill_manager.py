#!/usr/bin/env python3
"""
skill_manager.py — skill CRUD
Usage:
  python3 scripts/skill_manager.py create <name>
  python3 scripts/skill_manager.py list
  python3 scripts/skill_manager.py archive <name>
  python3 scripts/skill_manager.py restore <name>
  python3 scripts/skill_manager.py delete <name>
"""
import json
import shutil
import sys
from pathlib import Path

SKILLS_DIR = Path("skills")
ARCHIVE_DIR = Path("skills/.archive")
USAGE_FILE = Path("skills/.usage.json")

SKILL_TEMPLATE = """\
# /{name} — [스킬 설명]

[스킬 목적을 한 줄로]

---

> **추적:** `python3 scripts/skill_usage.py track {name}`

---

## Step 1 — [첫 번째 단계]

[단계 설명]

---

## 규칙

| 항목 | 규칙 |
|---|---|
| | |
"""


def load_usage() -> dict:
    if USAGE_FILE.exists():
        return json.loads(USAGE_FILE.read_text())
    return {"skills": {}}


def create(name: str):
    skill_dir = SKILLS_DIR / name
    if skill_dir.exists():
        print(f"이미 존재: skills/{name}/")
        sys.exit(1)
    skill_dir.mkdir(parents=True)
    (skill_dir / "SKILL.md").write_text(SKILL_TEMPLATE.format(name=name))
    print(f"✓ 생성: skills/{name}/SKILL.md")


def list_skills():
    usage = load_usage().get("skills", {})

    active = sorted(
        d for d in SKILLS_DIR.iterdir()
        if d.is_dir() and not d.name.startswith(".")
    )

    print("### 활성 스킬")
    for d in active:
        info = usage.get(d.name, {})
        count = info.get("count", 0)
        last = info.get("last_used", "기록 없음")
        print(f"- {d.name}: {count}회 | 최근 {last}")
    if not active:
        print("- 없음")
    if len(active) <= 3:
        print(f"\n⚠️  활성 스킬이 {len(active)}개입니다. /curate는 아카이브를 자동 차단합니다.")

    print()
    print("### 아카이브")
    if ARCHIVE_DIR.exists():
        archived = sorted(d for d in ARCHIVE_DIR.iterdir() if d.is_dir())
        for d in archived:
            info = usage.get(d.name, {})
            print(f"- {d.name}: {info.get('count', 0)}회 (archived)")
        if not archived:
            print("- 없음")
    else:
        print("- 없음")


def archive_skill(name: str):
    skill_dir = SKILLS_DIR / name
    if not skill_dir.exists():
        print(f"스킬 없음: skills/{name}/")
        sys.exit(1)
    active = [d for d in SKILLS_DIR.iterdir() if d.is_dir() and not d.name.startswith(".")]
    if len(active) <= 3:
        print(f"활성 스킬이 {len(active)}개입니다. 최소 3개 유지 원칙에 따라 아카이브할 수 없습니다.")
        sys.exit(1)
    ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
    archive_target = ARCHIVE_DIR / name
    if archive_target.exists():
        print(f"⚠️  이미 아카이브됨: {name}. 먼저 restore 또는 delete를 실행하세요.")
        sys.exit(1)
    shutil.move(str(skill_dir), str(archive_target))
    print(f"✓ 아카이브: skills/{name}/ → skills/.archive/{name}/")


def restore_skill(name: str):
    src = ARCHIVE_DIR / name
    if not src.exists():
        print(f"아카이브에 없음: {name}")
        sys.exit(1)
    shutil.move(str(src), str(SKILLS_DIR / name))
    print(f"✓ 복원: skills/.archive/{name}/ → skills/{name}/")


def delete_skill(name: str):
    skill_dir = SKILLS_DIR / name
    if not skill_dir.exists():
        print(f"스킬 없음: skills/{name}/")
        sys.exit(1)
    answer = input(f"'{name}' 스킬을 삭제합니까? (yes/no): ")
    if answer.strip().lower() != "yes":
        print("취소.")
        return
    shutil.rmtree(str(skill_dir))
    print(f"✓ 삭제: skills/{name}/")


def cli():
    if len(sys.argv) < 2:
        print("Usage: skill_manager.py <create|list|archive|restore|delete> [name]")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "create":
        if len(sys.argv) < 3:
            print("Usage: skill_manager.py create <name>")
            sys.exit(1)
        create(sys.argv[2])
    elif cmd == "list":
        list_skills()
    elif cmd == "archive":
        if len(sys.argv) < 3:
            print("Usage: skill_manager.py archive <name>")
            sys.exit(1)
        archive_skill(sys.argv[2])
    elif cmd == "restore":
        if len(sys.argv) < 3:
            print("Usage: skill_manager.py restore <name>")
            sys.exit(1)
        restore_skill(sys.argv[2])
    elif cmd == "delete":
        if len(sys.argv) < 3:
            print("Usage: skill_manager.py delete <name>")
            sys.exit(1)
        delete_skill(sys.argv[2])
    else:
        print(f"Unknown: {cmd}")
        sys.exit(1)


if __name__ == "__main__":
    cli()
