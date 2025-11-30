#!/usr/bin/env bash
set -euo pipefail

MODELS=(
  "llama3.1:8b"
  "qwen3-coder:30b"
  "hermes3"
  "JollyLlama/GLM-Z1-32B-0414-Q4_K_M"
)

for m in "${MODELS[@]}"; do
  docker exec ollama ollama pull "$m" || true
done
