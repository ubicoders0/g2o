# Maintainer Manual

## How to Build and Publish (Maintainers only)

1. **Update Version**: Change `version` to your new value in `pyproject.toml`.
2. **Build Linux Wheels via Docker**:
   ```bash
   docker compose up
   ```
   *This concurrently spins up 12 independent containers (Ubuntu 20, 22, 24 matrixed with Python 3.10-3.13) to compile all manylinux wheels simultaneously, drastically decreasing build time. It outputs them into the `dist_build/` folder.*
3. **Prepare the Release Wheels**:
   Assuming you previously built the Windows `.whl` files on a native Windows machine and placed them in `dist/`, and the newly built Linux wheels are in `dist_build/`, run the release script:
   ```bash
   ./prepare_release.bash
   ```
   *This script automatically extracts the target version from `pyproject.toml`. It then processes all wheels in `dist/` and `dist_build/` by safely unpacking them, updating their internal `METADATA` directly to the new version, and officially repacking them into valid wheels. All finalized, deployable wheels will be placed in the `release/` directory.*
4. **Test the Built Environment**:
   Before publishing, you can verify your `.whl` files install and run correctly in a fresh conda environment:
   ```bash
   conda create -n test_env python=3.10 -y
   conda activate test_env
   
   # Auto-detect your active Python version (e.g., "310") and install its corresponding Linux wheel
   PY_VER=$(python -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')
   pip install release/ubicoders_g2opy-*cp${PY_VER}-cp${PY_VER}*manylinux*.whl
   ```
5. **Publish to PyPI**:
   ```bash
   twine upload release/*
   ```

## Release Testing

The `release_tester` folder contains a Docker setup used to test the installation of the published `ubicoders-g2opy` package across multiple Ubuntu versions (20.04, 22.04, 24.04). It acts as a final verification step after uploading to PyPI using twine.

To run the installation tests:
1. Ensure the new version is uploaded to PyPI (Twine).
2. Navigate to the `release_tester` directory.
3. Run `docker compose up test-u20 test-u22 test-u24`
This will configure Ubuntu containers, install `ubicoders-g2opy` via `pip`, and execute `tester.py` to confirm the installation is functional.
