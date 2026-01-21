# POLÍTICA DE SEGURANÇA (SECURITY)

## Terminação TLS
- **Mandatório:** Todo tráfego externo é criptografado via TLS 1.2/1.3.
- **Interno:** Comunicação entre serviços usa certificados CA internos (Self-signed para v2.0).

## RBAC (Role Based Access Control)
- Kibana configurado com autenticação nativa do Elasticsearch.
- Perfis de acesso: `admin`, `readonly`, `security_analyst`.

## Isolamento de Containers
- **User Namespace:** Containers rodam com UID/GID 10001 (Non-root), exceto Wazuh Manager que requer permissões específicas de sistema.
- **Network Isolation:** Serviços de backend não possuem exposição de portas para o host (apenas via Proxy).

## Hardening
- Limites de recursos (CPU/RAM) aplicados em todos os serviços.
- Ulimits configurados para alta performance de IO no Elasticsearch.
