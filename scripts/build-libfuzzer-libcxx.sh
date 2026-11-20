#!/bin/sh
# Build libFuzzer against libc++. The Ubuntu clang package ships
# libclang_rt.fuzzer built with libstdc++. ci-cpp-opencv's OpenCV is libc++,
# so -fsanitize=fuzzer cannot link that image. Callers pass fuzzer-no-link
# and this archive instead.
set -eu

out="${1:?output directory}"
mkdir -p "${out}"
src="${out}/src"
if [ ! -f "${src}/compiler-rt/lib/fuzzer/FuzzerDriver.cpp" ]; then
	rm -rf "${src}"
	git clone --depth 1 --filter=blob:none --sparse \
		--branch llvmorg-18.1.3 \
		https://github.com/llvm/llvm-project.git "${src}"
	git -C "${src}" sparse-checkout set compiler-rt/lib/fuzzer
fi

obj="${out}/obj"
rm -rf "${obj}"
mkdir -p "${obj}"
for cpp in "${src}/compiler-rt/lib/fuzzer/"*.cpp; do
	base=$(basename "${cpp}")
	case "${base}" in
	*Windows* | *Darwin* | *Fuchsia* | *Emscripten*) continue ;;
	esac
	clang++ -std=c++17 -stdlib=libc++ -fsanitize=address -g -O2 \
		-c "${cpp}" -o "${obj}/${base}.o"
done
rm -f "${out}/libFuzzer.a"
ar rcs "${out}/libFuzzer.a" "${obj}/"*.o
echo "built ${out}/libFuzzer.a"
