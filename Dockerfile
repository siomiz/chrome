FROM ubuntu:22.04

LABEL maintainer="Tomohisa Kusano <siomiz@gmail.com>"

ENV VNC_SCREEN_SIZE=1024x768

COPY copyables /

# Update packages, install essential dependencies, and clean up
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gnupg2 \
    fonts-noto-cjk \
    pulseaudio \
    supervisor \
    x11vnc \
    fluxbox \
    eterm \
    wget && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf /var/cache/* /var/log/apt/* /tmp/*

# Install Latest Google Chrome and Chrome Remote Desktop
RUN wget --no-check-certificate -O /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    wget --no-check-certificate -O /tmp/chrome-remote-desktop.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/google-chrome-stable.deb /tmp/chrome-remote-desktop.deb && \
    rm /tmp/google-chrome-stable.deb /tmp/chrome-remote-desktop.deb

# Configure the environment
RUN useradd -m -G chrome-remote-desktop,pulse-access chrome && \
    usermod -s /bin/bash chrome && \
    ln -s /crdonly /usr/local/sbin/crdonly && \
    ln -s /update /usr/local/sbin/update && \
    mkdir -p /home/chrome/.config/chrome-remote-desktop /home/chrome/.fluxbox && \
    echo ' \n\
       session.screen0.toolbar.visible:        false\n\
       session.screen0.fullMaximization:       true\n\
       session.screen0.maxDisableResize:       true\n\
       session.screen0.maxDisableMove: true\n\
       session.screen0.defaultDeco:    NONE\n\
    ' >> /home/chrome/.fluxbox/init && \
    chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

USER chrome

VOLUME ["/home/chrome"]

WORKDIR /home/chrome

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]