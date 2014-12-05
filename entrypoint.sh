#!/bin/bash
set -e

Xvfb :1 -screen 0 1024x768x24 &
DISPLAY=:1 /opt/google/chrome/chrome --user-data-dir --no-sandbox --window-position=0,0 --window-size=1024,768 &

exec "$@"
