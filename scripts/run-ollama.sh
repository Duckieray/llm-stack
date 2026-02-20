#!/usr/bin/env bash
set -euo pipefail

ACCEL_MODE="${OLLAMA_ACCEL:-auto}"
GPU_ARGS=()
OLLAMA_IMAGE="ollama/ollama:latest"

has_amd_devices() {
  [[ -e /dev/kfd && -d /dev/dri ]]
}

has_nvidia_devices() {
  # Classic Linux NVIDIA device nodes.
  if [[ -e /dev/nvidiactl || -d /proc/driver/nvidia ]]; then
    return 0
  fi

  # WSL often exposes NVIDIA through nvidia-smi + /dev/dxg only.
  if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
    return 0
  fi

  # If Docker has an NVIDIA runtime configured, prefer GPU mode in auto.
  if docker info --format '{{json .Runtimes}}' 2>/dev/null | grep -q '"nvidia"'; then
    return 0
  fi

  return 1
}

select_mode() {
  case "$ACCEL_MODE" in
    auto)
      if has_amd_devices; then
        echo "amd"
      elif has_nvidia_devices; then
        echo "nvidia"
      else
        echo "cpu"
      fi
      ;;
    amd|rocm)
      echo "amd"
      ;;
    nvidia|cpu)
      echo "$ACCEL_MODE"
      ;;
    *)
      echo "Invalid OLLAMA_ACCEL value '$ACCEL_MODE'. Use: auto|amd|rocm|nvidia|cpu" >&2
      exit 1
      ;;
  esac
}

MODE="$(select_mode)"

case "$MODE" in
  amd)
    OLLAMA_IMAGE="ollama/ollama:rocm"
    GPU_ARGS+=(--device /dev/kfd --device /dev/dri --group-add video)
    ;;
  nvidia)
    GPU_ARGS+=(--gpus all)
    ;;
  cpu)
    ;;
esac

echo "Starting Ollama with mode='$MODE' image='$OLLAMA_IMAGE'"
docker rm -f ollama >/dev/null 2>&1 || true
docker run --rm \
  --name ollama \
  --network ollama-net \
  "${GPU_ARGS[@]}" \
  -p 11434:11434 \
  -v ollama_data:/root/.ollama \
  "$OLLAMA_IMAGE"
