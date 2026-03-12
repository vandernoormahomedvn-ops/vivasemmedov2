---
name: repository-migration
description: Guia e standard de desenvolvimento para isolamento de lógica de dados e acesso ao banco de dados utilizando Data Models e Repositories nas apps Flexpress.
---

# Skill: Repository Migration 🏗️

Esta skill define os padrões e procedimentos obrigatórios quando implementar ou refatorar o acesso à camada de dados (Cloud Firestore). O objetivo é isolar a UI da implementação de Base de Dados e garantir consistência e Type-Safety em toda a aplicação Flexpress.

## O Problema (Anti-Pattern) ❌

A UI **nunca** deve interagir diretamente com o Firestore.
Evite usar isto em Widgets:
```dart
FirebaseFirestore.instance.collection('deliveries').doc(id).snapshots()
// ou
await FirebaseFirestore.instance.collection('riders').update({'status': 'offline'})
```
Isto leva a código não-testável, tipagem solta (`Map<String, dynamic>`), replicação constante do parsing do Firestore e vulnerabilidade a erros de escrita.

## O Padrão a Seguir (Best Practice) ✅

Toda a lógica de acesso e escrita de dados pertence a um **Repository**.
Toda a representação de dados viaja sob a forma de um **Model** tipado.

### 1. Modelos Tipados (`fromFirestore` e `toFirestore`)

```dart
class UserModel {
  final String id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}
```

### 2. Repositórios (`withConverter`)

Utilize o método nativo `.withConverter<T>()` dentro dos repositórios para abstrair toda a camada de parse:

```dart
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<UserModel> get _usersRef => _firestore
      .collection('users')
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
        toFirestore: (model, _) => model.toFirestore(),
      );

  Stream<UserModel?> streamProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) => snapshot.data());
  }
}
```

### 3. Chamadas na UI Limpas

Injete, instancie ou providencie o repositório e consuma apenas Standard Data Types.

```dart
StreamBuilder<UserModel?>(
  stream: UserRepository().streamProfile(uid),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final user = snapshot.data!;
      return Text(user.name);
    }
  }
)
```

## Diretrizes e Verificações 🛡️

Quando instruído a utilizar esta skill ou após criar ou refatorar componentes:

- ✓ **Sem Maps Crus:** Garanta que a UI nunca interage com um objeto do tipo `Map<String, dynamic>`.
- ✓ **Remoção Segura de Imports Firebase:** Nenhum ficheiro da UI (em `screens/`, `widgets/`) deve ter `import 'package:cloud_firestore/cloud_firestore.dart';` a não ser casos de extrema necessidade de `Timestamp` (que não devem existir na UI em rigor).
- ✓ **Lógica em Funções Cloud:** Para transações pesadas ou financeiras que toquem coleções sensíveis (ex: `wallet`), o *Repository* não deve escrever diretamente se houver lógica interligada; deve delegar o side-effect a uma *Cloud Function*, e o Repository (ou mesmo a Cloud Function em trigger) deve tratar das nuances de segurança. O Repository apenas lê ou engatilha um status da entrega, o que dispara as lógicas críticas.
