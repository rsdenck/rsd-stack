# GUIA DE INSTALAÇÃO (v2.0.0)

## Preparação do Ambiente
1. Ajuste o `vm.max_map_count` no host:
   ```bash
   sysctl -w vm.max_map_count=262144
   ```
2. Clone o repositório e configure as variáveis de ambiente:
   ```bash
   cp deploy/docker/.env.example deploy/docker/.env
   ```

## Deploy via Docker Compose
```bash
cd deploy/docker
docker compose up -d
```

## Deploy via Kubernetes
1. Crie os namespaces:
   ```bash
   kubectl apply -f deploy/kubernetes/namespaces/
   ```
2. Aplique as configurações e segredos (não inclusos no repo público).
3. Faça o deploy da stack:
   ```bash
   kubectl apply -R -f deploy/kubernetes/
   ```

## Verificação
- Acesse `https://kibana.rsd.local`
- Verifique o status do cluster:
  ```bash
  curl -k -u elastic:password https://rsd-els:9200/_cluster/health
  ```
