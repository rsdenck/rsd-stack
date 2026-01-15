###############################################################################
# RSD-STACK :: rsd/wzh
# Wazuh Manager Hardened - Debian Based
###############################################################################

FROM rsd/base-runtime:12

LABEL org.opencontainers.image.title="rsd/wzh"
LABEL org.opencontainers.image.version="4.7.2"

USER root

# Instalação do Wazuh Manager
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 \
    && wget -qO - https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && apt-get install -y --no-install-recommends wazuh-manager=4.7.2-1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Link simbólico para padronização RSD
RUN ln -s /var/ossec /opt/rsd/wazuh

# Hardening: Usuário RSD precisa estar nos grupos do Wazuh ou vice-versa
RUN usermod -aG ossec rsd

# Scripts de inicialização simplificados (sem systemd)
RUN echo '#!/bin/bash\n\
/var/ossec/bin/wazuh-control start\n\
tail -f /var/ossec/logs/ossec.log' > /usr/local/bin/wazuh-entrypoint.sh && \
chmod +x /usr/local/bin/wazuh-entrypoint.sh

EXPOSE 1514/udp 1515/tcp 55000/tcp

# Entrypoint usando o script de controle via tini
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/wazuh-entrypoint.sh"]
