import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import 'user_repository.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    UserRepository? userRepository,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // Create user document in Firestore via UserRepository
      final userModel = UserModel(
        id: user.uid,
        email: email,
        displayName: name,
        phoneNumber: phone,
        statusUsuario: 'Ativo', // Default status
        createdTime: DateTime.now(),
      );
      await _userRepository.createUser(userModel);
    }
    
    return userCredential;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
