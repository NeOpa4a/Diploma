import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithPhone({
    required String phone,
    required Function(String verificationId) codeSent,
    required Function(FirebaseAuthException e) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onError,
      codeSent: (verificationId, _) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  User? get currentUser => _auth.currentUser;

  Future<void> logout() => _auth.signOut();
}
