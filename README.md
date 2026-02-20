# llm-stack

Local LLM stack using:
- Ollama
- Open WebUI
- Nix Flakes
- process-compose

## Prerequisites

- Nix with flakes enabled
- Docker running locally
- (Optional) NVIDIA GPU + NVIDIA Container Toolkit for `--gpus all`

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

The stack also auto-pulls these models at startup (see `scripts/ensure-models.sh`):
- `llama3.1:8b`
- `qwen3-coder:30b`
- `hermes3`
- `JollyLlama/GLM-Z1-32B-0414-Q4_K_M`

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
