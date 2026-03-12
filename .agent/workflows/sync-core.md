---
description: Sincroniza a pasta lib/core (UI e design system) entre as aplicações do Flexpress
---

# Sincronização do Core (PremiumGlass & Themes)

Como o Flexpress opera com múltiplas aplicações (User, Rider, Admin), é crítico que o Design System (`PremiumGlass`, `AppTheme`, Constantes) seja sempre partilhado e igual em todos os projetos. Este workflow garante que o `flexpress_app` actua como a **Single Source of Truth** (Fonte Principal) para a interface.

// turbo
1. Sincronizar `lib/core` para a App do Motoboy (`flexpress_rider`)
```bash
rsync -av --delete flexpress_app/lib/core/ flexpress_rider/lib/core/
```

// turbo
2. Sincronizar `lib/core` para a App Admin (`flexpress_admin`) - se existir
```bash
if [ -d "flexpress_admin" ]; then rsync -av --delete flexpress_app/lib/core/ flexpress_admin/lib/core/; else echo "Projeto flexpress_admin ainda não existe. Ignorando."; fi
```

> [!TIP]
> Execute este workflow sempre que fizer alterações nas cores, widgets partilhados ou estilos de vidro na app principal.
