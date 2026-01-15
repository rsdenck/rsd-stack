###############################################################################
# RSD-STACK :: rsd/efw
# ElasticFlow Hardened - Debian Based
###############################################################################

# Stage 1: Builder
FROM debian:12-slim@sha256:7f46571599388147d2b45e751859c0490f23075c3f309d949216f46142750e38 AS builder

ARG EFW_VER=7.7.2
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && \
    wget -q https://elastiflow-releases.s3.us-east-2.amazonaws.com/flow-collector/flow-collector_${EFW_VER}_linux_amd64.deb && \
    mkdir -p /tmp/extract && \
    dpkg-deb -x flow-collector_${EFW_VER}_linux_amd64.deb /tmp/extract

# Stage 2: Runtime
FROM rsd/base-runtime:12

LABEL org.opencontainers.image.title="rsd/efw"
LABEL org.opencontainers.image.version="7.7.2"

USER root

# Copia binários do estágio builder para o path padronizado
COPY --from=builder /tmp/extract/usr/bin/flowcoll /opt/rsd/bin/flowcoll

# Garante permissões
RUN chown -R rsd:rsd /opt/rsd && \
    chmod +x /opt/rsd/bin/flowcoll

USER rsd
WORKDIR /opt/rsd

EXPOSE 2055/udp 6343/udp 4739/udp

# Entrypoint via tini
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/rsd/bin/flowcoll"]
