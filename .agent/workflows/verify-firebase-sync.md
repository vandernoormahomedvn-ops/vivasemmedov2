---
description: Verifica se o ambiente local, CLI e projeto Cloud estão sincronizados para evitar erros de permissão.
---

Este workflow garante que a aplicação não está a apontar para um projeto Firebase enquanto o CLI está a apontar para outro.

// turbo-all
1. Verificar o Projeto Ativo no CLI:
   `firebase_get_environment`
2. Identificar o Projeto no Código da App (iOS):
   `view_file /Users/vanderdfsnoormahomed/Downloads/Flexpress/flexpress_rider/ios/Runner/GoogleService-Info.plist`
3. Identificar o Projeto no Código da App (Android):
   `view_file /Users/vanderdfsnoormahomed/Downloads/Flexpress/flexpress_rider/android/app/google-services.json`
4. Comparar os IDs:
   - Se o `active_project` no CLI for diferente do `PROJECT_ID` nos ficheiros `.plist` ou `.json`, o ambiente está DESALINHADO.
5. Corrigir o Alinhamento (se necessário):
   - Executar `firebase use <PROJECT_ID_DA_APP>` para alinhar o CLI com o código.
6. Validar Regras de Segurança:
   - Executar `firebase_get_security_rules` para confirmar se as regras na Cloud correspondem às locais.
7. Alerta de Segurança:
   - Se houver desalinhamento, NÃO fazer deploy de regras até corrigir o `firebase use`.
