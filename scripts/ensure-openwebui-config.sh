#!/usr/bin/env bash
set -euo pipefail

MAX_RETRIES="${OPENWEBUI_CONFIG_RETRIES:-60}"
SLEEP_SECS="${OPENWEBUI_CONFIG_SLEEP_SECS:-2}"
TARGET_OLLAMA_URL="${OPENWEBUI_OLLAMA_URL:-http://ollama:11434}"

wait_for_openwebui_container() {
  local i
  for i in $(seq 1 "$MAX_RETRIES"); do
    if docker ps --format '{{.Names}}' | grep -qx 'open-webui'; then
      return 0
    fi
    sleep "$SLEEP_SECS"
  done
  return 1
}

configure_openwebui() {
  docker exec -i open-webui python3 - <<PY
import json
import sqlite3
import sys

db = "/app/backend/data/webui.db"
target_url = "$TARGET_OLLAMA_URL"

con = sqlite3.connect(db)
cur = con.cursor()
row = cur.execute("SELECT id, data FROM config ORDER BY id DESC LIMIT 1").fetchone()
if row is None:
    sys.exit(2)

config_id, raw = row
data = json.loads(raw)
ollama = data.setdefault("ollama", {})
changed = False

if ollama.get("enable") is not True:
    ollama["enable"] = True
    changed = True

if ollama.get("base_urls") != [target_url]:
    ollama["base_urls"] = [target_url]
    changed = True

api_configs = ollama.get("api_configs")
if not isinstance(api_configs, dict) or not api_configs:
    ollama["api_configs"] = {"0": {}}
    changed = True

if changed:
    cur.execute(
        "UPDATE config SET data = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        (json.dumps(data), config_id),
    )
    con.commit()
    print("Open WebUI config updated: Ollama enabled")
else:
    print("Open WebUI config already correct")
PY
}

echo "Ensuring Open WebUI is configured to use Ollama..."
wait_for_openwebui_container

for i in $(seq 1 "$MAX_RETRIES"); do
  if configure_openwebui; then
    exit 0
  fi
  sleep "$SLEEP_SECS"
done

echo "Failed to configure Open WebUI after ${MAX_RETRIES} attempts" >&2
exit 1
