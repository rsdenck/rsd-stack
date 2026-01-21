###############################################################################
# RSD-STACK :: rdenck/wzh
# Wazuh Manager Hardened - Debian Based
###############################################################################

FROM rdenck/base-runtime:12

LABEL org.opencontainers.image.title="rdenck/wzh"
LABEL org.opencontainers.image.version="4.7.2"

USER root

# Instalação do Wazuh Manager
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 \
    && curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && apt-get install -y --no-install-recommends wazuh-manager=4.7.2-1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Link simbólico e Hardening
RUN ln -s /var/ossec /opt/rsd/wazuh && \
    usermod -aG wazuh rsd

# Copia configuração e garante permissões
COPY config/ossec.conf /var/ossec/etc/ossec.conf
RUN chown root:wazuh /var/ossec/etc/ossec.conf && \
    chmod 660 /var/ossec/etc/ossec.conf

# Scripts de inicialização simplificados (sem systemd)
RUN echo '#!/bin/bash\n\
chown -R wazuh:wazuh /var/ossec/logs\n\
chown -R wazuh:wazuh /var/ossec/data\n\
/var/ossec/bin/wazuh-control start\n\
sleep 5\n\
tail -f /var/ossec/logs/ossec.log' > /usr/local/bin/wazuh-entrypoint.sh && \
    chmod +x /usr/local/bin/wazuh-entrypoint.sh

# Garante permissões
EXPOSE 1514/udp 1515/tcp 55000/tcp

RUN chown -R wazuh:wazuh /var/ossec && \
    chmod -R 770 /var/ossec

# USER rsd  <-- Removido para permitir que o Wazuh inicie seus processos como root

# Entrypoint usando o script de controle via tini
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/wazuh-entrypoint.sh"]
