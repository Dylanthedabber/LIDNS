FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && \
    apt-get install -y nginx python3-pip openssl curl dnsutils netcat-openbsd iptables nftables && \
    pip3 install websockets && \
    rm -rf /var/lib/apt/lists/*

# CoreDNS
COPY coredns.tgz /tmp/
RUN tar -xzf /tmp/coredns.tgz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/coredns && \
    rm /tmp/coredns.tgz

# App files
COPY fake-relay.py prewarm-api.py /opt/
COPY lsrelay/ /var/www/lsrelay/
COPY nginx-lsrelay.conf /etc/nginx/sites-available/lsrelay
COPY ext.cnf /etc/ssl/lsrelay/ext.cnf

# Baked-in CA (fixed across all LIDNS installs so users only install the cert once)
RUN mkdir -p /etc/ssl/lsrelay /etc/coredns
COPY ca.key ca.crt /etc/ssl/lsrelay/

# nginx setup
RUN ln -sf /etc/nginx/sites-available/lsrelay /etc/nginx/sites-enabled/lsrelay && \
    rm -f /etc/nginx/sites-enabled/default

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 53/udp 53/tcp 80/tcp 443/tcp

ENTRYPOINT ["/entrypoint.sh"]
