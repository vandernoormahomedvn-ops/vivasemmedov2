import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<UserModel> get usersCollection =>
      _firestore.collection('users').withConverter<UserModel>(
            fromFirestore: (snapshot, _) =>
                UserModel.fromFirestore(snapshot),
            toFirestore: (model, _) => model.toFirestore(),
          );

  Future<void> createUser(UserModel user) async {
    try {
      await usersCollection.doc(user.id).set(user);
    } on FirebaseException catch (e) {
      throw Exception('Failed to create user: ${e.message}');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final snapshot = await usersCollection.doc(uid).get();
      return snapshot.data();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch user: ${e.message}');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await usersCollection.doc(user.id).update(user.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Failed to update user: ${e.message}');
    }
  }
}
