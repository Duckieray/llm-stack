# llm-stack

Local LLM stack using:
- Ollama
- Open WebUI
- Nix Flakes
- process-compose

## Prerequisites

- Nix with flakes enabled
- Docker running locally
- Optional GPU support:
  - NVIDIA: NVIDIA Container Toolkit
  - AMD (ROCm): host exposes `/dev/kfd` and `/dev/dri`

## Quick start

From this repository:

```bash
nix run
```

From GitHub (without cloning):

```bash
nix run https://github.com/duckieray/llm-stack#default
```

Equivalent flake shorthand:

```bash
nix run github:duckieray/llm-stack#default
```

This starts:
- Ollama on `http://localhost:11434`
- Open WebUI on `http://localhost:3000`

GPU mode is auto-detected by default:
- AMD/ROCm when `/dev/kfd` + `/dev/dri` exist (uses `ollama/ollama:rocm`)
- NVIDIA when NVIDIA devices, `nvidia-smi`, or Docker `nvidia` runtime are detected (uses `--gpus all`)
- CPU fallback otherwise

You can force a mode:

```bash
OLLAMA_ACCEL=amd nix run
OLLAMA_ACCEL=nvidia nix run
OLLAMA_ACCEL=cpu nix run
```

The stack also auto-pulls these models at startup (see `scripts/ensure-models.sh`):
- `llama3.1:8b`
- `qwen3-coder:30b`
- `hermes3`
- `JollyLlama/GLM-Z1-32B-0414-Q4_K_M`

Open WebUI is also auto-configured at startup to keep Ollama enabled
(see `scripts/ensure-openwebui-config.sh`), which prevents the
`No models found` issue after restarts.

## Useful commands

Run explicitly from the current directory:

```bash
nix run .#
```

Enter a dev shell with required tools:

```bash
nix develop
```

Stop the stack with `Ctrl+C` in the running terminal.
