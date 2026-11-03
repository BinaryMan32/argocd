#!/bin/bash
# Runs instead of the image's scan and liberate loop, after liberate.sh has set up the config and database.
# Downloads from CDNs sometimes stall without the connection closing, and libation has no timeout for that,
# so restart a command when its process stops reading and writing files.
set -uo pipefail

# a working download writes the book as it arrives, while a stalled one only does the runtime's
# occasional few bytes of housekeeping io, so progress means at least MIN_PROGRESS_BYTES since the last
MIN_PROGRESS_BYTES=${MIN_PROGRESS_BYTES:-1048576}
STALL_SECONDS=${STALL_SECONDS:-300}
CHECK_SECONDS=${CHECK_SECONDS:-30}
MAX_ATTEMPTS=${MAX_ATTEMPTS:-5}
LIBATION_CLI=${LIBATION_CLI:-/libation/LibationCli}
# libation has no progress output when stdout isn't a terminal, so log it from the download state files
# liberate.sh sets InProgress to /tmp, downloads keep WritePosition and ContentLength in <asin>.json
DOWNLOADS_DIR=${DOWNLOADS_DIR:-/tmp/DownloadsInProgress}
PROGRESS_SECONDS=${PROGRESS_SECONDS:-60}

log() {
  printf "%s %s: %s\n" "$(date '+%F %T')" "$1" "$2"
}

# total bytes read and written through files, sockets aren't counted
io_bytes() {
  awk '/^(rchar|wchar):/ { total += $2 } END { print total }' "/proc/$1/io" 2>/dev/null
}

# log downloads updated within STALL_SECONDS, skipping state left behind by earlier failures
log_progress() {
  local file line
  while IFS= read -r file; do
    line=$(jq -r --arg asin "$(basename "$file" .json)" \
      'select(.ContentLength > 0) | "\($asin) \(.WritePosition / 1048576 | floor)/\(.ContentLength / 1048576 | floor) MiB (\(.WritePosition * 100 / .ContentLength | floor)%)"' \
      "$file" 2>/dev/null)
    [[ -n "$line" ]] && log "info" "$line"
  done < <(find "$DOWNLOADS_DIR" -maxdepth 1 -name '*.json' -newermt "-${STALL_SECONDS} seconds" 2>/dev/null)
}

# run a command, restarting it after STALL_SECONDS without progress, up to MAX_ATTEMPTS times
run_watched() {
  local attempt pid progress current idle elapsed status
  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    "$@" &
    pid=$!
    progress=0
    idle=0
    elapsed=0
    # poll every second so a quick command isn't delayed until the next check
    while kill -0 "$pid" 2>/dev/null; do
      sleep 1
      elapsed=$((elapsed + 1))
      (( elapsed % PROGRESS_SECONDS == 0 )) && log_progress
      (( elapsed % CHECK_SECONDS == 0 )) || continue
      current=$(io_bytes "$pid")
      [[ -n "$current" ]] || continue
      if (( current - progress >= MIN_PROGRESS_BYTES )); then
        idle=0
        progress=$current
      else
        idle=$((idle + CHECK_SECONDS))
      fi
      if (( idle >= STALL_SECONDS )); then
        log "WARNING" "'$*' made no progress for ${idle}s, restarting (attempt ${attempt}/${MAX_ATTEMPTS})"
        kill -TERM "$pid"
        for _ in $(seq 1 30); do
          kill -0 "$pid" 2>/dev/null || break
          sleep 1
        done
        kill -KILL "$pid" 2>/dev/null
        break
      fi
    done
    wait "$pid"
    status=$?
    if (( idle < STALL_SECONDS )); then
      return "$status"
    fi
  done
  log "ERROR" "'$*' stalled ${MAX_ATTEMPTS} times, giving up"
  return 1
}

log "info" "scanning accounts"
# not watched: scan waits on api requests, which time out, and writes little to files while it waits
if ! "$LIBATION_CLI" scan; then
  log "ERROR" "scan failed, skipping liberate"
  exit 1
fi

log "info" "liberating books"
run_watched "$LIBATION_CLI" liberate
