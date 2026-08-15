#!/bin/bash
set -e

source dev-container-features-test-lib

check "HOL Guard command is available" hol-guard --help
check "Plugin scanner command is available" plugin-scanner --help
check "Plugin guard command is available" plugin-guard --help
check "Ecosystem scanner command is available" plugin-ecosystem-scanner --help
check "System installation exists" test -x /usr/local/share/hol-guard/bin/python
check "Scanner runtime imports" /usr/local/share/hol-guard/bin/python -c \
    "import codex_plugin_scanner, magika, onnxruntime"
check "Primary command symlink exists" test -L /usr/local/bin/hol-guard
check "Primary command targets the feature installation" bash -c \
    'test "$(readlink /usr/local/bin/hol-guard)" = /usr/local/share/hol-guard/bin/hol-guard'

reportResults
