FROM ubuntu:14.04

MAINTAINER Tomohisa Kusano <siomiz@gmail.com>

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive \
	apt-get install -y \
	ca-certificates \
	fonts-takao \
	gconf-service \
	libappindicator1 \
	libasound2 \
	libcurl3 \
	libgconf-2-4 \
	libnspr4 \
	libnss3 \
	libpango1.0-0 \
	supervisor \
	wget \
	x11vnc \
	xdg-utils \
	xvfb \
	&& rm -rf /var/lib/apt/lists/*

ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /chrome.deb

RUN dpkg -i /chrome.deb && rm /chrome.deb

RUN ln -s /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5900

CMD ["/usr/bin/supervisord"]

