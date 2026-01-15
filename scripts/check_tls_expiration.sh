#!/bin/sh
###############################################################################
# RSD-STACK :: CHECK TLS EXPIRATION
# Autor: rsdenck - Ranlens Denck
# Objetivo: Verificar validade de certificados no host e retornar status SRE
###############################################################################

# Configurações
CERT_DIR="./certs"
THRESHOLD_WARN=30
THRESHOLD_CRIT=15
EXIT_STATUS=0

# Cores para saída manual
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

printf "=== RSD-STACK :: TLS EXPIRATION CHECK ===\n"

# Verifica se o diretório de certificados existe
if [ ! -d "$CERT_DIR" ]; then
    printf "${RED}[ERROR]${NC} Diretório de certificados não encontrado: %s\n" "$CERT_DIR"
    exit 2
fi

# Busca por arquivos de certificado (.crt ou .pem)
CERTS=$(find "$CERT_DIR" -type f \( -name "*.crt" -o -name "*.pem" \))

if [ -z "$CERTS" ]; then
    printf "${YELLOW}[WARN]${NC} Nenhum certificado encontrado em %s\n" "$CERT_DIR"
    exit 0
fi

for cert in $CERTS; do
    # Extrai a data de expiração usando openssl
    EXP_DATE=$(openssl x509 -enddate -noout -in "$cert" | cut -d= -f2)
    
    # Converte datas para segundos (Epoch) para comparação
    # Nota: Uso de 'date' compatível com POSIX/BSD/GNU
    if uname | grep -q "Darwin"; then
        EXP_EPOCH=$(date -j -f "%b %d %T %Y %Z" "$EXP_DATE" "+%s")
    else
        EXP_EPOCH=$(date -d "$EXP_DATE" "+%s")
    fi
    
    NOW_EPOCH=$(date "+%s")
    DIFF_SECONDS=$((EXP_EPOCH - NOW_EPOCH))
    DIFF_DAYS=$((DIFF_SECONDS / 86400))

    # Lógica de Threshold
    if [ "$DIFF_DAYS" -le "$THRESHOLD_CRIT" ]; then
        STATUS="${RED}[CRITICAL]${NC}"
        [ "$EXIT_STATUS" -lt 2 ] && EXIT_STATUS=2
    elif [ "$DIFF_DAYS" -le "$THRESHOLD_WARN" ]; then
        STATUS="${YELLOW}[WARNING]${NC}"
        [ "$EXIT_STATUS" -lt 1 ] && EXIT_STATUS=1
    else
        STATUS="${GREEN}[OK]${NC}"
    fi

    printf "%s %s: %s dias restantes (%s)\n" "$STATUS" "$cert" "$DIFF_DAYS" "$EXP_DATE"
done

printf "==========================================\n"
printf "Final Status Exit Code: %s\n" "$EXIT_STATUS"
exit "$EXIT_STATUS"
