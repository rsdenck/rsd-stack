# RSD-STACK :: Service Container

Esta imagem faz parte da **RSD-STACK**, uma solução de Observabilidade e Segurança Soberana.

## ⚠️ AVISO IMPORTANTE
Esta imagem foi projetada para funcionar exclusivamente dentro da orquestração da **RSD-STACK**. O uso isolado não é suportado e pode violar os controles de segurança e governança da stack.

## Sobre o Serviço
- **Base Image**: `rsd/base-runtime:12` (Debian 12 Hardened)
- **Init System**: `tini` (PID 1)
- **Segurança**: Usuário não-root (UID 10001), `cap_drop: ALL`.

## Documentação e Código Fonte
Para instruções de instalação, guias de deploy e código fonte completo, acesse o repositório oficial:

🔗 [https://github.com/rsdenck/rsd-stack](https://github.com/rsdenck/rsd-stack)

---
**Mantido por: rsdenck**
