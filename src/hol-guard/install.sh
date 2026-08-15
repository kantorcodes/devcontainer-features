#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-latest}"
INIT_HARNESS="${INITHARNESS:-none}"
STRICT_MODE="${STRICTMODE:-false}"
INSTALL_DIR="/usr/local/share/hol-guard"

log() {
    printf '[hol-guard-feature] %s\n' "$*"
}

fail() {
    printf '[hol-guard-feature] ERROR: %s\n' "$*" >&2
    exit 1
}

command -v python3 >/dev/null 2>&1 || fail \
    'Python 3.10+ is required. Add ghcr.io/devcontainers/features/python before HOL Guard.'

python3 - <<'PY' || fail 'HOL Guard requires Python 3.10 or newer.'
import sys
raise SystemExit(0 if sys.version_info >= (3, 10) else 1)
PY

# The scanner uses Magika, whose Python package depends on ONNX Runtime.
# ONNX Runtime does not publish musllinux wheels, so fail early with a useful
# image recommendation rather than leaving a long pip resolution error.
if command -v ldd >/dev/null 2>&1 && ldd --version 2>&1 | grep -qi musl; then
    fail 'Alpine/musl images are not supported. Use a Debian or Ubuntu based Dev Container image.'
fi

if [ "$VERSION" != "latest" ] && ! printf '%s' "$VERSION" | grep -qE \
    '^[0-9]+(\.[0-9]+)*((a|b|rc|c|\.post|\.dev)[0-9]*)*$'; then
    fail "Invalid version '$VERSION'. Use 'latest' or a PEP 440 version such as '2.2.88'."
fi

USERNAME="${_REMOTE_USER:-${_CONTAINER_USER:-auto}}"
if [ "$USERNAME" = "auto" ] || [ "$USERNAME" = "root" ]; then
    for candidate in vscode node codespace; do
        if id "$candidate" >/dev/null 2>&1; then
            USERNAME="$candidate"
            break
        fi
    done
fi
if [ "$USERNAME" = "auto" ]; then
    USERNAME="root"
fi

if [ "$USERNAME" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="$(getent passwd "$USERNAME" 2>/dev/null | cut -d: -f6 || true)"
    [ -n "$USER_HOME" ] || USER_HOME="/home/$USERNAME"
fi

run_as_target_user() {
    if [ "$USERNAME" = "root" ]; then
        env HOME="$USER_HOME" PATH="/usr/local/bin:$PATH" "$@"
    elif command -v runuser >/dev/null 2>&1; then
        runuser -u "$USERNAME" -- env HOME="$USER_HOME" PATH="/usr/local/bin:$PATH" "$@"
    else
        local command_line
        printf -v command_line '%q ' "$@"
        su -s /bin/bash "$USERNAME" -c \
            "export HOME=$(printf '%q' "$USER_HOME"); export PATH=/usr/local/bin:\$PATH; exec $command_line"
    fi
}

log "Installing for $USERNAME with Python $(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"

if [ ! -x "$INSTALL_DIR/bin/python" ]; then
    rm -rf "$INSTALL_DIR"
    if ! python3 -m venv "$INSTALL_DIR"; then
        if command -v apt-get >/dev/null 2>&1; then
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            apt-get install -y --no-install-recommends python3-venv
            rm -rf /var/lib/apt/lists/*
            python3 -m venv "$INSTALL_DIR"
        else
            fail 'python3 -m venv is unavailable. Install the Python venv module in the base image.'
        fi
    fi
fi

"$INSTALL_DIR/bin/python" -m pip install \
    --disable-pip-version-check \
    --no-cache-dir \
    --upgrade pip setuptools wheel

if [ "$VERSION" = "latest" ]; then
    log 'Installing the latest stable HOL Guard release.'
    "$INSTALL_DIR/bin/python" -m pip install \
        --disable-pip-version-check \
        --no-cache-dir \
        --upgrade hol-guard
else
    log "Installing HOL Guard $VERSION."
    "$INSTALL_DIR/bin/python" -m pip install \
        --disable-pip-version-check \
        --no-cache-dir \
        --upgrade "hol-guard==$VERSION"
fi

primary_command="$INSTALL_DIR/bin/hol-guard"
[ -x "$primary_command" ] || fail 'The installed HOL Guard package did not expose the hol-guard command.'
ln -sfn "$primary_command" /usr/local/bin/hol-guard

# Older and transitional releases have not always emitted every compatibility
# console script into their wheel, even though those names dispatch to the same
# CLI. Preserve the documented command surface by using a packaged executable
# when present and otherwise aliasing the verified primary command.
for command_name in plugin-scanner plugin-guard plugin-ecosystem-scanner; do
    packaged_command="$INSTALL_DIR/bin/$command_name"
    if [ -x "$packaged_command" ]; then
        target="$packaged_command"
    else
        target="$primary_command"
        log "Normalizing compatibility command '$command_name' to hol-guard."
    fi
    ln -sfn "$target" "/usr/local/bin/$command_name"
done

# Installation is deliberately side-effect free by default. Only modify the
# developer's harness configuration when the feature consumer opts in.
if [ "$INIT_HARNESS" != "none" ]; then
    log "Initializing HOL Guard for the target user (requested harness: $INIT_HARNESS)."
    run_as_target_user hol-guard init --yes
fi

if [ "$STRICT_MODE" = "true" ]; then
    log 'Enabling strict security mode for the target user.'
    run_as_target_user hol-guard settings set security-level strict
fi

hol-guard --help >/dev/null
plugin-scanner --help >/dev/null
plugin-guard --help >/dev/null
plugin-ecosystem-scanner --help >/dev/null
"$INSTALL_DIR/bin/python" -c 'import codex_plugin_scanner, magika, onnxruntime'

log 'HOL Guard installed successfully.'
log 'Documentation: https://hol.org/guard/security'
