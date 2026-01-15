# POLÍTICA DE GOVERNANÇA TLS — RSD-STACK

## 1. VISÃO GERAL
Esta política define os padrões de segurança, validades e procedimentos para a gestão de certificados TLS na infraestrutura `rsd-stack`, garantindo a integridade da comunicação Zero Trust em ambientes SOC/NOC 24x7.

## 2. TAXONOMIA DE CERTIFICADOS

| Tipo | Descrição | Emissor |
| :--- | :--- | :--- |
| **Root CA** | Autoridade Certificadora Raiz (Offline) | Auto-assinada |
| **Intermediate CA** | CA para emissão operacional | Root CA |
| **Service Certificate** | Certificados de endpoint (serviços) | Intermediate CA |

## 3. PADRÕES DE VALIDADE

- **Root CA:** 3650 dias (10 anos)
- **Intermediate CA:** 365 dias (1 ano)
- **Service Certificates:** 90 dias

> **Nota:** A validade curta para serviços (90 dias) é obrigatória para mitigar riscos de comprometimento e forçar a automação/rotina de rotação.

## 4. ESTRUTURA DE VERSIONAMENTO (SISTEMA DE ARQUIVOS)
Os certificados devem ser armazenados no host seguindo a estrutura de subdiretórios para permitir rollbacks rápidos e rastreabilidade:

```text
certs/
├── ca/
│   └── v1/ (ca.crt, ca.key)
├── elasticsearch/
│   └── v1/ (tls.crt, tls.key)
├── logstash/
│   └── v1/ (tls.crt, tls.key)
├── kibana/
│   └── v1/ (tls.crt, tls.key)
├── wazuh/
│   └── v1/ (tls.crt, tls.key)
└── elasticflow/
    └── v1/ (tls.crt, tls.key)
```

## 5. PROCESSO DE ROTAÇÃO
1. **Trigger:** Notificação de expiração (Threshold <= 30 dias).
2. **Geração:** Criação de novos CSRs e assinatura via Intermediate CA.
3. **Deploy:** Atualização dos arquivos no diretório versionado correspondente.
4. **Aplicação:** Restart sequencial dos containers conforme Runbook.

## 6. PLANO DE ROLLBACK
Em caso de falha na comunicação pós-rotação:
1. Identificar a versão anterior funcional (ex: `v1`).
2. Apontar o link simbólico ou copiar os arquivos da versão anterior para o path de montagem do volume.
3. Restart sequencial dos serviços afetados.

## 7. RESPONSABILIDADES
- **Time SRE:** Garantir a execução do script de monitoramento e integridade dos volumes.
- **Security Officer:** Custódia da Root CA e aprovação de novas Intermediate CAs.
- **Analista SOC:** Monitoramento de alertas de expiração no dashboard de observabilidade.
