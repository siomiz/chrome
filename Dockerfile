FROM ubuntu:14.04

MAINTAINER Tomohisa Kusano <siomiz@gmail.com>

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive \
	apt-get install -y \
	ca-certificates \
	fonts-takao \
	gconf-service \
	gksu \
	libappindicator1 \
	libasound2 \
	libcurl3 \
	libgconf-2-4 \
	libnspr4 \
	libnss3 \
	libpango1.0-0 \
	python-psutil \
	supervisor \
	wget \
	x11vnc \
	xbase-clients \
	xdg-utils \
	xvfb \
	&& rm -rf /var/lib/apt/lists/*

ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /chrome.deb
ADD https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb /crd.deb

RUN dpkg -i /chrome.deb && dpkg -i /crd.deb && rm /chrome.deb /crd.deb

RUN ln -s /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN addgroup chrome-remote-desktop && useradd -m -G chrome-remote-desktop chrome
ENV CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES 1024x768

RUN echo "#!/bin/bash\nsudo -E -u chrome -H /usr/bin/python /opt/google/chrome-remote-desktop/chrome-remote-desktop --start --foreground --config=\`ls /home/chrome/.config/chrome-remote-desktop/*.json | head -1\`" \ 
		> crdonly \
	&& chmod +x /crdonly \
	&& echo "exec /opt/google/chrome/chrome --no-sandbox --window-position=0,0 --window-size=1024,768" \
		> /home/chrome/.chrome-remote-desktop-session

VOLUME ["/home/chrome"]

EXPOSE 5900

CMD ["/usr/bin/supervisord"]

