#!/usr/bin/env bash
set -e  # exit on error

echo "========================================================"
echo "Starting g2opy build inside Docker container"
echo "Ubuntu Version: $(cat /etc/os-release | grep VERSION_ID | cut -d= -f2)"
echo "========================================================"

# Make sure Conda commands are available in this non-interactive shell script
source /opt/conda/etc/profile.d/conda.sh

# 0) Isolate the workspace to prevent host-mount race conditions across parallel containers
echo "Isolating source from host mount to prevent parallel build race conditions..."
mkdir -p /tmp/app
rsync -a --exclude='.git' --exclude='dist' --exclude='build' --exclude='dist_build' --exclude='dist_logs' /app/ /tmp/app/
cd /tmp/app

# Ensure dist_build directory exists to copy repaired wheels into
mkdir -p /app/dist_build
# Ensure dist exists inside the container so wheels can be built initially
mkdir -p dist

if [[ -z "$PY_VER" ]]; then
    echo "ERROR: PY_VER environment variable is not set."
    exit 1
fi

ENV_NAME="tempy${PY_VER//./}"  # e.g., tempy310
echo "========================================================"
    echo "Setting up Conda environment: $ENV_NAME (Python $PY_VER)"
    echo "========================================================"
    
    # Create or update environment
    conda create -n "$ENV_NAME" python="$PY_VER" -y
    
    # Activate environment
    conda activate "$ENV_NAME"

    # Accept Conda Terms of Service to avoid CondaToSNonInteractiveError
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

    # Install compilers into the isolated conda env so we get a modern gcc/g++ matching the python linkage
    conda install -y -c conda-forge "libstdcxx-ng>=12" "libgcc-ng>=12" "gcc_linux-64>=12" "gxx_linux-64>=12" libgomp

    # Install python dependencies required for building the wheel
    pip install pybind11-stubgen build twine setuptools wheel auditwheel patchelf "numpy>=2.0"

    # Clean previous cmake cache and staged files to rebuild the bindings for this specific Python version
    rm -rf build/linux
    rm -f python/g2opy/*.so python/g2opy/*.pyd python/g2opy/*.dylib python/g2opy/*.dll
    
    # Configure C++ build for this specific python version
    echo "Configuring C++ build for Python $PY_VER..."
    
    # Force the Conda-provided GCC to link against the older native Ubuntu system glibc 
    # instead of Conda's newer glibc. Also statically link the modern C++ runtime so auditwheel 
    # doesn't see the GLIBCXX_3.4.32 dependency and bump the manylinux tag to 2_39!
    export CFLAGS="-m64 -fPIC"
    export CXXFLAGS="-m64 -fPIC"
    export LDFLAGS="-m64 -static-libgcc -static-libstdc++"

    cmake -S . -B build/linux \
      -DBUILD_SHARED_LIBS=Off \
      -DG2O_BUILD_PYTHON=On \
      -DG2O_BUILD_APPS=Off \
      -DG2O_BUILD_EXAMPLES=Off \
      -DG2O_USE_OPENGL=Off \
      -DCMAKE_BUILD_TYPE=Release \
      -DPython_EXECUTABLE="$CONDA_PREFIX/bin/python" \
      -DPython3_EXECUTABLE="$CONDA_PREFIX/bin/python"

    echo "Building C++..."
    cmake --build build/linux --config Release -j $(nproc)

    echo "Staging artifacts..."
    PKG_DIR="python/g2opy"
    mkdir -p "$PKG_DIR"
    shopt -s nullglob
    cp build/linux/lib/*.{so,pyd,dylib,dll} "$PKG_DIR" 2>/dev/null || true
    cp build/linux/*.{so,pyd,dylib,dll}     "$PKG_DIR" 2>/dev/null || true
    echo "Installed C++ libs and staged Python extensions into $PKG_DIR"

    echo "Building wheel for Python $PY_VER..."
    
    # Run stubs generation for the *first* loop just to ensure stubs are created
    if [[ ! -d "stubs" ]]; then
       python -m build --wheel
       echo "Generating initial stubs..."
       pip install dist/ubicoders_g2opy-*.whl
       pybind11-stubgen g2opy -o stubs
       rsync -a stubs/g2opy/ python/g2opy/
    fi

    # Build the final wheel
    python -m build --wheel

    # Repair the newly built wheels for manylinux compliance
    echo "Running auditwheel repair on Linux wheels..."
    
    # We specifically target the wheel built mapping to the current python version
    WHEEL_TAG="cp${PY_VER//./}"
    for W in dist/ubicoders_g2opy-*-${WHEEL_TAG}-linux_*.whl; do
       if [[ -f "$W" ]]; then
           echo "Repairing $W..."
           auditwheel repair "$W" -w /app/dist_build/
       fi
    done

# Deactivate env
conda deactivate

echo "Finished Python $PY_VER."
echo "========================================================"
echo "All done! Built wheels are in /app/dist_build/"
echo "========================================================"
