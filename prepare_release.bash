#!/bin/bash
set -e

# Extract target release version from pyproject.toml
if [ ! -f "pyproject.toml" ]; then
    echo "Error: pyproject.toml not found in the current directory."
    exit 1
fi

TARGET_VERSION=$(sed -n 's/^version = "\([^"]*\)"/\1/p' pyproject.toml | tr -d '\r')

if [ -z "$TARGET_VERSION" ]; then
    echo "Error: Could not extract target version from pyproject.toml"
    exit 1
fi

echo "Target release version: $TARGET_VERSION"

RELEASE_DIR="release"
DIST_DIR="dist"
DIST_BUILD_DIR="dist_build"

echo "Creating clean release directory..."
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Check if wheel package is installed
if ! python3 -m pip show wheel > /dev/null 2>&1; then
    echo "The 'wheel' package is required. Installing..."
    python3 -m pip install wheel
fi

# =========================================================================
# 1. Process Windows wheels from $DIST_DIR
# =========================================================================
echo "Processing Windows wheels from $DIST_DIR..."
# Find all matching windows wheels
WIN_WHEELS=($(find "$DIST_DIR" -maxdepth 1 -name "*win_amd64.whl" 2>/dev/null || true))

if [ ${#WIN_WHEELS[@]} -eq 0 ]; then
    echo "  -> No Windows wheels found in $DIST_DIR"
else
    for whl in "${WIN_WHEELS[@]}"; do
        python3 rename_wheel.py "$whl" "$TARGET_VERSION" "$RELEASE_DIR"
    done
fi

# =========================================================================
# 2. Process Linux wheels from $DIST_BUILD_DIR
# =========================================================================

echo "Processing Linux wheels from $DIST_BUILD_DIR..."
# The docker pipeline outputs to dist_build
LINUX_WHEELS=($(find "$DIST_BUILD_DIR" -maxdepth 1 -name "*.whl" 2>/dev/null || true))

if [ ${#LINUX_WHEELS[@]} -gt 0 ]; then
    for whl in "${LINUX_WHEELS[@]}"; do
        python3 rename_wheel.py "$whl" "$TARGET_VERSION" "$RELEASE_DIR"
    done
    echo "  -> Processed ${#LINUX_WHEELS[@]} Linux wheels to $RELEASE_DIR/."
else
    echo "  -> Warning: No Linux wheels found in $DIST_BUILD_DIR."
    echo "     Make sure you ran the docker build step first to generate the new Linux wheels."
fi

echo ""
echo "Release preparation complete!"
echo "Your final deployable wheels are located in the '$RELEASE_DIR/' folder."
echo "You can publish them securely using: twine upload $RELEASE_DIR/*"
