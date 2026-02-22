import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:nova_post/models/Parcel.model.dart';
import 'package:nova_post/models/ParcelTrackResult.model.dart';
import 'package:nova_post/models/Trace.model.dart';
import 'package:nova_post/repositories/Parcel.repo.dart';
import 'package:nova_post/repositories/User.repo.dart';
import 'package:nova_post/services/Firebase.auth.service.dart';
import 'package:nova_post/services/Firebase.database.service.dart';
import 'package:nova_post/test/test.dart';
import 'package:nova_post/widgets/Logo_head.dart';
import 'package:nova_post/widgets/ParcelItemWidget.dart';

class ParcelListPage extends StatefulWidget {
  const ParcelListPage({super.key});

  @override
  State<ParcelListPage> createState() => _ParcelListPageState();
}

class _ParcelListPageState extends State<ParcelListPage> {
  final _codeController = TextEditingController();
  final dbService = FirebaseDbService();
  final auth = FirebaseAuth.instance;
  final FirebaseAuthService authService = FirebaseAuthService();
  List<Parcel> parcelsList = [];
  late ParcelRepository repository = ParcelRepository(dbService, auth);
  ParcelTrackResult? result;
  bool searchMode = false;
  bool loading = false;
  List<Trace> traces = [];
  String? error;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    //createTestData();
    fetchData();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    // користувач доскролив донизу
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _refreshPage();
    }
  }

  Future<void> fetchData() async {
    final user = auth.currentUser;
    if (user != null) {
      final list = await dbService.getParcelsByUser(user.uid);
      setState(() {
        parcelsList = list;
      });
    }
  }

  Future<void> _refreshPage() async {
    print('🔄 Refresh page');
    await fetchData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> checkAuthUser() async {
    final user = auth.currentUser;
    if (user != null) {
      final userData = await dbService.getUser(user.uid);
      if (userData != null) {
        final list = await dbService.getParcelsByUser(user.uid);
        print('Parcels for user ${user.uid}: ${list.length}');
        setState(() {
          parcelsList = list;
        });
      }
    } else {
      print('No authenticated user found, redirecting to login');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void searchParcel(int code) {
    Navigator.pushNamed(context, '/parcelTrack', arguments: code.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF1a1d1f),
        appBar: LogoHead(null),
        drawer: Drawer(
          backgroundColor: Color(0xFF1a1d1f),
          child: ListView(
            children: [
              Container(
                  color: Color(0xFFFF8C0F),
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () async {
                      await authService.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  )),
            ],
          ),
        ),
        body: Container(
            color: Color(0xFF1a1d1f),
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: ListView(controller: _scrollController, children: [
                    SizedBox(
                      height: 5,
                    ),
                    Text("All parcels for current user:",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 5,
                    ),
                    ...parcelsList.map((p) => ParcelItemWidget(
                          parcel: p,
                          onSearchPressed: () => searchParcel(p.number),
                        ))
                  ]),
                ))));
  }
}
