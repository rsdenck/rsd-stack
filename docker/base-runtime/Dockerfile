###############################################################################
# RSD-STACK :: rdenck/base-runtime
# Debian 12 Hardened Base Image
###############################################################################

FROM debian:12-slim@sha256:56ff6d36d4eb3db13a741b342ec466f121480b5edded42e4b7ee850ce7a418ee

ENV RSD_BASE=/opt/rsd
ENV TZ=UTC
ENV LC_ALL=C.UTF-8

# Instalação de dependências críticas e Tini
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    ca-certificates \
    curl \
    procps \
    netcat-openbsd \
    libstdc++6 \
    libc6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Estrutura de diretórios padronizada
RUN mkdir -p ${RSD_BASE}/bin \
    ${RSD_BASE}/config \
    ${RSD_BASE}/certs \
    ${RSD_BASE}/data \
    ${RSD_BASE}/logs \
    ${RSD_BASE}/tmp

# Hardening: Usuário RSD
RUN groupadd -g 10001 rsd && \
    useradd -u 10001 -g 10001 -d ${RSD_BASE} -s /bin/bash rsd

# Permissões base
RUN chown -R rsd:rsd ${RSD_BASE} && \
    chmod -R 755 ${RSD_BASE}/bin && \
    chmod -R 770 ${RSD_BASE}/data ${RSD_BASE}/logs ${RSD_BASE}/config ${RSD_BASE}/certs

WORKDIR ${RSD_BASE}

ENTRYPOINT ["/usr/bin/tini", "--"]
