// repositories/user_repository.dart

import 'package:nova_post/models/User.model.dart';
import 'package:nova_post/services/Firebase.auth.service.dart';
import 'package:nova_post/services/Firebase.database.service.dart';

class UserRepository {
  final FirebaseAuthService _authService;
  final FirebaseDbService _dbService;

  UserRepository(this._authService, this._dbService);

  Future<User> createUserIfNotExists() async {
    final firebaseUser = _authService.currentUser!;
    final existingUser = await _dbService.getUser(firebaseUser.uid);

    if (existingUser != null) return existingUser;

    final newUser = User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'New User',
      phoneNumber: firebaseUser.phoneNumber!,
      createdAt: DateTime.now(),
    );

    await _dbService.createUser(newUser);
    return newUser;
  }
}
