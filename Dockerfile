FROM ubuntu:22.04

LABEL maintainer="Tomohisa Kusano <siomiz@gmail.com>"

ENV VNC_SCREEN_SIZE=1024x768

COPY copyables /

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
	gnupg2 \
	fonts-noto-cjk \
	pulseaudio \
	supervisor \
	x11vnc \
	fluxbox \
	eterm

ADD https://dl.google.com/linux/linux_signing_key.pub \
	https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
	https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
	/tmp/

RUN apt-key add /tmp/linux_signing_key.pub \
	&& dpkg -i /tmp/google-chrome-stable_current_amd64.deb \
	|| dpkg -i /tmp/chrome-remote-desktop_current_amd64.deb \
	|| DEBIAN_FRONTEND=noninteractive apt-get -f --yes install

RUN apt-get clean \
	&& rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/* \
	&& useradd -m -G chrome-remote-desktop,pulse-access chrome \
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
	&& chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

USER chrome

VOLUME ["/home/chrome"]

WORKDIR /home/chrome

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
