###############################################################################
# RSD-STACK :: rdenck/efw
# ElasticFlow Hardened - Debian Based
###############################################################################

# Stage 1: Builder
FROM debian:12-slim@sha256:56ff6d36d4eb3db13a741b342ec466f121480b5edded42e4b7ee850ce7a418ee AS builder

ARG EFW_VER=7.7.2
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && \
    wget -q https://elastiflow-releases.s3.us-east-2.amazonaws.com/flow-collector/flow-collector_${EFW_VER}_linux_amd64.deb && \
    mkdir -p /tmp/extract && \
    dpkg-deb -x flow-collector_${EFW_VER}_linux_amd64.deb /tmp/extract

# Stage 2: Runtime
FROM rdenck/base-runtime:12

LABEL org.opencontainers.image.title="rdenck/efw"
LABEL org.opencontainers.image.version="7.7.2"

USER root

COPY --from=builder /tmp/extract/usr/share/elastiflow/bin/flowcoll /opt/rsd/bin/flowcoll

# Garante permissões
RUN chown -R rsd:rsd /opt/rsd && \
    chmod +x /opt/rsd/bin/flowcoll

USER rsd
WORKDIR /opt/rsd

EXPOSE 2055/udp 6343/udp 4739/udp

# Entrypoint via tini
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/rsd/bin/flowcoll"]
