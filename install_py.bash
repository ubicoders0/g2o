#!/usr/bin/env bash
python -m build --wheel
pip install --force-reinstall dist/g2opy-*.whl
pip install dist/*.whl

pybind11-stubgen g2opy -o stubs
rsync -a stubs/g2opy/ python/g2opy/

python -m build --wheel
pip install --force-reinstall dist/g2opy-*.whl
pip install dist/*.whl