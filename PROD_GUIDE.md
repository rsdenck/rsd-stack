# RSD-STACK :: GUIA DE PRODUÇÃO (REVERSE PROXY + HA + K8s READY)
**VERSÃO: 1.1 — EXECUÇÃO REAL**

Este documento detalha a arquitetura de produção da RSD-STACK, focando em escalabilidade, alta disponibilidade (HA) e segurança enterprise.

---

## TEMA 1 — NGINX (DECISÃO ARQUITETURAL)

### Análise de Opções
| Critério | Nginx no HOST | Nginx em CONTAINER | Nginx INGRESS (K8s) |
| :--- | :--- | :--- | :--- |
| **Performance** | Máxima (sem overhead de rede Docker) | Alta (isolamento de processo) | Otimizada (nativo K8s) |
| **Segurança** | Direta (Kernel Hardening) | Isolada (Namespace/Cgroups) | Centralizada (Policy-based) |
| **Observabilidade** | Logs via Host (Syslog) | Logs via Docker (JSON/STDOUT) | Logs via Metrics Server |
| **Kubernetes** | Difícil integração | Não recomendado | Padrão Nativo |

### **PADRÃO OFICIAL RSD-STACK: Nginx em CONTAINER (Docker) e INGRESS CONTROLLER (K8s)**
Para manter a portabilidade e a paridade funcional entre Docker e Kubernetes, o Nginx deve ser tratado como um serviço de infraestrutura orquestrado.

---

## TEMA 2 — REVERSE PROXY PARA KIBANA (PRODUÇÃO)

A exposição do Kibana deve ser realizada exclusivamente via Reverse Proxy com TLS obrigatório.

### 1. Configuração de Domínios
- **ELK UI:** `kibana.rsd.local` -> Aponta para `kbn-ui01:5601`
- **Flow UI:** `flow.rsd.local` -> Aponta para `efw-kbn01:5601`

### 2. Regras de Segurança (Nginx)
- **TLS 1.3:** Obrigatório. Cifras seguras (HSTS ativo).
- **Headers de Segurança:** `X-Frame-Options`, `X-Content-Type-Options`, `Content-Security-Policy`.
- **Bloqueio de Portas:** As portas 5601 e 5602 NÃO devem ser expostas diretamente no Firewall/Load Balancer.
- **RBAC:** Integração direta com o Elasticsearch para autenticação (Native Realm).

---

## TEMA 3 — CLUSTER ELASTICSEARCH (3 NÓS)

Em produção, o Elasticsearch deve operar em cluster para garantir a integridade dos dados e tolerância a falhas.

### 1. Componentes
- **Nós:** `els-nd01`, `els-nd02`, `els-nd03` (Todos Master-eligible + Data).
- **Discovery:** `discovery.seed_hosts` contendo os FQDNs dos 3 nós.
- **Quorum:** `cluster.initial_master_nodes` definido no bootstrap inicial.

### 2. Persistência
- **Docker:** Volumes nomeados com drivers de alta performance (XFS/EXT4).
- **Kubernetes:** `StatefulSet` com `VolumeClaimTemplates` (SSD/NVMe obrigatório).

---

## TEMA 4 — HA WAZUH (SIEM ENTERPRISE)

### 1. Cluster de Managers
- **Nós:** `wzh-mgr01`, `wzh-mgr02` (Ativo/Ativo com sincronização de base).
- **Load Balancing:** Agentes apontam para um VIP ou FQDN balanceado (Porta 1514/1515).

### 2. Indexers (HA)
- **Nós:** `wzh-idx01`, `wzh-idx02`, `wzh-idx03`.
- **Papel:** Armazenamento distribuído de alertas e monitoramento de integridade.

---

## TEMA 5 — DOCKER vs KUBERNETES (PARIDADE)

| Conceito | Docker Compose | Kubernetes |
| :--- | :--- | :--- |
| **Orquestração** | `docker-compose.yml` | `Deployments / StatefulSets` |
| **Rede** | `networks (bridge/overlay)` | `Services / Ingress` |
| **Armazenamento** | `volumes (named)` | `PersistentVolumeClaims (PVC)` |
| **Segurança** | `user: "10001:10001"` | `SecurityContext (runAsUser: 10001)` |

---

## TEMA 6 — SEGURANÇA ENTERPRISE

1. **Isolamento de Rede:** Redes separadas para tráfego de ingestão (`elk_net`) e gerência (`mgmt_net`).
2. **TLS End-to-End:** Comunicação criptografada entre todos os nós do cluster (Elasticsearch e Wazuh).
3. **Hardening:** Imagens base baseadas em `debian:12-slim` com remoção de binários desnecessários e execução como usuário não-root (exceto Wazuh Manager).

---
**Execução:** SRE Team | **Projeto:** RSD-STACK
