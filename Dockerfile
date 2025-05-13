FROM alpine:3.18

LABEL maintainer="your-team@example.com"

RUN apk add --no-cache bash curl

COPY scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
