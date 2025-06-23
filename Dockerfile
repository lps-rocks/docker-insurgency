# Build from Debian 11 Slim image
FROM debian:bullseye-slim

# ENV Variables for installing server
ENV STEAM_APP=237410 \
    STEAM_AUTO_UPDATE=false \
    SERVER_NAME="insurgency" \
    SERVER_ADDITIONAL_PARAMS="" \
    PUID=1000 \
    PGID=1000
# Stop apt-get asking to get Dialog frontend
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

# Enable additional repositories
RUN sed -i -e's/ main$/ main contrib non-free/g' /etc/apt/sources.list

# Add i386 packages
RUN dpkg --add-architecture i386

# Preseed SteamCMD install
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# Install SteamCMD
RUN apt-get update && \
    apt-get -y install -y procps tmux locales sudo ca-certificates bash lib32gcc-s1 steamcmd net-tools zlib1g:i386 && \
    apt-get clean

# Clean up APT
RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Set Bash as default /bin/sh
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \ 
    LC_ALL=en_US.UTF-8

# Add the steam user
RUN adduser \
    --disabled-login \
    --disabled-password \
    --shell /bin/bash \
    --gecos "" \
    steam && \
    usermod -G tty steam

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Ports
EXPOSE 27015/udp

# Expose Mounts
VOLUME ["/home/steam/insurgency"]

# Working directory
WORKDIR /home/steam

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
