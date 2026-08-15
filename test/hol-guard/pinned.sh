#!/bin/bash
set -e

source dev-container-features-test-lib

check "Pinned HOL Guard command" hol-guard --help
check "Pinned release installed" /usr/local/share/hol-guard/bin/python -c \
    "from importlib.metadata import version; assert version('hol-guard') == '2.2.88'"
check "Pinned scanner runtime imports" /usr/local/share/hol-guard/bin/python -c \
    "import codex_plugin_scanner, magika, onnxruntime"

reportResults
