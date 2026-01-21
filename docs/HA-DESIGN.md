# DESIGN DE ALTA DISPONIBILIDADE (HA)

## Elasticsearch HA
- **Quorum:** Mínimo de 3 nós para evitar Split-Brain.
- **Roles:** Todos os nós operam como Master-eligible e Data nodes (configuração otimizada para médio porte).
- **Replicação:** `number_of_replicas: 1` garantido por política de index.

## Logstash HA
- **Horizontal Scaling:** 2 ou mais réplicas rodando o mesmo conjunto de pipelines.
- **Load Balancing:** O tráfego de entrada deve ser balanceado via Round-Robin ou Least-Connections (externo ou via Ingress).

## Wazuh HA
- **Cluster Mode:** Sincronização de integridade e regras entre Managers.
- **Indexer HA:** Mínimo de 2 nós indexadores para persistência de alertas SIEM.

## Nginx Proxy HA
- **Docker:** Rodando com `restart: unless-stopped`.
- **Kubernetes:** Rodando via Ingress Controller (Nginx) com HPA (Horizontal Pod Autoscaler).
