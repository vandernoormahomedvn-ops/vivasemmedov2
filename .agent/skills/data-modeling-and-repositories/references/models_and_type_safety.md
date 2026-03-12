# Models and Type-Safety

All data structures in Flexpress apps MUST be defined as strict Dart classes (Data Models) to ensure type-safety and avoid runtime errors associated with raw `Map<String, dynamic>`.

## Rules for Data Models

1. **Schema alignment:** The properties of a Dart model must strictly mirror the fields defined in the `firebase_schema.md` artifact.
2. **Immutability:** Use `final` for all properties.
3. **Serialization:** Every model MUST implement `fromFirestore` (factory) and `toFirestore` (method) to serialize and deserialize data from/to Cloud Firestore.
4. **Default values:** Provide sensible defaults or use nullable types `?` for fields that might be missing in older documents, to prevent parsing crashes.
5. **No direct Maps in UI:** UI components (Screens, Widgets) MUST NEVER accept or consume `Map<String, dynamic>`. They must always use the defined Data Models.

## Typical Model Structure Example
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final num totalOrders;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.totalOrders,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      totalOrders: data['total_orders'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'total_orders': totalOrders,
    };
  }
}
```
