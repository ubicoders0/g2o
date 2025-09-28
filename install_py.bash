#!/usr/bin/env bash
set -e  # exit on error

# First build
python -m build --wheel

# Run stub generation if "stubs/" is missing OR "gen-stub" is passed
if [[ ! -d "stubs" || "$1" == "gen-stub" ]]; then
    pip install dist/ubicoders_g2opy-2.1.2-cp313-cp313-linux_x86_64.whl
    echo "Generating stubs..."
    pybind11-stubgen g2opy -o stubs
    rsync -a stubs/g2opy/ python/g2opy/

    # Rebuild after stubs are copied
    python -m build --wheel
    pip install --force-reinstall dist/ubicoders_g2opy-*.whl
    pip install dist/ubicoders_g2opy-*.whl
fi

