#!/usr/bin/env bash
set -e  # exit on error

# First build
python -m build --wheel

# Run stub generation if "stubs/" is missing OR "gen-stub" is passed
if [[ ! -d "stubs" || "$1" == "gen-stub" ]]; then
    pip install dist/*.whl
    echo "Generating stubs..."
    pybind11-stubgen g2opy -o stubs
    rsync -a stubs/g2opy/ python/g2opy/

    # Rebuild after stubs are copied
    python -m build --wheel
    pip install --force-reinstall dist/ubicoders_g2opy-*.whl
    pip install dist/*.whl
fi

# Fix wheel for PyPI
pip install auditwheel
auditwheel repair dist/ubicoders_g2opy-*-linux_x86_64.whl -w dist/
rm dist/ubicoders_g2opy-*-linux_x86_64.whl
pip install --force-reinstall dist/ubicoders_g2opy-*manylinux_2_39_x86_64.whl