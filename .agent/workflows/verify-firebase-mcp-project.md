---
description: Verifica e corrige o projeto Firebase ativo no MCP antes de qualquer operação, evitando queries e operações no projeto errado.
---

# Verify Firebase MCP Project

## Problema
O Firebase MCP server persiste o projeto ativo entre conversas e workspaces. Ao trocar de projeto (ex: de Flexpress para Yentelelo), o MCP pode continuar apontando para o projeto anterior, causando:
- Queries Firestore retornando dados vazios ou do projeto errado
- Operações (create/update/delete) executadas no projeto errado
- Debugging desnecessário por dados "inexistentes"

## Workflow

// turbo-all

### 1. Verificar ambiente atual
```
Use: mcp_firebase-mcp-server_firebase_get_environment
```
Verifique se:
- `Active Project ID` corresponde ao projeto do workspace atual
- `Project Directory` aponta para o diretório correto

### 2. Identificar o projeto correto
Procure o `projectId` no código do app:
```
grep_search: "projectId" em lib/backend/firebase/firebase_config.dart
```
Ou em `firebase_options.dart`, `google-services.json`, ou `GoogleService-Info.plist`.

**Projetos Conhecidos:**

| Workspace | Project ID |
|-----------|-----------|
| Yentelelo | `yentelelo-el9qvy` |
| Flexpress Delivery | `flexpress-delivery-pro` |

### 3. Corrigir se necessário
```
Use: mcp_firebase-mcp-server_firebase_update_environment
  - active_project: <projectId correto>
  - project_dir: <diretório do workspace atual>
```

### 4. Confirmar
```
Use: mcp_firebase-mcp-server_firebase_get_environment
```
Valide que agora `Active Project ID` está correto.

## Quando usar
- **SEMPRE** antes da primeira operação Firestore/Auth/Storage via MCP em qualquer conversa
- Ao trocar de workspace/projeto na mesma sessão
- Quando queries Firestore retornam resultados inesperados (vazios ou dados errados)
- Após cada hot restart ou nova sessão de debugging que envolva dados do Firestore

## Checklist de Troubleshooting de Dados

Se após verificar o projeto correto os dados ainda estiverem vazios:

1. **Verifique a estrutura da coleção**: dados podem estar em subcoleções (`playlists/{id}/videos`) e não na coleção top-level (`videos`).
2. **Verifique os campos de ordenação**: `orderBy('views')` retorna vazio se muitos docs NÃO têm o campo `views`.
3. **Alternativa a `collectionGroup`**: itere a coleção pai e busque subcoleções individualmente para evitar problemas de regras.
4. **Verifique se a lógica existe em TODAS as telas**: uma feature (ex: incrementar `views`) pode existir no Player mas não na tela de Detalhes.
