#!/usr/bin/env bash
set -e  # exit on error

for pyver in 310 311 312 313; do
    echo "whl tempy${pyver}"
    conda run -n "tempy${pyver}" python -m build --wheel
done
