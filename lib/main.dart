import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nova_post/pages/parcel_list_page.dart';
import 'package:nova_post/pages/parcel_track_page.dart';
import 'package:nova_post/pages/phone_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const PhoneLoginPage(),
        '/parcelTrack': (context) => const ParcelTrackPage(),
        '/parcelList': (context) => const ParcelListPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PhoneLoginPage(),
    );
  }
}
