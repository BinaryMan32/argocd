#!/usr/bin/env python3
"""Review files held by tdarr's Require Review flow plugin.

Lists staged files waiting for review, opens the original and the transcoded
cache file in video-compare, then sends the chosen verdict back to tdarr.

The API key is read from TDARR_API_KEY, or from the desktop keyring:

    secret-tool store --label='Tdarr API key' service tdarr
"""

import curses
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request

TDARR_URL = os.environ.get("TDARR_URL", "https://tdarr.int.fivebytestudios.com")
API_KEY = None
# media mount in the tdarr pods = local mount of the same nfs share
PATH_MAP = os.environ.get("TDARR_PATH_MAP", "/data=/mnt/nfs/media")

# label, verdict sent to tdarr; same verdicts as the staging section buttons
VERDICTS = [
    ("Approve (reviewed)", "reviewed"),
    ("Requeue", "reset"),
    ("Skip", "skip"),
    ("Fail", "fail"),
]


def api_key():
    if key := os.environ.get("TDARR_API_KEY"):
        return key
    try:
        result = subprocess.run(
            ["secret-tool", "lookup", "service", "tdarr"],
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        sys.exit("secret-tool not found: install libsecret-tools or set TDARR_API_KEY")
    if not result.stdout.strip():
        sys.exit("no API key: run secret-tool store --label='Tdarr API key' service tdarr")
    return result.stdout.strip()


def api(path, data):
    request = urllib.request.Request(
        TDARR_URL + path,
        data=json.dumps({"data": data}).encode(),
        headers={"Content-Type": "application/json", "x-api-key": API_KEY},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        body = response.read()
    try:
        return json.loads(body)
    except ValueError:
        return body.decode()


def waiting_for_review():
    result = api(
        "/api/v2/client/staged",
        {"start": 0, "pageSize": 1000, "filters": [], "sorts": [], "opts": {}},
    )
    return [row for row in result.get("array", []) if row.get("status") == "requireReview"]


def send_verdict(row, verdict):
    # the ui posts the whole staged row as obj
    api("/api/v2/transcode-user-verdict", {"obj": row, "verdict": verdict})


def local_path(path):
    remote, local = PATH_MAP.split("=", 1)
    if path == remote or path.startswith(remote + "/"):
        return local + path[len(remote) :]
    return path


def files(row):
    original = row["originalLibraryFile"]
    transcoded = row["lastCompletedCacheFile"]
    return original.get("file", original["_id"]), transcoded.get("file", transcoded["_id"])


def describe(row):
    original, _ = files(row)
    # tdarr stores file_size in MiB
    before = row["originalLibraryFile"].get("file_size") or 0
    after = row["lastCompletedCacheFile"].get("file_size") or 0
    # new size as a percentage of the original, like the ratio column in tdarr
    ratio = f"{100 * after / before:.1f}%" if before else "?"
    return f"{before:8.0f} → {after:6.0f} MiB {ratio:>7}  {os.path.basename(original)}"


def menu(stdscr, title, lines, keys, status="", selected=0):
    """Show a scrolling list; return (key, index) on Enter, Esc or one of keys."""
    top = 0
    while True:
        stdscr.erase()
        height, width = stdscr.getmaxyx()
        visible = max(height - 3, 1)
        selected = min(max(selected, 0), max(len(lines) - 1, 0))
        top = min(max(top, selected - visible + 1), selected)
        stdscr.addnstr(0, 0, title, width - 1, curses.A_BOLD)
        if not lines:
            stdscr.addnstr(2, 0, "Nothing is waiting for review.", width - 1, curses.A_DIM)
        for y, line in enumerate(lines[top : top + visible], start=2):
            attr = curses.A_REVERSE if top + y - 2 == selected else curses.A_NORMAL
            stdscr.addnstr(y, 0, line, width - 1, attr)
        stdscr.addnstr(height - 1, 0, status, width - 1)

        key = stdscr.getch()
        if key in (curses.KEY_UP, ord("k")):
            selected -= 1
        elif key in (curses.KEY_DOWN, ord("j")):
            selected += 1
        elif key == curses.KEY_PPAGE:
            selected -= visible
        elif key == curses.KEY_NPAGE:
            selected += visible
        elif key in (curses.KEY_ENTER, 10, 13) and lines:
            return "enter", selected
        elif key == 27:
            return "esc", selected
        elif 0 <= key < 256 and chr(key) in keys:
            return chr(key), selected


def compare(stdscr, row):
    """Open the pair in video-compare; return an error message, if any."""
    paths = [local_path(path) for path in files(row)]
    for path in paths:
        if not os.path.exists(path):
            return f"Not found: {path}"
    # hand the terminal back while video-compare runs
    curses.def_prog_mode()
    curses.endwin()
    try:
        result = subprocess.run(["video-compare", *paths], check=False)
    finally:
        curses.reset_prog_mode()
        stdscr.refresh()
    if result.returncode != 0:
        return f"video-compare exited with {result.returncode}"
    return None


def choose_verdict(stdscr, row, status):
    name = os.path.basename(files(row)[0])
    labels = [label for label, _ in VERDICTS] + ["Back"]
    key, index = menu(stdscr, f"{name}: choose handling", labels, "q", status)
    if key != "enter" or index == len(VERDICTS):
        return None
    label, verdict = VERDICTS[index]
    try:
        send_verdict(row, verdict)
    except (urllib.error.URLError, OSError) as error:
        return f"{label} failed: {error}"
    return f"{label}: {name}"


def run(stdscr, rows):
    curses.curs_set(0)
    status = ""
    selected = 0
    while True:
        title = f"Tdarr review: {len(rows)} waiting   Enter compare   a act   r refresh   q quit"
        key, selected = menu(stdscr, title, [describe(row) for row in rows], "aqr", status, selected)
        status = ""
        if key in ("q", "esc"):
            return
        if key in ("enter", "a") and rows:
            row = rows[selected]
            error = compare(stdscr, row) if key == "enter" else None
            if error:
                status = error
                continue
            status = choose_verdict(stdscr, row, "Esc to go back") or ""
        try:
            rows = waiting_for_review()
        except (urllib.error.URLError, OSError) as error:
            status = f"Refresh failed: {error}"


def main():
    global API_KEY
    API_KEY = api_key()
    try:
        rows = waiting_for_review()
    except urllib.error.HTTPError as error:
        sys.exit(f"{TDARR_URL}: {error.code} {error.reason}")
    except (urllib.error.URLError, OSError) as error:
        sys.exit(f"{TDARR_URL}: {error}")
    os.environ.setdefault("ESCDELAY", "25")
    curses.wrapper(run, rows)


if __name__ == "__main__":
    main()
