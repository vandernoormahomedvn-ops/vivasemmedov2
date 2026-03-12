# Repository Pattern

Abstract data access logic (Firestore, external APIs) from the UI components by placing it in Repositories.

## Architecture Guidelines

1. **Location:** Repositories should live inside the feature directory, typically in `lib/features/<feature>/repositories/`.
2. **Separation of Concerns:** UI widgets should only handle display and user interaction. All data fetching, writing, and complex data combinations should happen in the Repository layer.
3. **Dependency Injection:** Provide repositories to the widget tree using `Provider` or simply pass them if the architecture is simple, but avoid instantiating Firestore instances directly in UI files if complex business logic is involved. (For simple real-time listener streams, a static method or direct `.withConverter()` call in the UI is acceptable, but consider moving complex queries to a repository).
4. **Error Handling:** Repositories should catch Firebase exceptions and throw custom app-specific exceptions or return `Result` types (if using error handling libraries) to the UI.

## Example: Repository Structure
```dart
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserStatus(String uid, String newStatus) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': newStatus,
      });
    } on FirebaseException catch (e) {
      // Handle or rethrow custom exception
      throw Exception('Failed to update status: ${e.message}');
    }
  }
}
```
