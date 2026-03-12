---
description: Audita e automatiza a migração de componentes UI para utilizar o padrão Repository em vez de chamadas diretas ao Firestore.
---

# Workflow: Migrate Repositories 🏗️

This workflow is designed to automate the process of finding and replacing direct `FirebaseFirestore.instance` calls inside UI components with their respective Repository pattern equivalents in the Flexpress apps.

## Passos para Migração

// turbo
1. Executar uma busca para encontrar todas as chamadas diretas na camada de apresentação (UI):
```bash
grep -rn "FirebaseFirestore.instance" lib/features/**/screens/
```

2. Analisar os resultados. Para cada chamada direta identificada:
   - Identificar qual o Repositório correspondente (`UserRepository`, `RiderRepository`, `DeliveryRepository`, `WalletRepository`, etc.).
   - Se a operação exigida não existir no Repositório, adicionar a função/Stream lá primeiro retornando Modelos Tipificados.
   - Refatorar a classe UI (`StatefulWidget` / `StatelessWidget`) para chamar a função do Repositório.

3. Substituir dados brutos como `DocumentSnapshot` e `QuerySnapshot` utilizados em `StreamBuilder` e `FutureBuilder` para consumirem listas tipadas ou objetos `Model?`.

4. Identificar e remover quaisquer importações não utilizadas de `package:cloud_firestore/cloud_firestore.dart` nos arquivos refatorados.

// turbo
5. Validar o código após a refatoração:
```bash
flutter analyze
flutter format .
```

6. Confirmar se a funcionalidade permanece idêntica executando testes locais na aplicação.
