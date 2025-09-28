#!/usr/bin/env bash
set -euo pipefail

# 1) Configure and build C/C++ (no Python, no scikit-build)
cmake -S . -B build/linux \
  -DBUILD_SHARED_LIBS=Off \
  -DG2O_BUILD_PYTHON=On \
  -DG2O_BUILD_APPS=Off \
  -DG2O_BUILD_EXAMPLES=Off \
  -DG2O_USE_OPENGL=Off \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build/linux --config Release -j $(nproc)

echo "Native build done. Next: stage artifacts to python package dir."


# --- Step 2: Stage compiled Python extension(s) into package dir ---
PKG_DIR="python/g2opy"
mkdir -p "$PKG_DIR"

# Adjust these globs if your .so/.pyd end up deeper
shopt -s nullglob
cp build/linux/*/*.{so,pyd,dylib,dll} "$PKG_DIR" 2>/dev/null || true
cp build/linux/*.{so,pyd,dylib,dll}     "$PKG_DIR" 2>/dev/null || true

echo "Installed C++ libs and staged Python extensions into $PKG_DIR"