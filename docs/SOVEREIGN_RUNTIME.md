# SOVEREIGN RUNTIME CONTROL — RSD-STACK

## 1. VISÃO GERAL
O **Sovereign Runtime Control (SRC)** é a camada final de defesa da `rsd-stack`. Ele implementa um gate de execução determinístico que impede o deploy de qualquer artefato que não tenha sido explicitamente auditado e assinado criptograficamente.

## 2. COMPONENTES DO GATE

### 2.1 Entrypoint Único (`ops/stack-up.sh`)
- Substitui o uso direto de `docker-compose up`.
- Centraliza as validações antes de liberar o binário do Docker.
- Implementa lógica de fail-fast e isolamento de erros.

### 2.2 Verificação de Orquestração (`security/verify_compose.sh`)
- Valida o hash SHA256 do `docker-compose.yml` contra o `security/trust/compose.sha256`.
- Impede alterações manuais ou maliciosas no arquivo de definição da stack (ex: adição de containers priviligiados ou mapeamentos de volumes indevidos).

### 2.3 Verificação de Supply Chain (`security/verify_supply_chain.sh`)
- **Assinaturas:** Valida assinaturas Cosign Keyless via OIDC.
- **Hashes Travados:** Compara o digest da imagem local com o registro de auditoria em `security/trust/images.sha256`.
- **Bloqueio:** Se uma imagem foi alterada no registry (mesmo mantendo a tag `latest`), o hash divergirá e o deploy será abortado.

## 3. OPERAÇÃO EM PRODUÇÃO

### 3.1 Fluxo de Deploy
O operador deve executar exclusivamente:
```bash
bash ops/stack-up.sh
```

### 3.2 Bloqueio de Bypass
Para ambientes altamente hardened, recomenda-se a configuração de aliases no host:
```bash
alias docker-compose='echo "Use ops/stack-up.sh para gerenciar a rsd-stack"'
alias docker='echo "Acesso direto ao Docker bloqueado por política de Sovereign Runtime"'
```

## 4. GESTÃO DE CONFIANÇA (TRUST REGISTRY)
Sempre que o `docker-compose.yml` for alterado legalmente ou novas versões de imagens forem auditadas, os hashes devem ser atualizados:

1. **Atualizar Hash do Compose:**
   ```bash
   sha256sum docker-compose.yml | awk '{print $1}' > security/trust/compose.sha256
   ```

2. **Atualizar Hashes de Imagens:**
   Atualizar manualmente o arquivo `security/trust/images.sha256` após o build e push oficial.

## 5. CONCLUSÃO TÉCNICA
A `rsd-stack` atinge o estado de **"APROVADA PARA PRODUÇÃO — SOVEREIGN RUNTIME CONTROL"**, onde a execução é subordinada à prova criptográfica, eliminando a confiança no operador e no registry.
