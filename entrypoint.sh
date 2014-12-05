#!/bin/bash
set -e

Xvfb :1 -screen 0 1024x768x24 &
DISPLAY=:1 /opt/google/chrome/chrome --user-data-dir --no-sandbox &
DISPLAY=:1 xdotool search --sync --onlyvisible --class "chrome" windowsize 1024 768

exec "$@"
