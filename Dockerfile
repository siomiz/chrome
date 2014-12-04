FROM ubuntu:14.04

# enable multiverse for flashplugin-nonfree
RUN sed -ri '/multiverse/s/^# //' /etc/apt/sources.list

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive \
	apt-get install -y \
	x11vnc \
	xvfb \
	# fonts-takao \
	gconf-service \
	libgconf-2-4 \
	libappindicator1 \
	xdg-utils \
	libasound2 \
	libnspr4 \
	libnss3 \
	libpango1.0-0 \
	ca-certificates \
	libcurl3 \
	wget

ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /chrome.deb

RUN dpkg -i /chrome.deb

RUN ln -s /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 5900

CMD ["x11vnc", "-display", ":1", "-nopw"]

