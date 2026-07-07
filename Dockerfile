FROM alpine:latest

RUN apk add --no-cache strongswan iptables

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
