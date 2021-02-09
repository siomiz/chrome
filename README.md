I was tired of not being able to queue downloads from my iPad while "discovering" new content. This container runs a full Chrome browser on a Ubuntu
base. This is because it is the easiest way to sync bookmarks from all connected browsers in real time.

What this does:
- Starts a VNC server for initial setup. Currently also prepares Chrome Remote Desktop.
- Scans all bookmarks for certain patterns every 15 minutes via cronjob.
- If a matching url is found, the downloader does the real magic.
- Outputs to /output/literotica and /output/luscious respectively.

This image supports PGID and PUID as ENV, so your output is nice and tidy!

For persistent login data I recommend manually mounting /home/chrome !

Supported Environment variables:

| Environment var | default value | what it does |
| ENABLE_VNC | false | VNC is necessary for first setup and login |
| VNC_SCREEN_SIZE | 1024x768 | default screen size for VNC setup |
| OUTPUT | /output | default output folder, also used for logfile |
| OUT_LUSCIOUS | /output/luscious | if separate volume is mounted |
| OUT_LITEROTICA | /output/literotica | if separate volume is mounted |
| ENABLE_LOG | false | set to true to get all commands written to logfile |
| ENABLE_JD | false | handler for Pornhub downloads, sends urls to JD_DEVICE |
| JD_USER | not set | required for MyJDownloader login |
| JD_PASS | not set | required for MyJDownloader login |
| JD_DEVICE | not set | case-sensitive name of MyJD device name |
| PUID | 911 | user id for file system permissions |
| PGID | 911 | group id for file system permissions |

Example:
<pre><code>docker run -d \
--name=bookmark-dl \
-p 5900:5900 \
-v bookmark-dl-conf:/home/chrome \
-v bookmark-dl-output:/output \
-e PUID=1000 \
-e PGID=1000 \
-e ENABLE_VNC=true \
--restart unless-stopped \
npr0n/bookmark-dl
</code></pre>

To be done:

- add caching for urls
- add url cleanup ?
- add TZ env variable
- make image smaller & remove CRD
- add VNC HTML support for setup ?
- add support for more pages ?


Currently this Image uses:
- `ubuntu:18.04` - Base image
- [`siomiz/chrome`](https://hub.docker.com/r/siomiz/chrome/) - basic functionality, forked for slimming (TBD)
- [`openone/litero`](https://github.com/openone/litero) - downloader for literotica
- [`Lucas8x/luscious-downloader`](https://github.com/Lucas8x/luscious-downloader) - downloader for luscious
- [`mmarquezs/myjdapi`](https://github.com/mmarquezs/My.Jdownloader-API-Python-Library/) - api to connect to MyJDownloader, used for Pornhub




Until this is much further I will keep siomiz' ReadMe intact:
###############################################################

 - The testing branch for [RandR](https://en.wikipedia.org/wiki/RandR) (i.e. "Resize desktop to fit" in CRD client) is merged into master/latest.

Google Chrome via VNC
==
`docker run -p 127.0.0.1:5900:5900 siomiz/chrome`

 - Google Chrome, not Chromium, for the ease of Flash plugin management
 - on Xvfb, with FluxBox (no window decorations)
 - served by X11VNC (no password; assuming usage via SSH)

Must agree to [Google Chrome ToS][1] to use.

Google Chrome via Chrome Remote Desktop
==
... so you can use the full Google Chrome with Flash on iPad (with preliminary sound support)!
Much faster than VNC thanks to VP8!

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

Docker ホスト(ヘッドレス可！)で走らせれば、「艦これ」等 Flash ブラウザゲームを iPad/iPhone/Android 等上の Chrome リモート デスクトップ アプリで一応プレイ可能になります。サウンド付き(遅延があります)。
Chrome は英語版ですが、Web ページ用の日本語フォントは含まれています。[詳しくはこちら。][3]

Chrome Updates
--
It is recommended to `docker pull siomiz/chrome` and restart the container once in a while to update chrome & crd inside (they will not get automatically updated). Optionally you can run `docker exec <chrome-container> update` to upgrade only google-chrome-stable from outside the container (exit Chrome inside CRD after upgrading).

  [1]: https://www.google.com/intl/en/chrome/browser/privacy/eula_text.html
  [2]: https://code.google.com/p/chromium/issues/detail?id=490964
  [3]: https://github.com/siomiz/chrome/wiki/%E6%97%A5%E6%9C%AC%E8%AA%9E
