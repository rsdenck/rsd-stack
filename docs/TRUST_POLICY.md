# TRUST POLICY — RSD-STACK

## 1. POLÍTICA DE CONFIANÇA (SUPPLY CHAIN)
Esta política define os critérios de aceitação para imagens de container no ambiente `rsd-stack`.

### 1.1 Critérios de Aceitação
Nenhuma imagem será executada no ambiente de produção sem atender a:
1. **Assinatura Criptográfica:** Deve possuir assinatura válida via Cosign (Keyless via OIDC).
2. **Registro de Proveniência:** Deve possuir SBOM (Software Bill of Materials) associado.
3. **Integridade de Hash:** O digest SHA256 da imagem deve corresponder ao registrado em `security/trust/hashes.txt`.
4. **Build Autorizado:** A imagem deve ter sido construída exclusivamente via GitHub Actions oficial do repositório.

## 2. FLUXO DE VERIFICAÇÃO
Antes de qualquer operação de `docker compose up`, o script `scripts/verify_supply_chain.sh` deve ser executado.
Se qualquer verificação falhar, o deploy deve ser abortado imediatamente.

## 3. GESTÃO DE CHAVES
- O ambiente utiliza **Keyless Signing**. A confiança é baseada na identidade do workflow do GitHub Actions.
- Verificação manual pode ser feita via:
  ```bash
  cosign verify ghcr.io/rsdenck/rsd-stack/rsd/<service>:<tag> \
    --certificate-identity-regexp https://github.com/rsdenck/rsd-stack/.github/workflows/docker-build.yml \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com
  ```
