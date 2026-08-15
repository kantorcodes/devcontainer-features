# HOL Guard Dev Container Feature

Install [HOL Guard](https://hol.org/guard/security) in VS Code Dev Containers, GitHub Codespaces, and other environments that implement the [Development Container specification](https://containers.dev/).

HOL Guard is a local-first security layer for AI coding agents. It evaluates supported tool actions before files change or network requests leave the workspace, and it can scan skills, MCP servers, plugins, and agent packages for supply-chain threats.

## Use the feature

```json
{
  "image": "mcr.microsoft.com/devcontainers/python:1-3.12-bookworm",
  "features": {
    "ghcr.io/kantorcodes/devcontainer-features/hol-guard:1": {}
  }
}
```

The default installation is side-effect free: it installs the CLI but does not modify an agent harness configuration. Set `initHarness` explicitly when you want initialization during the container build.

## Supported images

Use a glibc-based Debian or Ubuntu image with Python 3.10 or newer. Alpine/musl images are not supported because the scanner's ONNX Runtime dependency does not publish musllinux wheels.

## Options

| Option | Default | Purpose |
| --- | --- | --- |
| `version` | `latest` | Install the latest stable HOL Guard release or an exact PEP 440 version such as `2.2.88`. |
| `initHarness` | `none` | Keep installation side-effect free, or request initialization for an installed agent harness. |
| `strictMode` | `false` | Configure strict security mode for the Dev Container user. |

Full option documentation is in [`src/hol-guard/README.md`](src/hol-guard/README.md).

## Verification

Every change is validated with the official Dev Container CLI against current Microsoft Python Dev Container images before publication to GitHub Container Registry.

## Project links

- [HOL Guard security overview](https://hol.org/guard/security)
- [HOL Guard source](https://github.com/hashgraph-online/hol-guard)
- [HOL Guard on PyPI](https://pypi.org/project/hol-guard/)

This distribution repository is maintained by Michael Kantor for Hashgraph Online. HOL Guard itself is licensed under Apache-2.0.
