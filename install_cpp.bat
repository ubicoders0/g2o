@REM @echo off
@REM set VCPKG_ROOT=E:\local_projects\vcpkg
@REM set TRIPLET=%VCPKG_DEFAULT_TRIPLET%
@REM if "%TRIPLET%"=="" set TRIPLET=x64-windows

@REM set BUILD_DIR=build\cpp
@REM set TOOLCHAIN=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake

@REM rem Optional but recommended for VS generators: match arch to triplet
@REM set GEN_ARCH=-A x64

@REM cmake -S . -B %BUILD_DIR% ^
@REM   %GEN_ARCH% ^
@REM   -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN% ^
@REM   -DVCPKG_TARGET_TRIPLET=%TRIPLET% ^
@REM   -DCMAKE_BUILD_TYPE=Release ^
@REM   -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON ^
@REM   -DBLA_VENDOR=OpenBLAS ^
@REM   -DSUITESPARSE_INCLUDE_DIR="%VCPKG_ROOT%\installed\%TRIPLET%\include\suitesparse" ^
@REM   -DSUITESPARSE_LIBRARY_DIR="%VCPKG_ROOT%\installed\%TRIPLET%\lib" ^
@REM   -DLAPACK_LIBRARIES="%VCPKG_ROOT%\installed\%TRIPLET%\lib\openblas.lib" ^
@REM   -DBUILD_SHARED_LIBS=Off ^
@REM   -DG2O_BUILD_PYTHON=On ^
@REM   -DG2O_BUILD_APPS=Off ^
@REM   -DG2O_USE_OPENGL=Off ^
@REM   -DG2O_BUILD_EXAMPLES=Off

@REM cmake --build %BUILD_DIR% --config Release -j %NUMBER_OF_PROCESSORS%


@REM echo Native build done. Next: stage artifacts to python package dir.

set PKG_DIR=python\g2opy
if not exist %PKG_DIR% mkdir %PKG_DIR%

for %%f in (%BUILD_DIR%\bin\Release\*.*) do (
    if "%%~xf"==".pyd" copy /Y "%%f" %PKG_DIR%
    if "%%~xf"==".dll" copy /Y "%%f" %PKG_DIR%
)

echo Installed C++ libs and staged Python extensions into %PKG_DIR%
