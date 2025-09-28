@echo off
setlocal
cd /d "%~dp0"

set "PKG_DIR=python\g2opy"

for %%f in (build\win_tempy310\bin\Release\*.*) do (
    if "%%~xf"==".pyd" copy /Y "%%f" %PKG_DIR%
    if "%%~xf"==".dll" copy /Y "%%f" %PKG_DIR%
)

for %%f in (build\win_tempy311\bin\Release\*.*) do (
    if "%%~xf"==".pyd" copy /Y "%%f" %PKG_DIR%
)

for %%f in (build\win_tempy312\bin\Release\*.*) do (
    if "%%~xf"==".pyd" copy /Y "%%f" %PKG_DIR%
    
)
for %%f in (build\win_tempy313\bin\Release\*.*) do (
    if "%%~xf"==".pyd" copy /Y "%%f" %PKG_DIR%
)    

echo Staged artifacts to %PKG_DIR%
endlocal


