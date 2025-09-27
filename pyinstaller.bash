#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update -qq
# dependencies for building g2o
sudo apt-get install -qq qtdeclarative5-dev qt5-qmake libqglviewer-dev-qt5 libsuitesparse-dev libeigen3-dev -y
pip install pybind11-stubgen


# Detect conda env
if [[ -n "${CONDA_PREFIX-}" ]]; then
  echo "Conda environment detected: $CONDA_PREFIX"
  conda install -y -c conda-forge "libstdcxx-ng>=12" "libgcc-ng>=12" libgomp
else
  echo "No conda environment detected (system Python/venv). Skipping conda install."
fi

# Then continue with pip installs
pip install "numpy>=2.0"
pip install -U build
python -m build --wheel
pip install .


pybind11-stubgen g2opy -o stubs
rsync -a stubs/g2opy/ python/g2opy/

pip install -U build
python -m build --wheel
pip install .