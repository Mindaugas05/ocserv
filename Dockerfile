FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ocserv \
        iproute2 \
        iptables \
        ca-certificates \
        procps \
        openssl \
        kmod && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
    /etc/ocserv \
    /etc/ocserv/certs \
    /var/log/ocserv \
    /var/run/ocserv

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
