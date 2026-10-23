#!/usr/bin/env python3
"""Public API documentation coverage from the Clang AST (CPP-DOC-001).

Counts public declarations in public headers. A declaration counts as
documented when its comment starts with ``/**``, ``/*!``, or ``///``.
Unknown libclang cursor kinds are skipped; their children are still walked.
"""

from __future__ import annotations

import argparse
import glob
import sys
import tempfile
from pathlib import Path

from clang import cindex

PUBLIC_SUFFIXES = {".h", ".hh", ".hpp", ".hxx"}
DOCUMENTED_PREFIXES = ("/**", "/*!", "///")
COUNTED_KINDS = {
    "NAMESPACE",
    "CLASS_DECL",
    "STRUCT_DECL",
    "CLASS_TEMPLATE",
    "FUNCTION_DECL",
    "FUNCTION_TEMPLATE",
    "CXX_METHOD",
    "CONSTRUCTOR",
    "ENUM_DECL",
    "TYPE_ALIAS_DECL",
    "TYPE_ALIAS_TEMPLATE_DECL",
    "CONCEPT_DECL",
}


def library_file() -> str:
    matches = sorted(glob.glob("/usr/lib/llvm*/lib/libclang.so*"))
    if not matches:
        print("error: libclang not found under /usr/lib/llvm*/lib", file=sys.stderr)
        sys.exit(1)
    unsuffixed = [path for path in matches if path.endswith("/libclang.so")]
    return unsuffixed[0] if unsuffixed else matches[0]


def public_headers(include: Path) -> list[Path]:
    headers: list[Path] = []
    for path in sorted(include.rglob("*")):
        if not path.is_file() or path.suffix not in PUBLIC_SUFFIXES:
            continue
        if "detail" in path.parts:
            continue
        headers.append(path)
    return headers


def is_public_header(filename: str | None, include: Path) -> bool:
    if not filename:
        return False
    path = Path(filename)
    try:
        relative = path.resolve().relative_to(include.resolve())
    except ValueError:
        return False
    return path.suffix in PUBLIC_SUFFIXES and "detail" not in relative.parts


def documented(node: cindex.Cursor) -> bool:
    comment = node.raw_comment or ""
    return comment.lstrip().startswith(DOCUMENTED_PREFIXES)


def walk(node: cindex.Cursor, include: Path, seen: dict[str, bool]) -> None:
    try:
        kind = node.kind
    except ValueError:
        for child in node.get_children():
            walk(child, include, seen)
        return
    kind_name = kind.name if kind is not None else ""
    if kind_name in COUNTED_KINDS and is_public_header(
        node.location.file.name if node.location.file else None, include
    ):
        access = node.access_specifier
        hidden = access in (
            cindex.AccessSpecifier.PRIVATE,
            cindex.AccessSpecifier.PROTECTED,
        )
        in_detail = False
        parent = node.semantic_parent
        for _ in range(32):
            if parent is None:
                break
            try:
                parent_kind = parent.kind
            except ValueError:
                break
            if parent_kind == cindex.CursorKind.NAMESPACE and parent.spelling == "detail":
                in_detail = True
                break
            parent = parent.semantic_parent
        if not hidden and not in_detail and node.spelling:
            seen.setdefault(node.get_usr() or f"{kind_name}:{node.spelling}:{node.location}", documented(node))
    for child in node.get_children():
        walk(child, include, seen)


def parse_tu(index: cindex.Index, source: str, args: list[str]) -> cindex.TranslationUnit:
    tu = index.parse(source, args=args)
    if tu is None:
        print(f"error: clang failed to parse {source}", file=sys.stderr)
        sys.exit(1)
    errors = [diag for diag in tu.diagnostics if diag.severity >= cindex.Diagnostic.Error]
    for diag in errors:
        print(diag, file=sys.stderr)
    if errors:
        sys.exit(1)
    return tu


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--threshold", required=True, type=float)
    parser.add_argument("--include", default="include")
    parser.add_argument("clang_args", nargs="*")
    args = parser.parse_args()

    root = args.root.resolve()
    include = (root / args.include).resolve()
    headers = public_headers(include)
    if not headers:
        print(f"error: no public headers under {include}", file=sys.stderr)
        sys.exit(1)

    cindex.Config.set_library_file(library_file())
    index = cindex.Index.create()
    clang_args = [
        "-std=c++20",
        "-stdlib=libc++",
        "-I",
        str(include),
        "-xc++",
        *args.clang_args,
    ]
    lines = ['#include "' + path.relative_to(include).as_posix() + '"' for path in headers]
    with tempfile.NamedTemporaryFile("w", suffix=".cpp", delete=False) as handle:
        handle.write("\n".join(lines) + "\n")
        source = handle.name
    tu = parse_tu(index, source, clang_args)
    seen: dict[str, bool] = {}
    walk(tu.cursor, include, seen)
    total = len(seen)
    if total == 0:
        print("error: the AST contained no public declarations", file=sys.stderr)
        sys.exit(1)
    covered = sum(1 for ok in seen.values() if ok)
    ratio = 100.0 * covered / total
    print(f"doc_coverage: {covered}/{total} = {ratio:.1f}% (threshold {args.threshold})")
    if ratio + 1e-9 < args.threshold:
        sys.exit(1)


if __name__ == "__main__":
    main()
