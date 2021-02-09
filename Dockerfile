FROM ubuntu:18.04

LABEL maintainer="npr0n"

ENV VNC_SCREEN_SIZE 1024x768
ENV OUTPUT /output
ENV OUT_LUSCIOUS /output/luscious
ENV OUT_LITEROTICA /output/literotica
ENV ENABLE_JD false
ENV ENABLE_LOG false
ENV ENABLE_VNC false

COPY copyables /

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	gdebi \
	gnupg2 \
	fonts-noto-cjk \
	pulseaudio \
	supervisor \
	x11vnc \
	fluxbox \
	eterm \
	&& apt-get install -y \
    python3 \
    python3-pip \
    cron \
	npm \
	nodejs

ADD https://dl.google.com/linux/linux_signing_key.pub \
	https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
	https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
	/tmp/

RUN apt-key add /tmp/linux_signing_key.pub \
	&& gdebi --non-interactive /tmp/google-chrome-stable_current_amd64.deb \
	&& gdebi --non-interactive /tmp/chrome-remote-desktop_current_amd64.deb

RUN apt-get clean \
	&& rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/* \
	&& addgroup --gid 1000 chrome \
	&& useradd -m -G chrome-remote-desktop,pulse-access -u 911 -g 1000 chrome \
	&& usermod -s /bin/bash chrome \
	&& ln -s /crdonly /usr/local/sbin/crdonly \
	&& ln -s /update /usr/local/sbin/update \
	&& mkdir -p /home/chrome/.config/chrome-remote-desktop \
	&& mkdir -p /home/chrome/.fluxbox \
	&& echo ' \n\
		session.screen0.toolbar.visible:        false\n\
		session.screen0.fullMaximization:       true\n\
		session.screen0.maxDisableResize:       true\n\
		session.screen0.maxDisableMove: true\n\
		session.screen0.defaultDeco:    NONE\n\
	' >> /home/chrome/.fluxbox/init \
	&& mv /usercron /home/chrome/ \
	&& chown -R chrome:chrome /home/chrome \
    && python3 -m pip install chrome-bookmarks luscious-downloader myjdapi \
	&& npm install -g litero \
    && systemctl enable cron \
    && su chrome -c "crontab ~/usercron; rm ~/usercron"

VOLUME [ "/home/chrome" ]

VOLUME [ "/output" ]

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]