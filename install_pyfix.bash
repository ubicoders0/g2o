Fix wheel for PyPI
pip install auditwheel
auditwheel repair dist/ubicoders_g2opy-*-linux_x86_64.whl -w dist/
rm dist/ubicoders_g2opy-*-linux_x86_64.whl
# pip install --force-reinstall dist/ubicoders_g2opy-*manylinux_2_39_x86_64.whl