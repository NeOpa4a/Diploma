import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nova_post/repositories/User.repo.dart';
import 'package:nova_post/services/Firebase.auth.service.dart';
import 'package:nova_post/services/Firebase.database.service.dart';
import 'package:nova_post/widgets/Logo_head.dart';
import 'package:nova_post/widgets/Phone_field_widget.dart';
import 'package:nova_post/widgets/SmsCodeInput.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userRepository = UserRepository(
    FirebaseAuthService(),
    FirebaseDbService(),
  );
  String _phone = '';
  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;
  final logo_provider = AssetImage('images/go_box.jpg');

  Future<void> _sendCode() async {
    setState(() => _loading = true);
    if (_phone.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid phone number ${_phone}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _loading = false);
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: _phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        _onLoginSuccess();
      },
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid phone number',
            ),
            backgroundColor: Colors.red,
          ),
        );
      },
      codeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    setState(() => _loading = false);
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null) return;

    final code = _codeController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid 6-digit code',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      print('✅ Login successful: ${userCredential.user!.uid}');
      _onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String message = 'Login failed. Try again.';

      if (e.code == 'invalid-verification-code') {
        message = 'Invalid SMS code. Please try again.';
      } else if (e.code == 'session-expired') {
        message = 'Code expired. Please request a new one.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Try later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('❌ FirebaseAuth error: ${e.code} — ${e.message}');
    } catch (e) {
      setState(() => _loading = false);

      debugPrint('❌ Unknown error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onLoginSuccess() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Login Successful!'), backgroundColor: Colors.green),
    );

    await userRepository.createUserIfNotExists();
    Navigator.pushReplacementNamed(context, '/parcelList');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: LogoHead(null),
        body: Container(
          color: Color(0xFF1a1d1f),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
            ),
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("WELCOME TO",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 5,
                    ),
                    Text("GO BOX",
                        style: TextStyle(
                            color: Color(0xFFFF8C0F),
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                PhoneInputWidget(
                  onChanged: (phone) {
                    setState(() {
                      _phone = phone;
                    });
                    print(_phone);
                  },
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 16),
                  SmsCodeInput(
                    onChanged: (code) {
                      _codeController.text = code;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFFFF8C0F))),
                    onPressed: _loading
                        ? null
                        : _codeSent
                            ? _verifyCode
                            : _sendCode,
                    child: _loading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ))
                        : Text(_codeSent ? 'Verify code' : 'Send code',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0)))),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "or",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                    child: Text(
                      "Continue as a guest",
                      style: TextStyle(
                          color: Color(0xFFFF8C0F),
                          decoration: TextDecoration.underline),
                    ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFF1a1d1f))),
                    onPressed: () {
                      Navigator.pushNamed(context, '/parcelTrack');
                      // Navigator.pushReplacement(...)
                    })
              ],
            ),
          ),
        ));
  }
}
