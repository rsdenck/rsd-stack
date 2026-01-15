# RUNBOOK: ROTAÇÃO DE CERTIFICADOS TLS — RSD-STACK

## 1. PRÉ-REQUISITOS
- Acesso ao host onde a `rsd-stack` está rodando.
- Binário `openssl` instalado.
- Chave da Autoridade Certificadora (CA) disponível e protegida.

## 2. FASE 1: GERAÇÃO (OFFLINE)
Não gere certificados dentro dos containers. Utilize o host ou uma máquina de gestão.

1. **Gerar Nova Versão:**
   Siga a estrutura de versionamento da `TLS_POLICY.md`. Se a versão atual é `v1`, crie a `v2`.
   ```bash
   mkdir -p ./certs/elasticsearch/v2
   openssl req -new -nodes -newkey rsa:4096 -keyout ./certs/elasticsearch/v2/tls.key -out ./certs/elasticsearch/v2/tls.csr
   # Assinar com a CA
   openssl x509 -req -in ./certs/elasticsearch/v2/tls.csr -CA ./certs/ca/v1/ca.crt -CAkey ./certs/ca/v1/ca.key -CAcreateserial -out ./certs/elasticsearch/v2/tls.crt -days 90
   ```

## 3. FASE 2: VALIDAÇÃO
Antes de aplicar, valide o novo certificado:
```bash
openssl x509 -in ./certs/elasticsearch/v2/tls.crt -text -noout | grep "Not After"
```

## 4. FASE 3: SUBSTITUIÇÃO
A `rsd-stack` utiliza volumes montados. Para atualizar sem mudar o `docker-compose.yml`, utilize links simbólicos ou substitua os arquivos no path mapeado.

1. **Backup da versão atual:**
   ```bash
   cp -a ./certs/elasticsearch/v1 ./certs/elasticsearch/v1.bak
   ```
2. **Atualização do path ativo:**
   ```bash
   cp ./certs/elasticsearch/v2/* ./certs/elasticsearch/active/
   ```

## 5. FASE 4: RESTART SEQUENCIAL (CRÍTICO)
Os serviços devem ser reiniciados na ordem de dependência para evitar falhas de handshake durante a subida.

| Ordem | Serviço | Comando |
| :--- | :--- | :--- |
| 1 | **Elasticsearch** | `docker compose restart rsd-els` |
| 2 | **Logstash** | `docker compose restart rsd-lgs` |
| 3 | **Kibana** | `docker compose restart rsd-kbn` |
| 4 | **Wazuh** | `docker compose restart rsd-wzh` |
| 5 | **ElasticFlow** | `docker compose restart rsd-efw` |

## 6. FASE 5: VERIFICAÇÃO PÓS-ROTINA
1. **Logs:** Verifique se não há erros de `SSL Handshake failed`.
   ```bash
   docker compose logs -f rsd-els
   ```
2. **Script de Monitoramento:**
   ```bash
   ./scripts/check_tls_expiration.sh
   ```

## 7. PLANO DE EMERGÊNCIA (ROLLBACK)
Se o serviço não subir ou houver erro de TLS:
1. Reverter arquivos para a versão `.bak`.
2. Reiniciar a stack na mesma ordem sequencial.
3. Investigar a CA emissora e os SANs (Subject Alternative Names) do novo certificado.
