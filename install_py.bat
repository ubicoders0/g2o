@echo off
REM Python build and packaging

python -m build --wheel
for %%f in (dist\pyg2o-*.whl) do pip install "%%f"