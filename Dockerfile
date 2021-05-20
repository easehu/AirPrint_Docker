FROM debian:latest
MAINTAINER AirPrint Docker Maintainers "24173177@qq.com"

ENV TERM xterm
ENV LC_ALL=C
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# User ustc sources
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Install Packages (basic tools, cups, basic drivers, HP drivers, python3 libs)
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \ 
    apt-get install -y \
    net-tools \
    cups \
    cups-client \
    cups-bsd \
    cups-filters \
    foomatic-db-compressed-ppds \
    openprinting-ppds \
    hp-ppd \
    hplip \
    hpijs-ppds \
    printer-driver-all \
    printer-driver-cups-pdf \
    avahi-discover \
    python-cups \
    python3-dev \
    python3-pip \
    libcups2-dev \
    inotify-tools && \
    python3 -m pip config set global.index-url https://pypi.mirrors.ustc.edu.cn/simple/ && \
    python3 -m pip --no-cache-dir install --upgrade pip && \
    python3 -m pip install pycups && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose IPP printer sharing
EXPOSE 631/tcp

# Expose avahi advertisement
EXPOSE 5353/udp

# Mount config volume
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n    Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n    Allow All\n    Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n    Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
    sed -i 's/# alias ll/alias ll/' /root/.bashrc && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

#Run Script
CMD ["/root/run_cups.sh"]

