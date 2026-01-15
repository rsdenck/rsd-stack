###############################################################################
# RSD-STACK :: rsd/els
# Elasticsearch Hardened - Debian Based
###############################################################################

# Stage 1: Builder
FROM docker.elastic.co/elasticsearch/elasticsearch:8.13.4@sha256:9825c856b5157d1d2c44923f8bda22f84ffe2ccd04a980f4da22c1976202e870 AS builder

# Stage 2: Runtime
FROM rsd/base-runtime:12

LABEL org.opencontainers.image.title="rsd/els"
LABEL org.opencontainers.image.version="8.13.4"

USER root

# Instalação do OpenJDK (Elasticsearch 8.13.4 usa Java 17)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV ES_HOME=/opt/rsd
ENV ES_PATH_CONF=/opt/rsd/config

# Copia binários do estágio builder
COPY --from=builder --chown=rsd:rsd /usr/share/elasticsearch /opt/rsd

# Garante permissões
RUN chown -R rsd:rsd /opt/rsd && \
    chmod -R 770 /opt/rsd/data /opt/rsd/logs /opt/rsd/config

USER rsd
WORKDIR /opt/rsd

EXPOSE 9200 9300

# Entrypoint usando o script oficial via tini
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/rsd/bin/elasticsearch"]
