#!/bin/bash
# RSD-STACK :: Validation Script
# Garante que os Dockerfiles seguem o Contrato Arquitetural RT-09

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "--------------------------------------------------"
echo "🔍 Validando Contrato Arquitetural (RT-09/RT-11A)"
echo "--------------------------------------------------"

FAILED=0

# --- Validação do docker-compose.yml (Governança de Runtime RT-11A) ---
echo -n "Validando limites de recursos no docker-compose.yml... "
COMPOSE_FILE="docker-compose.yml"
# Verifica se cada serviço tem a seção deploy.resources.limits.cpus definida
# Esta é uma validação simplificada via grep/awk; em produção, yq seria ideal.
SERVICES=$(grep "^  rsd-" "$COMPOSE_FILE" | sed 's/://g' | tr -d ' ')
for SVC in $SERVICES; do
    # Procura pelo bloco do serviço e verifica se há cpus: dentro de limits:
    # A lógica aqui busca a linha do serviço e as próximas 30 linhas
    if ! grep -A 30 "$SVC:" "$COMPOSE_FILE" | grep -A 5 "limits:" | grep -q "cpus:"; then
        echo -e "${RED}ERRO: Serviço $SVC sem limite de CPU definido!${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHA na validação do Compose${NC}"
fi

# --- Validação dos Dockerfiles ---
DOCKERFILES=$(find docker -name "Dockerfile" | grep -v "base-runtime")

validate_file() {
    local file=$1
    echo -n "Validando $file... "
    
    # 1. Verificar Base Image (exceto para a própria base image)
    if ! grep -q "FROM rsd/base-runtime:12" "$file"; then
        echo -e "${RED}ERRO: Não utiliza rsd/base-runtime:12${NC}"
        FAILED=1
        return
    fi

    # 1b. Verificar fixação de digest em Builders (se houver)
    if grep -q "AS builder" "$file" && ! grep -q "@sha256:" "$file"; then
        echo -e "${RED}ERRO: Builder image sem digest SHA256 fixado${NC}"
        FAILED=1
        return
    fi

    # 2. Verificar Tini Entrypoint
    if ! grep -q "ENTRYPOINT \[\"/usr/bin/tini\", \"--\"" "$file"; then
        echo -e "${RED}ERRO: Entrypoint não utiliza tini corretamente${NC}"
        FAILED=1
        return
    fi

    # 3. Verificar Paths (/opt/rsd)
    if ! grep -q "/opt/rsd" "$file"; then
        echo -e "${RED}ERRO: Não utiliza caminhos padronizados /opt/rsd${NC}"
        FAILED=1
        return
    fi

    # 4. Verificar Usuário não-root (deve terminar com USER rsd ou similar)
    # Nota: Algumas imagens podem trocar de usuário no meio, mas o final deve ser seguro
    # Wazuh é exceção conhecida nesta fase
    if [[ "$file" == *"wzh"* ]]; then
        echo -n "(Wazuh: Exceção de root permitida)... "
    elif grep -q "USER root" "$file" && [[ $(tail -n 5 "$file" | grep -c "USER rsd") -eq 0 ]]; then
         echo -e "${RED}ERRO: Possível execução como root detectada${NC}"
         FAILED=1
         return
    fi

    echo -e "${GREEN}OK${NC}"
}

# Validar base-runtime separadamente (regras diferentes)
echo -n "Validando docker/base-runtime/Dockerfile... "
if grep -q "FROM debian:12-slim@sha256:" "docker/base-runtime/Dockerfile" && grep -q "USER rsd" "docker/base-runtime/Dockerfile"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERRO: Base image fora dos padrões ou sem digest fixado${NC}"
    FAILED=1
fi

for f in $DOCKERFILES; do
    validate_file "$f"
done

echo "--------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ SUCESSO: Todos os componentes seguem o RT-09.${NC}"
    exit 0
else
    echo -e "${RED}❌ FALHA: Regressões arquiteturais detectadas!${NC}"
    exit 1
fi
