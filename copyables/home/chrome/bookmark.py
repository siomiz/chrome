import chrome_bookmarks
import subprocess

out_luscious = "/output/luscious"

for url in chrome_bookmarks.urls:
    if "https://www.luscious.net/" in url.url:
        cmd = "lsd -o "+out_luscious+" -a "+url.url
        subprocess.run(cmd, shell=True)