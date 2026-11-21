#!/usr/bin/env python3
"""Count CodeQL results that are not under a dependency or build tree."""

import json
import sys
from pathlib import Path


def vendor(uri: str) -> bool:
    return "vcpkg_installed/" in uri or uri.startswith("build/") or "/build/" in uri


def counted(result: dict) -> bool:
    for loc in result.get("locations") or []:
        uri = ((loc.get("physicalLocation") or {}).get("artifactLocation") or {}).get("uri") or ""
        if vendor(uri):
            return False
    return True


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "codeql.sarif")
    paths = [root] if root.is_file() else sorted(root.glob("*.sarif"))
    total = 0
    for path in paths:
        for run in json.loads(path.read_text()).get("runs", []):
            total += sum(1 for result in run.get("results", []) if counted(result))
    print(total)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
