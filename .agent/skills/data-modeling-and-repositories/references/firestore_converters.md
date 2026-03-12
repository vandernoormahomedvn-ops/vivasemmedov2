# Firestore Converters

To consume Data Models directly from Firebase streams and futures, you MUST always use `.withConverter()`.

## Rules for Firestore Queries

1. **Avoid manual mapping:** Do not map `QuerySnapshot<Map<String, dynamic>>` manually inside `StreamBuilder` or repository methods. Use `.withConverter()` directly on the collection reference.
2. **Type-safe UI:** This ensures that `StreamBuilder` and `FutureBuilder` provide your UI with `DocumentSnapshot<YourModel>` or `QuerySnapshot<YourModel>`.

## Example: Using `.withConverter()`

```dart
Stream<QuerySnapshot<UserModel>> getUsersStream() {
  return FirebaseFirestore.instance
      .collection('users')
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
        toFirestore: (model, _) => model.toFirestore(),
      )
      .snapshots();
}
```

```dart
// Fetching a single document
Stream<DocumentSnapshot<UserModel>> getUserProfile(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
        toFirestore: (model, _) => model.toFirestore(),
      )
      .snapshots();
}
```
