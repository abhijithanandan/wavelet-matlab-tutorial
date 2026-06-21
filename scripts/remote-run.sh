#!/usr/bin/env bash
# Sync the working tree to the server and run a command there.
# Dev docs (docs/), SDD scratch (.superpowers/) and the local .git stay out of
# the sync; everything else (code and the bundled tutorial/data) goes up so
# Octave can run it remotely. The project lives in its own server subfolder.
# Usage: scripts/remote-run.sh "<command to run in the remote repo dir>"
set -euo pipefail
HOST="${WSCAT_HOST:-asai-12-abhijith}"
REMOTE_DIR="${WSCAT_REMOTE_DIR:-projects/wavelet-octave-port}"
LOCAL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
rsync -az --delete --exclude '.git/' --exclude 'docs/' --exclude '.superpowers/' "$LOCAL_DIR/" "$HOST:$REMOTE_DIR/"
ssh "$HOST" "cd '$REMOTE_DIR' && $*"
