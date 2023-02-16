_:new: Recent update made `chrome` the running USER. Chrome profile must be owned by user `chrome` so you may need to run `docker exec --volumes-from <your-chrome-profile> --user root siomiz/chrome chown -R chrome:chrome /home/chrome` to fix permission issues._

Google Chrome via VNC
==
`docker run -p 127.0.0.1:5900:5900 siomiz/chrome`

 - Google Chrome, ~~not Chromium, for the ease of Flash plugin management~~
 - on Xvfb, with FluxBox (no window decorations)
 - served by X11VNC (no password; assuming usage via SSH)

Must agree to [Google Chrome ToS][1] to use.

Google Chrome via Chrome Remote Desktop
==

Prerequisite: Create a Profile Volume
--
You need a VNC client for the initial setup.

 1. `docker run -d --name chrome-profile siomiz/chrome` (NO password so DO NOT simply use -p 5900:5900 to expose it to the world!)
 2. Connect to the container via VNC. Find the container's IP address by `docker inspect -f '{{ .NetworkSettings.IPAddress }}' chrome-profile`
 3. Install the "Chrome Remote Desktop" Chrome extension via VNC and activate it, authorize it, and My Computers > Enable Remote Connections, then set a PIN. (Google Account required)
 4. `docker stop chrome-profile`

(Technically the only config file CRD uses is `/home/chrome/.config/chrome-remote-desktop/~host.json` which includes OAuth token and private key.)

Usage
--
`docker run -d --volumes-from chrome-profile siomiz/chrome /crdonly` (no port needs to be exposed)
`/crdonly` command will run chrome-remote-desktop in foreground.

Chrome Updates
--
It is recommended to `docker pull siomiz/chrome` and restart the container once in a while to update chrome & crd inside (they will not get automatically updated). Optionally you can run `docker exec --user=root <chrome-container> update` to upgrade only google-chrome-stable from outside the container (exit Chrome inside CRD after upgrading).

  [1]: https://www.google.com/intl/en/chrome/browser/privacy/eula_text.html
  [2]: https://code.google.com/p/chromium/issues/detail?id=490964
