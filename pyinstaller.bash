#!/usr/bin/env bash
python -m build --wheel
# python setup.py bdist_wheel --plat-name manylinux2014_x86_64
pip install --force-reinstall dist/g2opy-*.whl
pip install dist/*.whl

# pybind11-stubgen g2opy -o stubs
# rsync -a stubs/g2opy/ python/g2opy/

# python setup.py bdist_wheel --plat-name manylinux2014_x86_64
# pip install dist/*.whl