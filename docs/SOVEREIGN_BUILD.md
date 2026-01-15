# PRODUCTION READY — CRYPTOGRAPHICALLY TRUSTED RELEASE

## 1. PRINCÍPIOS DO BUILD SOBERANO
A `rsd-stack` utiliza um processo de build **determinístico e reproduzível**, garantindo que o binário em execução seja idêntico bit-a-bit ao código auditado.

## 2. GARANTIAS TÉCNICAS

### 2.1 Reproduzibilidade
- **Base Image Pinning:** Uso de digests SHA256 em vez de tags mutáveis.
- **Timestamp Clamping:** Todos os arquivos nos containers possuem timestamps fixos (2026-01-14) para garantir hashes de camada idênticos.
- **Deterministic Environment:** TZ=UTC e LC_ALL=C.UTF-8 forçados no build e runtime.

### 2.2 Cadeia de Custódia (Supply Chain)
- **SBOM (CycloneDX):** Inventário completo de dependências gerado via Syft e versionado em `security/sbom/`.
- **Assinatura Cosign:** Assinaturas Keyless baseadas em OIDC, vinculando a imagem ao workflow oficial do GitHub.
- **Trust Registry:** O arquivo `security/trust/images.sha256` é a única fonte da verdade para o Runtime Gate.

## 3. PROCEDIMENTO DE RELEASE
Cada release (vX.Y.Z) dispara o workflow `RSD-STACK-SOVEREIGN-BUILD`, que executa:
1. Build determinístico.
2. Escaneamento lógico (SBOM).
3. Assinatura criptográfica.
4. Registro de hash no Trust Registry.

## 4. VERIFICAÇÃO DE SOBERANIA
Para validar a integridade de uma release no host de produção:
```bash
# Executa o gate de soberania completo
bash ops/stack-up.sh
```

## 5. CONCLUSÃO
A stack está agora em estado de **"CRYPTOGRAPHICALLY TRUSTED RELEASE"**, onde a segurança não é uma configuração, mas uma propriedade matemática do artefato gerado.
