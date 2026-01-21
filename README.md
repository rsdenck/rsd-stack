# RSD-STACK v2.0 (Enterprise Ready)

## Status: Produção Enterprise
Esta stack representa uma solução completa de SIEM, Log Management e Observabilidade de Redes, desenhada para alta disponibilidade e segurança.

## Escopo Real da Stack
- **Elasticsearch Cluster:** 3 nós (`els-nd01`, `els-nd02`, `els-nd03`) com suporte a quorum e persistência distribuída.
- **Logstash HA:** Pipelines redundantes (`lgs-pl01`, `lgs-pl02`) para processamento de logs.
- **Kibana UI:** Interface de visualização centralizada com RBAC.
- **Wazuh HA:** SIEM/XDR com 2 Managers e Indexers em Alta Disponibilidade.
- **ElasticFlow HA:** Coleta e análise de NetFlow/IPFIX em escala.
- **Security:** Nginx Reverse Proxy com terminação TLS obrigatória.

## Pré-requisitos
- **Docker:** v24.0.0+ e Docker Compose v2.20.0+
- **Kubernetes:** v1.26+ (para deploy em cluster)
- **Recursos Mínimos (LAB):** 16GB RAM, 4 CPUs
- **Recursos Recomendados (PROD):** 64GB+ RAM, 16 CPUs, Armazenamento SSD/NVMe

## Modos de Deploy

### Docker Compose (On-Premise / Edge)
```bash
cd deploy/docker
docker compose up -d
```

### Kubernetes (Cloud / Cluster)
```bash
kubectl apply -f deploy/kubernetes/namespaces/
kubectl apply -f deploy/kubernetes/elasticsearch/
kubectl apply -f deploy/kubernetes/logstash/
kubectl apply -f deploy/kubernetes/kibana/
kubectl apply -f deploy/kubernetes/wazuh/
kubectl apply -f deploy/kubernetes/elasticflow/
kubectl apply -f deploy/kubernetes/ingress/
```

## Estrutura do Repositório
- `/deploy/docker`: Orquestração via Docker Compose.
- `/deploy/kubernetes`: Manifestos para orquestração em cluster.
- `/deploy/nginx`: Configurações do Reverse Proxy.
- `/docs`: Documentação técnica detalhada (Arquitetura, HA, Segurança).
- `/docker`: Definições de imagens customizadas e configurações de serviço.
- `/certs`: Certificados e infraestrutura de PKI.

## Segurança
- Todos os endpoints expostos via HTTPS.
- Backend isolado em redes privadas (`elk_net`, `wazuh_net`).
- Usuários não-root (10001:10001) para execução de containers.
- Certificados TLS em toda a comunicação interna.

---
**Versão:** v2.0.0
**Mantenedor:** RSD Team
