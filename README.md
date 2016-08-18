 - Screen size is currently hardcoded as 1024x768.
 - A testing branch for [RandR](https://en.wikipedia.org/wiki/RandR) (i.e. "Resize desktop to fit" in CRD client) is available; Use Docker image tag **:randr**.

Google Chrome via VNC
==
`docker run -p 127.0.0.1:5900:5900 siomiz/chrome`

 - Google Chrome, not Chromium, for the ease of Flash plugin management
 - on Xvfb
 - served by X11VNC (no password; assuming usage via SSH)

Must agree to [Google Chrome ToS][1] to use.

Google Chrome via Chrome Remote Desktop
==
... so you can use the full Google Chrome with Flash on iPad (with preliminary sound support)!
Much faster than VNC thanks to VP8!

No "desktop"; session goes straight to a maximized chrome.

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

On first connection (and after an "unclean" container stop) you will get a "Profile Locked / owned by different process" dialog, which you can just select "Relaunch".

Docker ホスト(ヘッドレス可！)で走らせれば、「艦これ」等 Flash ブラウザゲームを iPad/iPhone/Android 等上の Chrome リモート デスクトップ アプリで一応プレイ可能になります。サウンド付き(遅延があります)。
Chrome は英語版ですが、Web ページ用の日本語フォントは含まれています。[詳しくはこちら。][3]

Chrome Updates
--
It is recommended to `docker pull siomiz/chrome` and restart the container once in a while to update chrome & crd inside (they will not get automatically updated). Optionally you can run `docker exec <chrome-container> update` to upgrade only google-chrome-stable from outside the container (exit Chrome inside CRD after upgrading).

  [1]: https://www.google.com/intl/en/chrome/browser/privacy/eula_text.html
  [2]: https://code.google.com/p/chromium/issues/detail?id=490964
  [3]: https://github.com/siomiz/chrome/wiki/%E6%97%A5%E6%9C%AC%E8%AA%9E
