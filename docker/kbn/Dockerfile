###############################################################################
# RSD-STACK :: rdenck/kbn
# Kibana Hardened - Debian Based
###############################################################################

# Stage 1: Builder
FROM docker.elastic.co/kibana/kibana:8.13.4@sha256:aa596f0f8eac0529b4275128699db835e1d839d60ac5af05e3f3a1764d52ae79 AS builder

# Stage 2: Runtime
FROM rdenck/base-runtime:12

LABEL org.opencontainers.image.title="rdenck/kbn"
LABEL org.opencontainers.image.version="8.13.4"

USER root

# Kibana precisa de fontes e bibliotecas para relatórios/PDF
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-liberation \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV KBN_HOME=/opt/rsd

# Copia binários do estágio builder
COPY --from=builder --chown=rsd:rsd /usr/share/kibana /opt/rsd

# Garante permissões
RUN chown -R rsd:rsd /opt/rsd && \
    chmod -R 770 /opt/rsd/data /opt/rsd/logs /opt/rsd/config

USER rsd
WORKDIR /opt/rsd

EXPOSE 5601

# Entrypoint usando o script oficial via tini
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/rsd/bin/kibana"]
