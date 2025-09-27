#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./run.bash              # C++-only build (no Python)
#   ./run.bash --python     # Build C++ + Python bindings (reused by pyproject.toml)

WITH_PYTHON=0
if [[ "${1:-}" == "--python" ]]; then
  WITH_PYTHON=1
fi

# Build/install locations
BUILD_DIR=${BUILD_DIR:-build}
INSTALL_PREFIX=${INSTALL_PREFIX:-"${PWD}/install"}

# Core CMake options shared by both modes
COMMON_CMAKE_ARGS=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"
  -DBUILD_SHARED_LIBS=Off
  -DG2O_BUILD_APPS=Off
  -DG2O_BUILD_EXAMPLES=Off
  -DG2O_USE_OPENGL=Off
)

# Python toggle
if [[ "${WITH_PYTHON}" -eq 1 ]]; then
  COMMON_CMAKE_ARGS+=(-DG2O_BUILD_PYTHON=On)
else
  COMMON_CMAKE_ARGS+=(-DG2O_BUILD_PYTHON=Off)
fi

# Configure (note: -S. -B"${BUILD_DIR}" matches pyproject.toml)
cmake -S . -B "${BUILD_DIR}" "${COMMON_CMAKE_ARGS[@]}" ${CMAKE_ARGS:-}

# Build everything needed; if WITH_PYTHON=1, we also have the pybind target ready
# Parallelism: respect CMAKE_BUILD_PARALLEL_LEVEL if set, else detect cores on Unix
if [[ -z "${CMAKE_BUILD_PARALLEL_LEVEL:-}" && "$(uname -s)" != "Darwin" ]]; then
  PAR="-j$(nproc)"
else
  PAR=""
fi

cmake --build "${BUILD_DIR}" ${PAR}
cmake --build "${BUILD_DIR}" --target install ${PAR}

echo "✅ CMake build complete. Build dir: ${BUILD_DIR} | Install prefix: ${INSTALL_PREFIX}"
if [[ "${WITH_PYTHON}" -eq 1 ]]; then
  echo "ℹ️  Python bindings were built and will be reused by the wheel build."
fi
