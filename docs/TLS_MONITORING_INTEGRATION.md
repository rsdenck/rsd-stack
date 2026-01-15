# INTEGRAÇÃO DE MONITORAMENTO TLS — RSD-STACK

## 1. AGENDAMENTO VIA CRON (HOST)
Para garantir a verificação diária automática, adicione ao crontab do usuário gestor da stack:

```bash
# Executa todo dia às 03:00 AM
00 03 * * * /path/to/rsd-stack/scripts/check_tls_expiration.sh >> /var/log/rsd-stack-tls-check.log 2>&1
```

## 2. INTEGRAÇÃO COM ZABBIX (USER PARAMETER)
Adicione ao arquivo de configuração do Zabbix Agent no host:

```text
UserParameter=rsd.stack.tls.status,/path/to/rsd-stack/scripts/check_tls_expiration.sh | tail -n 1 | cut -d: -f2 | xargs
```

**Mapeamento de Triggers no Zabbix:**
- Valor `0`: OK
- Valor `1`: Warning (Notificar via E-mail/Slack)
- Valor `2`: Critical (Abrir chamado de Incidente Urgente)

## 3. INTEGRAÇÃO COM GITHUB ACTIONS (CI/CD)
Adicione uma etapa de validação no seu pipeline de deploy para garantir que nenhum certificado expirado seja promovido:

```yaml
- name: Verify TLS Expiration
  run: |
    chmod +x ./scripts/check_tls_expiration.sh
    ./scripts/check_tls_expiration.sh
```

## 4. EXEMPLOS DE ALERTA (STDOUT)

### Cenário OK:
```text
[OK] ./certs/elasticsearch/v1/tls.crt: 88 dias restantes (May 15 12:00:00 2026 GMT)
Final Status Exit Code: 0
```

### Cenário CRITICAL:
```text
[CRITICAL] ./certs/wazuh/v1/tls.crt: 12 dias restantes (Jan 26 12:00:00 2026 GMT)
Final Status Exit Code: 2
```

## 5. BOAS PRÁTICAS DE AGENDAMENTO
- **Frequência:** Uma vez por dia é suficiente para certificados de 90 dias.
- **Centralização:** Envie a saída do script para um agregador de logs (ex: o próprio Logstash da stack) para dashboarding histórico.
- **Fail-Safe:** O script retorna exit code não-zero, o que permite integração direta com qualquer ferramenta de monitoramento que suporte monitoramento de processos ou scripts.
