# ARQUITETURA DA RSD-STACK v2.0

## Visão Geral
A RSD-STACK é uma plataforma soberana de SRE e Segurança, estruturada em microserviços orquestrados com foco em resiliência e isolamento.

## Componentes
- **Camada de Ingestão:** Logstash HA e ElasticFlow Collectors.
- **Camada de Armazenamento:** Cluster Elasticsearch (3 nós) com shard allocation awareness.
- **Camada de Inteligência:** Wazuh Managers em cluster para correlação de eventos SIEM.
- **Camada de Visualização:** Kibana centralizado e instâncias dedicadas para fluxos de rede.
- **Camada de Borda:** Nginx Reverse Proxy gerenciando terminação TLS e roteamento por DNS.

## Redes (Isolamento)
- `elk_net`: Tráfego de dados entre Logstash, Elasticsearch e Kibana.
- `wazuh_net`: Tráfego isolado para indexadores e gerentes do Wazuh.
- `mgmt_net`: Rede de gerência para acesso via Proxy e APIs administrativas.

## Fluxo de Dados
1. Agentes (Wazuh/Beats) -> Ingestão (Logstash/Manager).
2. Ingestão -> Armazenamento (Elasticsearch Cluster).
3. Armazenamento -> Visualização (Kibana via Proxy).
