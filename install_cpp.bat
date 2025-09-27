@echo off
set VCPKG_ROOT=E:\local_projects\vcpkg
set TRIPLET=%VCPKG_DEFAULT_TRIPLET%
if "%TRIPLET%"=="" set TRIPLET=x64-windows

set BUILD_DIR=build\cpp
set TOOLCHAIN=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake

rem Optional but recommended for VS generators: match arch to triplet
set GEN_ARCH=-A x64

cmake -S . -B %BUILD_DIR% ^
  %GEN_ARCH% ^
  -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN% ^
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
  -DG2O_BUILD_EXAMPLES=Off

cmake --build %BUILD_DIR% --config Release -j %NUMBER_OF_PROCESSORS%


echo Native build done. Next: stage artifacts to python package dir.

set PKG_DIR=python\g2opy
if not exist %PKG_DIR% mkdir %PKG_DIR%

for %%f in (%BUILD_DIR%\bin\Release\*.*) do (
    if "%%~xf"==".pyd" copy /Y "%%f" %PKG_DIR%
    if "%%~xf"==".dll" copy /Y "%%f" %PKG_DIR%
)

echo Installed C++ libs and staged Python extensions into %PKG_DIR%
