import chrome_bookmarks
import subprocess
import datetime
import getpass
import os
import myjdapi

output = os.environ.get('OUTPUT')
out_luscious = os.environ.get('OUT_LUSCIOUS')
out_literotica = os.environ.get('OUT_LITEROTICA')
jd_user = os.environ.get('JD_USER')
jd_pass = os.environ.get('JD_PASS')
jd_device = os.environ.get('JD_DEVICE')
enable_jd = os.environ.get('ENABLE_JD')
enable_log = os.environ.get('ENABLE_LOG')

# convert environment variables from strings to bools
if "true" in enable_jd:
    enable_jd = True
else:
    enable_jd = False

if "true" in enable_log:
    enable_log = True
else:
    enable_log = False

# Log run start
if enable_log:
    logfile = open("lastrun.txt", "w")
    logfile.write(f"Start : {datetime.datetime.now().strftime(%c)}")
    logfile.write(f"User  : {getpass.getuser()}")
    if enable_jd:
        logfile.write(f"JDown.: {enable_jd}")

# connect to jdownloader
if enable_jd:
    # check if username present
    if not jd_user:
        if enable_log:
            logfile.write(f"No MyJDownloader username given. Disabling JDownloader.")
        enable_jd = False
    # check if password present
    elif not jd_pass:
        if enable_log:
            logfile.write(f"No MyJDownloader password given. Disabling JDownloader.")
        enable_jd = False
    # check if device name present
    elif not jd_device:
        if enable_log:
            logfile.write(f"No MyJDownloader device given. Disabling JDownloader.")
        enable_jd = False
    else:
        # set up 
        jd = myjdapi.Myjdapi()
        jd.set_app_key("bookmark-dl-testing")
        # try connecting with user and pass
        if not jd.connect(jd_user, jd_pass):
            # connection failed:
            if enable_log:
                logfile.write(f"MyJDownloader authentication failed. Disabling JDownloader.")
                enable_jd = False
        # connection worked, look for device name
        elif not jd.get_device(jd_device):
            # device name not online
            if enable_log:
                logfile.write(f"MyJDownloader device not found. Disabling JDownloader.")
                enable_jd = False
        # connect to device / instance
        else:
            jd_instance = jd.get_device(jd_device)
    # if anything failed: export ENV variable to skip this step next time
    if not enable_jd:
        os.environ['ENABLE_JD'] = False


for url in chrome_bookmarks.urls:
    # Testing
    if "test" in url.url:
        cmd = f"echo 'Testing url: {url.url}'"
    # Luscious
    elif "luscious.net/albums/" in url.url:
        cmd = f"lsd -o {out_luscious} -a {url.url}"
    elif "luscious.net/users/" in url.url:
        cmd = f"lsd -a {out_luscious} -u {url.url}"
    
    # Literotica
    elif "literotica.com/" in url.url:
        # beta url rewrite
        if "/beta/s/" in url.url:
            url.url = url.url.replace("/beta/s/", "/s/")
        cmd = f"cd {out_literotica} && litero_getstory -u {url.url}"
    
    # Pornhub
    elif "pornhub.com/" in url.url:
        if enable_jd:
            jd_instance.linkgrabber.add_links([{"packageName":url.Name, "links":url.url}])
            cmd = f"echo 'added {url.url} as {url.Name} to {jd_instance}'"
        else:
            cmd = f"echo 'enable_jd is set to {enable_jd}"

    # Skip
    else:
        continue
    
    # Logging
    if enable_log:
        logfile.write(f"Cmd:   : {cmd}")
    subprocess.run(cmd, shell=True)

# Log run finish
if enable_log:
    logfile.write(f"Finish: {datetime.datetime.now().strftime(%c)}")
    logfile.close()