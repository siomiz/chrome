#!/bin/bash
set -e

PUID=${PUID:-911}
PGID=${PGID:-911}
export OUTPUT=${OUTPUT:-"/output"}
export OUT_LUSCIOUS=${OUT_LUSCIOUS:-"/output/luscious"}
export OUT_LITEROTICA=${OUT_LITEROTICA:-"/output/literotica"}
export JD_USER=$JD_USER:-""}
export JD_PASS=${JD_PASS:-""}
export JD_DEVICE=${JD_DEVICE:-""}
export ENABLE_JD=${ENABLE_JD:-"true"}
export ENABLE_LOG=${ENABLE_LOG:-"true"}
ENABLE_VNC=${ENABLE_VNC:-"false"}

# set uid and gid
groupmod -o -g "$PGID" chrome
usermod -o -u "$PUID" chrome

# redo permissions
chown -R chrome:chrome /output
chown -R chrome:chrome /home/chrome
chown chrome /var/spool/cron/crontabs/chrome

# start cron
service cron start

# if VNC is enabled, copy correct supervisord.conf
if [ "$ENABLE_VNC" = "true" ] ; then
  echo 'VNC is enabled'
else
  echo 'VNC is disabled'
  cp /etc/supervisor/conf.d/supervisord-novnc.conf /etc/supervisor/conf.d/supervisord.conf
fi

# echo if JD and LOG are enabled
if [ "$ENABLE_JD" = "true" ] ; then
  echo 'MyJDownloader is enabled'
else
  echo 'MyJDownloader is disabled'
fi

if [ "$ENABLE_LOG" = "true" ] ; then
  echo 'Logging is enabled'
else
  echo 'Logging is disabled'
fi

# VNC default no password
export X11VNC_AUTH="-nopw"
echo "X11VNC_AUTH set"

# look for VNC password file in order (first match is used)
passwd_files=(
  /home/chrome/.vnc/passwd
  /run/secrets/vncpasswd
  )
echo "passwd_files set"

for passwd_file in ${passwd_files[@]}; do
  if [[ -f ${passwd_file} ]]; then
    export X11VNC_AUTH="-rfbauth ${passwd_file}"
    break
  fi
done
echo "passwd loop done"

# override above if VNC_PASSWORD env var is set (insecure!)
if [[ "$VNC_PASSWORD" != "" ]]; then
  export X11VNC_AUTH="-passwd $VNC_PASSWORD"
fi
echo "exported new password"

# set sizes for both VNC screen & Chrome window
: ${VNC_SCREEN_SIZE:='1024x768'}
IFS='x' read SCREEN_WIDTH SCREEN_HEIGHT <<< "${VNC_SCREEN_SIZE}"
export VNC_SCREEN="${SCREEN_WIDTH}x${SCREEN_HEIGHT}x24"
export CHROME_WINDOW_SIZE="${SCREEN_WIDTH},${SCREEN_HEIGHT}"

export CHROME_OPTS="${CHROME_OPTS_OVERRIDE:- --user-data-dir --no-sandbox --window-position=0,0 --force-device-scale-factor=1 --disable-dev-shm-usage}"

exec "$@"
