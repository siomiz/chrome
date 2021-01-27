import chrome_bookmarks
import subprocess

out_luscious = "/output/luscious"
out_literotica = "/output/literotica"

for url in chrome_bookmarks.urls:
    # Luscious
    if "luscious.net/albums/" in url.url:
        cmd = "lsd -o "+out_luscious+" -a "+url.url
    elif "luscious.net/users/" in url.url:
        cmd = "lsd -a "+out_luscious+" -u "+url.url
    # Literotica
    elif "literotica.com/s/" in url.url:
        cmd = "literotica_dl -o "+out_literotica+" -s "+url.url
    elif "literotica.com/stories/memberpage.php?uid=" in url.url:
        cmd = "literotica_dl -o "+out_literotica+" -a "+url.url
    # Literotica beta rewrites url
    elif "literotica.com/beta/s/" in url.url:
        url = url.url.replace("beta/", "")
        cmd = "literotica_dl -o "+out_literotica+" -s "+url
    else:
        continue
    subprocess.run(cmd, shell=True)
