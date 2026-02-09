import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential?> login({
    required String email,
    required String password,
  });

  Future<UserCredential?> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();

  User? get currentUser;

  Stream<User?> get authStateChanges;
}
