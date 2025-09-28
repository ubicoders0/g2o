@echo off
REM Python build and packaging

python -m build --wheel
@REM for %%f in (dist\ubicoders-g2opy-*.whl) do pip install "%%f"