@echo off
REM Python build and packaging with loop

for %%v in (310 311 312 313) do (
    echo "building tempy%%v"
    conda run -n tempy%%v python -m build --wheel
)

REM Optionally install the generated wheels
for %%f in (dist\ubicoders-g2opy-*.whl) do pip install "%%f"
