conda create -n tmpy310 python=3.10 -y  && conda activate tmpy310
conda create -n tempy311 python=3.11 -y && conda activate tempy311
conda create -n tempy312 python=3.12 -y && conda activate tempy312
conda create -n tempy313 python=3.13 -y && conda activate tempy313




conda env remove -n tmpy310 -y
conda env remove -n tempy311 -y
conda env remove -n tempy312 -y
conda env remove -n tempy313 -y