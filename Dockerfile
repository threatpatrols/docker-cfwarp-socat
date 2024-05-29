
# https://hub.docker.com/_/debian/tags
FROM debian:stable-slim

# Hello
LABEL maintainer="Nicholas de Jong <ndejong@threatpatrols.com>"
LABEL source="https://github.com/threatpatrols/docker-cfwarp-socat"

# install prerequisites and cloudflare-warp
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y socat procps curl lsb-release gpg && \
    apt-get install -y iputils-ping inetutils-traceroute && \
    \
    curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get install -y cloudflare-warp && \
    \
    mkdir -p /var/lib/cloudflare-warp/data && \
    touch /var/lib/cloudflare-warp/data/reg.json && \
    \
    mkdir -p /root/.local/share/warp && \
    echo -n 'yes' > /root/.local/share/warp/accepted-tos.txt && \
    echo -n 'yes' > /root/.local/share/warp/accepted-teams-tos.txt && \
    warp-cli --version && \
    \
    apt-get clean && \
    apt-get autoremove -y


COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=1 \
  CMD warp-cli --accept-tos status | grep -qE "Connected" || exit 1
