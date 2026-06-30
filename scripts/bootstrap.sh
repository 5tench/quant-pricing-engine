#!/usr/bin/env sh
set -eu

PYTHONPATH=src python -m unittest discover -s tests
