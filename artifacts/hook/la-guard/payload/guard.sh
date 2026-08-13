#!/bin/sh
# la-guard: PreToolUse guard for Claude Code.
#
# Reads the tool-call JSON on stdin and refuses a Bash command that pipes a
# downloaded script straight into a shell. Exit 0 allows the call; exit 2
# blocks it and shows stderr to the agent.

payload=$(cat)

printf '%s' "$payload" | python3 -c '
import json
import re
import sys

try:
    event = json.load(sys.stdin)
except ValueError:
    sys.exit(0)

if event.get("tool_name") != "Bash":
    sys.exit(0)

command = event.get("tool_input", {}).get("command", "")
if re.search(r"\b(curl|wget)\b[^|]*\|\s*(sudo\s+)?(ba|z|k)?sh\b", command):
    sys.stderr.write(
        "la-guard: refused a piped remote-install command. "
        "Download the script, review it, then run it explicitly.\n"
    )
    sys.exit(2)

sys.exit(0)
'
