FROM node:12.13.0-stretch-slim

ARG GOOGLE_CHROME_CHANNEL

ENV GOOGLE_CHROME_CHANNEL=${GOOGLE_CHROME_CHANNEL:-stable} \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    NODE_NO_WARNINGS=1 \
    NODE_PENDING_DEPRECATION=0 \
    NODE_ENV=production \
    NODE_PATH="${NODE_PATH}:/usr/local/lib/node_modules" \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN echo "\
path-exclude=/usr/share/man/*\n\
path-exclude=/usr/share/doc/*\n\
path-exclude=/usr/share/doc-base/*\n\
path-exclude=/usr/share/locale/*\n\
path-exclude=/usr/share/groff/*\n\
path-exclude=/usr/share/info/*\n\
path-exclude=/usr/share/lintian/*\n\
path-exclude=/usr/share/linda/*\n\
\n\
path-include=/usr/share/locale/locale.alias\n\
path-include=/usr/share/locale/en*" > /etc/dpkg/dpkg.cfg.d/excludes

RUN if ! command -v gpg > /dev/null; then \
	apt-get -qqy update \
	&& apt-get -qqy install --no-install-recommends gnupg curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get -qqy clean \
	; fi

RUN curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get -qqy update \
    && apt-get -qqy install --no-install-recommends google-chrome-${GOOGLE_CHROME_CHANNEL} \
    && rm -rf \
        /etc/apt/sources.list.d/google-chrome.list \
        /usr/share/man/* \
        /usr/share/doc/* \
        /var/lib/apt/lists/* \
        /var/cache/apt/* \
        /var/tmp/* \
    && apt-get -qqy clean
    
COPY ./build /tmp/build
COPY ./bin /usr/local/bin

RUN cp -a /tmp/build/google-chrome-$GOOGLE_CHROME_CHANNEL /usr/local/bin/google-chrome-shim \
	&& chmod 0755 /usr/local/bin/google-chrome-shim \
	&& mkdir -m 0755 -p /etc/skel/.config \
    && cp /tmp/build/chrome-flags.conf /etc/skel/.config/ \
	&& chmod 0644 /etc/skel/.config/chrome-flags.conf \
    && GOOGLE_CHROME_VERSION=$(/opt/google/chrome/chrome --product-version | cut -d'.' -f1) \
    && npm update -g npm \
    && npm install --production --global puppeteer-core@chrome-$GOOGLE_CHROME_VERSION

RUN useradd -m -G audio,video chrome \
	&& usermod -L chrome \
    && mv /tmp/build/test.sh /home/chrome/ \
    && chown -R chrome:chrome /home/chrome/ \
	&& rm -rf /tmp/*

USER chrome
WORKDIR /home/chrome
RUN ~/test.sh \
	&& rm -rf ~/test.sh \
		~/screenshot.png \
		~/.pki \
		~/.cache

CMD ["/bin/bash"]