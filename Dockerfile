FROM alpine:3.18

LABEL maintainer="your-team@examplee.com"

COPY scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
