# RUNTIME HARDENING — RSD-STACK

## 1. VISÃO GERAL
Este documento detalha as medidas de endurecimento (hardening) aplicadas em tempo de execução para a `rsd-stack`. O objetivo é garantir que cada container opere sob o princípio do menor privilégio, em um ambiente imutável e Zero Trust.

## 2. CONTROLES DE HARDENING APLICADOS

### 2.1 Imutabilidade do Filesystem (`read_only: true`)
Todos os containers rodam com o sistema de arquivos raiz em modo **Somente Leitura**.
- **Justificativa:** Impede a persistência de malware ou alterações não autorizadas no runtime.
- **Exceções:** Apenas volumes persistentes e `tmpfs` para diretórios temporários necessários.

### 2.2 Privilégios Mínimos
- **Non-Root User:** Todos os serviços executam com UID/GID `10001:10001`.
- **Security Opt:** `no-new-privileges:true` impede que processos ganhem novos privilégios via `setuid` ou `setgid`.
- **Cap Drop:** `ALL` capabilities do Linux foram removidas. Os containers não possuem permissões administrativas de kernel (ex: `NET_ADMIN`, `SYS_ADMIN`).

### 2.3 Isolamento de Recursos
- **tmpfs:** `/tmp` e `/run` são montados em memória (RAM), garantindo que dados temporários não persistam e que o filesystem raiz permaneça `read_only`.
- **Resource Limits:** Limites de CPU e Memória estritamente definidos via Docker Compose.

### 2.4 Healthchecks Funcionais
Healthchecks baseados em execução binária direta (sem shell):
- **Elasticsearch:** Validação via CLI Terminal.
- **Kibana:** Validação via Node.js embutido.
- **Wazuh:** Validação via `wazuh-control status`.
- **Logstash/ElasticFlow:** Validação de runtime Java.

## 3. IMPACTO OPERACIONAL
- **Segurança:** Redução drástica da superfície de ataque. Vulnerabilidades de OS são irrelevantes devido ao uso de **Distroless**.
- **Debug:** O troubleshooting deve ser feito via logs externos ou métricas. Não é possível realizar `docker exec -it` para abrir uma shell nos containers.
- **Disponibilidade:** Healthchecks garantem que serviços dependentes só iniciem quando o backend estiver pronto.

## 4. ALINHAMENTO ZERO TRUST
A `rsd-stack` não confia no ambiente local do container. Toda comunicação é criptografada (TLS) e todo runtime é restrito ao mínimo necessário para a função do serviço.
