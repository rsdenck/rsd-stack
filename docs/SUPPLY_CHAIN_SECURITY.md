# SUPPLY CHAIN SECURITY — RSD-STACK

## 1. ARQUITETURA DE CONFIANÇA
A `rsd-stack` utiliza uma cadeia de suprimentos de software (Supply Chain) protegida criptograficamente, garantindo a proveniência e integridade de cada imagem do build ao deploy.

## 2. COMPONENTES DE SEGURANÇA

### 2.1 SBOM (Software Bill of Materials)
- **Ferramenta:** Syft
- **Formato:** CycloneDX (JSON)
- **Local:** `security/sbom/*.json`
- **Função:** Inventário completo de todas as bibliotecas, dependências e camadas presentes nas imagens Distroless. Permite análise de vulnerabilidades (VEX) offline.

### 2.2 Assinatura de Imagens (Cosign)
- **Modelo:** Keyless (identidade via OIDC GitHub)
- **Identidade Autorizada:** Workflow `docker-build.yml`
- **Função:** Garante que a imagem no registry foi realmente construída pelo pipeline oficial e não foi alterada por terceiros.

### 2.3 Trust Registry (Hashes)
- **Local:** `security/trust/hashes.txt`
- **Função:** Registro imutável (via Git) dos digests SHA256 das imagens autorizadas. Serve como fonte da verdade para o script de verificação de deploy.

## 3. PROCEDIMENTO DE VERIFICAÇÃO
O deploy só deve prosseguir se a verificação de supply chain for bem-sucedida:
```bash
bash scripts/verify_supply_chain.sh
```

## 4. CONFORMIDADE SLSA
A stack busca aderência aos níveis **SLSA (Supply-chain Levels for Software Artifacts)**, garantindo que o processo de build seja isolado, parametrizado e possua proveniência verificável.
