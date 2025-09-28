#!/usr/bin/env bash
set -e  # exit on error


sudo apt-get install -qq qtdeclarative5-dev qt5-qmake libqglviewer-dev-qt5 libsuitesparse-dev libeigen3-dev -y
pip install pybind11-stubgen build twine setuptools wheel
pip install "numpy>=2.0"

# Detect conda env
if [[ -n "${CONDA_PREFIX-}" ]]; then
  echo "Conda environment detected: $CONDA_PREFIX"
  conda install -y -c conda-forge "libstdcxx-ng>=12" "libgcc-ng>=12" libgomp
else
  echo "No conda environment detected (system Python/venv). Skipping conda install."
fi


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

