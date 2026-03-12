---
description: Limpeza profunda nas dependências e cache local de todos os projetos Flutter (User, Rider, Admin)
---

# Limpeza Global & Refresh de Dependências

Múltiplas aplicações no mesmo ecossistema podem criar problemas de cache, versões erradas do CocoaPods ou cache sujo do Flutter. 

Ao rodar este workflow, ele re-instalará todo o core das apps. Pode levar alguns minutos.

// turbo-all
1. Deep Clean - `flexpress_app`
```bash
cd flexpress_app && flutter clean && flutter pub get && cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ../..
```

2. Deep Clean - `flexpress_rider`
```bash
if [ -d "flexpress_rider" ]; then cd flexpress_rider && flutter clean && flutter pub get && cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ../..; else echo "Rider app not found."; fi
```

3. Deep Clean - `flexpress_admin`
```bash
if [ -d "flexpress_admin" ]; then cd flexpress_admin && flutter clean && flutter pub get && cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ../..; else echo "Admin app not found."; fi
```
