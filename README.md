# RSD-STACK :: Sovereign Observability & Security

[![Linux Compliance](https://img.shields.io/badge/Linux-100%25%20Compliant-green.svg)](RT-10.md)
[![Deterministic Build](https://img.shields.io/badge/Build-Deterministic-blue.svg)](RT-11.md)
[![Integrity](https://img.shields.io/badge/Integrity-SHA256%20Verified-gold.svg)](RT-12.md)
[![CI/CD Ready](https://img.shields.io/badge/CI%2FCD-Ready%20(ALTA)-orange.svg)](RT-14.md)

A **RSD-STACK** é uma arquitetura de monitoramento de rede (Flows), segurança (Wazuh SIEM) e observabilidade (ELK) projetada para soberania de dados e máxima segurança.

> [!WARNING]
> **DOCKER DESKTOP ≠ PRODUÇÃO**
> O Docker Desktop (Windows/Mac) deve ser utilizado **apenas para homologação e desenvolvimento**. Ambientes de produção **devem** utilizar Linux Nativo (Debian/Ubuntu/RHEL) para garantir performance, isolamento de kernel e estabilidade.

---

## 1. Visão Geral da Stack

A stack é composta por containers altamente endurecidos (Hardened) baseados em uma imagem comum (`rsd/base-runtime:12`):

- **rsd-els**: Elasticsearch 8.13.4 (Data Lake)
- **rsd-lgs**: Logstash 8.13.4 (Pipeline de Ingestão)
- **rsd-kbn**: Kibana 8.13.4 (Visualização e SIEM)
- **rsd-wzh**: Wazuh Manager 4.7.2 (Segurança de Endpoint)
- **rsd-efw**: Elastiflow Collector 7.7.2 (Netflow/IPFIX)

---

## 2. Requisitos Mínimos (Produção Linux)

| Recurso | Requisito Mínimo | Recomendado |
| :--- | :--- | :--- |
| **Kernel** | 5.10+ | 6.x+ |
| **Docker** | 24.0+ | 26.x+ |
| **Compose** | V2.20+ | V2.24+ |
| **CPU** | 4 Cores | 8+ Cores |
| **RAM** | 16 GB | 32 GB |
| **Disco** | 100 GB SSD | 500 GB+ NVMe |
| **OS** | Debian 12 / Ubuntu 22.04 | Debian 12 (Pure) |

**Configuração Crítica do Host:**
```bash
# Necessário para o Elasticsearch
sudo sysctl -w vm.max_map_count=262144
```

---

## 3. Estrutura de Diretórios

```text
.
├── docker/                 # Definições de Dockerfiles por serviço
│   ├── base-runtime/       # Imagem base endurecida (RT-09)
│   ├── els/                # Elasticsearch
│   ├── lgs/                # Logstash
│   └── ...                 # Demais serviços
├── ops/                    # Scripts de Operação e Build
│   ├── build-all.sh        # Orquestrador de build determinístico
│   ├── stack-up.ps1        # Entrypoint para homologação (Windows)
│   └── validate-build.sh   # Validador de contrato arquitetural
├── security/               # Governança e Trust Registry
│   └── trust/              # Hashes SHA256 de integridade
└── docker-compose.yml      # Orquestração principal
```

---

## 4. Fluxo de Build e Run

### A. Linux (Produção)
1. Clone o repositório.
2. Prepare o ambiente: `cp .env.example .env` (edite as senhas).
3. Execute o build determinístico:
   ```bash
   bash ops/build-all.sh
   ```
4. Inicie a stack:
   ```bash
   docker compose up -d
   ```

### B. Docker Desktop (Homologação)
Utilize o Runtime Gate para garantir que sua homologação é fiel à arquitetura:
```powershell
.\ops\stack-up.ps1
```

---

## 5. Pipeline CI/CD e Publicação

A **RSD-STACK** utiliza um fluxo de entrega contínua (CI/CD) rigoroso:

1. **Build**: Executado em runners Linux nativos.
2. **Lint & Security**: Validação via `ops/validate-build.sh` (RT-11A).
3. **Integridade**: Verificação de hashes SHA256 (RT-12).
4. **Push**: Imagens são publicadas no Docker Hub (`rsd/`) apenas se todos os gates passarem.

## 6. Política de Versionamento

- **Semântico (SemVer)**: `vMAJOR.MINOR.PATCH` (ex: `v1.0.0`).
- **Imutabilidade**: Tags publicadas no Docker Hub nunca são sobrescritas.
- **Vínculo**: Cada release no GitHub possui os hashes de integridade correspondentes às imagens publicadas.

## 7. Governança e Contratos Arquiteturais

A stack é governada por contratos técnicos rígidos, documentados através de **Relatórios Técnicos (RTs)**:

- **[RT-09](RT-09.md)**: Contrato Arquitetural (Regras de Ouro).
- **[RT-11](RT-11.md)**: Garantia de Build Determinístico.
- **[RT-12](RT-12.md)**: Governança de Integridade.
- **[RT-15](RT-15.md)**: Validação Final Pré-Publicação.

---
**Desenvolvido por: rsdenck - Ranlens Denck**
