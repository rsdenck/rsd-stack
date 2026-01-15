###############################################################################
# RSD-STACK :: rsd/lgs
# Logstash Hardened - Debian Based
###############################################################################

# Stage 1: Builder
FROM docker.elastic.co/logstash/logstash:8.13.4@sha256:5664177599388147d2b45e751859c0490f23075c3f309d949216f46142750e38 AS builder

# Stage 2: Runtime
FROM rsd/base-runtime:12

LABEL org.opencontainers.image.title="rsd/lgs"
LABEL org.opencontainers.image.version="8.13.4"

USER root

# Instalação do OpenJDK
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LS_HOME=/opt/rsd

# Copia binários do estágio builder
COPY --from=builder --chown=rsd:rsd /usr/share/logstash /opt/rsd

# Garante permissões
RUN chown -R rsd:rsd /opt/rsd && \
    chmod -R 770 /opt/rsd/data /opt/rsd/logs /opt/rsd/config

USER rsd
WORKDIR /opt/rsd

EXPOSE 5044 9600

# Entrypoint usando o script oficial via tini
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/rsd/bin/logstash"]
