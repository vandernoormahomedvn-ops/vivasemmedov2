---
description: Cria a estrutura padrão de pastas para uma nova *feature* seguindo a arquitetura em qualquer app.
---

# Scaffolding: Nova Funcionalidade

Garante que respeitamos a nossa regra de estrutura Clean Architecture (`screens/`, `widgets/`, `models/`, `repositories/`, `controllers/`).

1. Ajuste a variável da app e da funcionalidade antes de rodar o workflow (Editando este bloco ou copiando para o terminal).

```bash
# Defina o Alvo
APP="flexpress_admin"
FEATURE="kyc_verification"

# Gere as pastas
cd $APP/lib/features && mkdir -p $FEATURE/screens $FEATURE/widgets $FEATURE/models $FEATURE/repositories $FEATURE/controllers

echo "✨ Estrutura base da feature '$FEATURE' criada com sucesso dento de '$APP'."
```
