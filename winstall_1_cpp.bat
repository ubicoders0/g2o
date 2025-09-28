@echo off
setlocal EnableExtensions



if "%~1"=="" (
  echo Usage: %~nx0 ^<conda_env_name^>
  echo Example: %~nx0 g2otempy311
  exit /b 2
)
set "ENV_NAME=%~1"


pip install pybind11-stubgen build twine setuptools wheel
pip install "numpy>=2.0" 
pip install eigen



set "VCPKG_ROOT=E:\local_projects\vcpkg"
set "TRIPLET=%VCPKG_DEFAULT_TRIPLET%"
if "%TRIPLET%"=="" set "TRIPLET=x64-windows"

set "ENV_ROOT=C:\Users\hylee\anaconda3\envs"
set "ENV_DIR=%ENV_ROOT%\%ENV_NAME%"
set "PYEXE=%ENV_DIR%\python.exe"

rem clean cache to avoid sticky Python
del "%BUILD_DIR%\CMakeCache.txt" 2>nul
rmdir /s /q "%BUILD_DIR%\CMakeFiles" 2>nul



set "BUILD_DIR=build\win_%ENV_NAME%"
set "TOOLCHAIN=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"
set "GEN_ARCH=-A x64"

echo [INFO] Configuring with Python from "%ENV_DIR%"
cmake -S . -B "%BUILD_DIR%" ^
  %GEN_ARCH% ^
  -DCMAKE_TOOLCHAIN_FILE="%TOOLCHAIN%" ^
  -DVCPKG_TARGET_TRIPLET=%TRIPLET% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON ^
  -DBLA_VENDOR=OpenBLAS ^
  -DSUITESPARSE_INCLUDE_DIR="%VCPKG_ROOT%\installed\%TRIPLET%\include\suitesparse" ^
  -DSUITESPARSE_LIBRARY_DIR="%VCPKG_ROOT%\installed\%TRIPLET%\lib" ^
  -DLAPACK_LIBRARIES="%VCPKG_ROOT%\installed\%TRIPLET%\lib\openblas.lib" ^
  -DBUILD_SHARED_LIBS=Off ^
  -DG2O_BUILD_PYTHON=On ^
  -DG2O_BUILD_APPS=Off ^
  -DG2O_USE_OPENGL=Off ^
  -DG2O_BUILD_EXAMPLES=Off ^
  -DPython3_FIND_STRATEGY=LOCATION ^
  -DPython3_FIND_IMPLEMENTATIONS=CPython ^
  -DPython3_ROOT_DIR="%ENV_DIR%" ^

if errorlevel 1 exit /b 1

cmake --build "%BUILD_DIR%" --config Release -j %NUMBER_OF_PROCESSORS%

echo [INFO] native build completed for %ENV_NAME%


