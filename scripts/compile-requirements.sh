#!/usr/bin/env bash
set -euo pipefail

pip install --upgrade pip pip-tools

pip-compile --resolver=backtracking --generate-hashes -o requirements/base.txt requirements/base.in
pip-compile --resolver=backtracking --generate-hashes -o requirements/dev.txt requirements/dev.in
pip-compile --resolver=backtracking --generate-hashes -o requirements/prod.txt requirements/prod.in
