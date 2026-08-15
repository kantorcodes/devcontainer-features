# HOL Guard

Installs [HOL Guard](https://hol.org/guard/security) into a Dev Container as a system-wide CLI while keeping user-specific policy and harness configuration under the Dev Container user's home directory.

## Quick start

```json
{
  "image": "mcr.microsoft.com/devcontainers/python:1-3.12-bookworm",
  "features": {
    "ghcr.io/kantorcodes/devcontainer-features/hol-guard:1": {}
  }
}
```

The default installation does not modify Codex, Claude Code, Cursor, Gemini CLI, OpenCode, or Pi configuration. It only installs and verifies the HOL Guard commands.

## Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `version` | string | `latest` | Install the latest stable release or an exact PEP 440 version such as `2.2.88`. |
| `initHarness` | string | `none` | Use `none` for a side-effect-free install. Other accepted values are `auto`, `codex`, `claude-code`, `cursor`, `gemini`, `opencode`, and `pi`; the Guard CLI still detects installed harnesses automatically. |
| `strictMode` | boolean | `false` | Configure strict security mode for the Dev Container user. |

## Pinned example

```json
{
  "features": {
    "ghcr.io/kantorcodes/devcontainer-features/hol-guard:1": {
      "version": "2.2.88",
      "initHarness": "none"
    }
  }
}
```

## Opt-in initialization

```json
{
  "features": {
    "ghcr.io/kantorcodes/devcontainer-features/hol-guard:1": {
      "initHarness": "cursor",
      "strictMode": true
    }
  }
}
```

Initialization runs as the Dev Container user rather than root, so generated configuration and local state remain accessible during normal development.

## Platform support

- Python 3.10 or newer
- Debian- or Ubuntu-based glibc images
- Root and non-root Dev Container users

Alpine/musl images are rejected with a clear error because the Python ONNX Runtime dependency used by the scanner does not publish musllinux wheels.

## Installed commands

- `hol-guard`
- `plugin-scanner`
- `plugin-guard`
- `plugin-ecosystem-scanner`

## Links

- [Security overview](https://hol.org/guard/security)
- [Source repository](https://github.com/hashgraph-online/hol-guard)
- [PyPI package](https://pypi.org/project/hol-guard/)
