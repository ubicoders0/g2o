#!/usr/bin/env bash

sudo apt-get update -qq
# dependencies for building g2o
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
