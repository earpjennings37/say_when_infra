FROM alpine:3.21.3

ARG POPEYE_VERSION=v0.22.1
ARG TARGETARCH=arm64

RUN apk add --no-cache curl tar ca-certificates

RUN curl -L \
    "https://github.com/derailed/popeye/releases/download/${POPEYE_VERSION}/popeye_Linux_${TARGETARCH}.tar.gz" \
    -o /tmp/popeye.tar.gz \
    && tar -xzf /tmp/popeye.tar.gz -C /tmp \
    && mv /tmp/popeye /bin/popeye \
    && chmod +x /bin/popeye \
    && rm -f /tmp/popeye.tar.gz

RUN adduser -u 5000 -D nonroot

USER 5000

ENTRYPOINT ["/bin/popeye"]