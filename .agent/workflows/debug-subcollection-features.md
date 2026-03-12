---
description: Workflow para debugar problemas em funcionalidades que usam subcoleções do Firestore (comentários, playlists, cursos, etc). Identifica path mismatches, field name errors, e discrepancies entre leitura e escrita.
---

# Debug Subcollection Features

// turbo-all

## Quando Usar
Use este workflow quando:
- Uma feature que grava/lê dados de subcoleções do Firestore não funciona
- Dados são gravados mas não aparecem na UI
- Comentários, likes, ou outras interações não persistem

## Passos

### 1. Identificar a Subcoleção e os Ficheiros Envolvidos
```bash
# Encontrar todos os ficheiros que referenciam a subcoleção
grep -rn "collection('NOME_DA_SUBCOLECAO')" lib/ --include="*.dart"
```
Anotar **todos** os ficheiros que fazem read (StreamBuilder/FutureBuilder) e write (.set/.add/.update).

### 2. Verificar Consistência de Paths (READ vs WRITE)
Para cada ficheiro, comparar:
- **READ path**: Verificar o que o `StreamBuilder` / `FutureBuilder` está a usar. Exemplo: `CommentsRecord.collection(currentVideo.reference)` → lê de `{video_path}/comments`
- **WRITE path**: Verificar o que o handler de submit usa. Exemplo: `FirebaseFirestore.instance.collection('videos').doc(id).collection('comments')` → escreve em `videos/{id}/comments`

**🐛 Bug Comum**: Paths hardcoded vs. paths dinâmicos. Se o vídeo está numa subcoleção (ex: `playlists/{id}/videos/{videoId}`), um path hardcoded `videos/{videoId}` não aponta para o mesmo documento.

**✅ Fix**: Sempre usar `parentDocument.reference.collection('subcolecao')` em vez de construir o path manualmente.

### 3. Verificar Nomes de Campos
Comparar os nomes dos campos no:
- **Modelo Dart** (`_initializeFields()`) — ex: `snapshotData['createdAt']`
- **Queries** (`.orderBy('field')`) — ex: `.orderBy('created_time')` ← MISMATCH!
- **createXRecordData()** — campos usados ao criar documentos

**🐛 Bug Comum**: `created_time` vs `createdAt`, `user_ref` vs `userRef`, snake_case vs camelCase.

### 4. Verificar Resolução de Referências
Verificar se `DocumentReference` fields (ex: `userRef`) são resolvidos na UI:
- ❌ Hardcoded: `Text('Utilizador')` ← nunca mostra o nome real
- ✅ Correto: `FutureBuilder<DocumentSnapshot>(future: comment.userRef?.get(), ...)`

### 5. Verificar no Firebase MCP
```
# Query a subcoleção para ver se os dados existem
mcp_firebase: firestore_query_collection → collection_path: "parent_collection"
```
Verificar se os documentos estão no path esperado.

### 6. Verificar Streams Duplicados
Procurar `StreamBuilder` duplicados para a mesma coleção — cada um addiciona um listener Firestore separado, dobrando custos.

### 7. Testar e Validar
```bash
# Analisar erros
dart analyze lib/path/to/modified_files
```
Hot restart ou relaunch da app para testar.

## Checklist Rápida
- [ ] READ path == WRITE path (usar `.reference.collection()`)
- [ ] Nomes de campos consistentes (modelo == query == create)
- [ ] Referências de user resolvidas com FutureBuilder
- [ ] Sem StreamBuilders duplicados para a mesma coleção
- [ ] `dart analyze` sem erros
