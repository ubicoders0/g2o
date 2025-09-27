@echo off
REM Environment setup for Windows

REM Install Python packages
pip install pybind11-stubgen build twine setuptools wheel
pip install "numpy>=2.0" 
pip install eigen
conda install -c conda-forge qt5-main pyqt

