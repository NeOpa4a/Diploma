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

class ParcelTrackPage extends StatefulWidget {
  const ParcelTrackPage({super.key, this.parcelNumber});

  final String? parcelNumber;

  @override
  State<ParcelTrackPage> createState() => _ParcelTrackPageState();
}

class _ParcelTrackPageState extends State<ParcelTrackPage> {
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
  bool initArcs = true;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    fetchData();

    // _searchParcel();
    //_scrollController.addListener(_onScroll);
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

  Future<String> getUserName(String? uid) async {
    if (uid == null) return 'Unknown';

    try {
      final user = await dbService.getUser(uid);
      return user?.name ?? 'Unknown';
    } catch (e) {
      print('Error fetching user: $e');
      return 'Unknown';
    }
  }

  Future<void> _searchParcel() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await repository.trackParcel(
      _codeController.text.trim(),
    );

    if (res == null) {
      error = 'Parcel not found';
      result = null;
    } else {
      result = res;
      final localTraces = res.traces
        ..sort((b, a) => b.timestamp.compareTo(a.timestamp));
      setState(() {
        traces = localTraces;
      });
    }

    setState(() => loading = false);
    setState(() => searchMode = true);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (initArcs) {
      _codeController.text =
          (args != null && args is String) ? args : widget.parcelNumber ?? '';
      initArcs = false;
    }

    return Scaffold(
        backgroundColor: Color(0xFF1a1d1f),
        appBar: LogoHead(context),
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
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Parcel number',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xFFFF8C0F))),
                                onPressed: _searchParcel,
                                child: Icon(Icons.search, color: Colors.black)),
                          ],
                        )),
                    if (result != null) ...[
                      // -------------------------------
                      // Повна інформація про посилку (тільки якщо canViewFullInfo)
                      // -------------------------------
                      if (result?.canViewFullInfo == true &&
                          result?.parcel != null) ...[
                        Text('Parcel Number: ${result?.parcel!.number}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('Description: ${result?.parcel!.description}',
                            style: TextStyle(color: Colors.white70)),
                        Text('Weight: ${result?.parcel!.weight} kg',
                            style: TextStyle(color: Colors.white70)),
                        Text(
                          result?.parcel?.paid == true ? "Paid" : "Not paid",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        // Text(
                        //     'From: Lat ${result?.parcel!.startLocation.latitude}, Lng ${result?.parcel!.startLocation.longitude}',
                        //     style: TextStyle(color: Colors.white70)),
                        // Text(
                        //     'To: Lat ${result?.parcel!.destination.latitude}, Lng ${result?.parcel!.destination.longitude}',
                        //     style: TextStyle(color: Colors.white70)),
                        FutureBuilder<String>(
                          future: getUserName(result?.parcel?.senderId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Loading sender...',
                                  style: TextStyle(color: Colors.white70));
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return Text('Sender: Unknown',
                                  style: TextStyle(color: Colors.white70));
                            }
                            return Text('Sender: ${snapshot.data}',
                                style: TextStyle(color: Colors.white70));
                          },
                        ),
                        FutureBuilder<String>(
                          future: getUserName(result?.parcel?.receiverId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Loading receiver...',
                                  style: TextStyle(color: Colors.white70));
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return Text('Receiver: Unknown',
                                  style: TextStyle(color: Colors.white70));
                            }
                            return Text('Receiver: ${snapshot.data}',
                                style: TextStyle(color: Colors.white70));
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // -------------------------------
                      // Trace історія (для всіх користувачів)
                      // -------------------------------
                      Text('Tracking history',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      ...traces.map((t) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFFFF8C0F), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Card(
                                color: Colors.grey[900],
                                borderOnForeground: true,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(t.status,
                                      style: TextStyle(color: Colors.white)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (result?.canViewFullInfo == true) ...[
                                        FutureBuilder<String>(
                                          future: getUserName(t.driverId),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text('Loading driver...',
                                                  style: TextStyle(
                                                      color: Colors.white70));
                                            }
                                            if (snapshot.hasError ||
                                                snapshot.data == null) {
                                              return Text('Driver: Unknown',
                                                  style: TextStyle(
                                                      color: Colors.white70));
                                            }
                                            return Text(
                                                'Driver: ${snapshot.data}',
                                                style: TextStyle(
                                                    color: Colors.white70));
                                          },
                                        ),
                                        Text('Description: ${t.description}',
                                            style: TextStyle(
                                                color: Colors.white70)),
                                        // Text(
                                        //     'Location: Lat ${t.currentLocation.latitude}, Lng ${t.currentLocation.longitude}',
                                        //     style: TextStyle(
                                        //         color: Colors.white70)),
                                      ],
                                      Text(
                                          'Timestamp: ${DateFormat('dd MMM yyyy, HH:mm').format(t.timestamp).toString()}',
                                          style:
                                              TextStyle(color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                    ] else if (error != null && result == null) ...[
                      Text(error ?? 'No results found',
                          style: TextStyle(color: Colors.red)),
                    ],
                    SizedBox(
                      height: 5,
                    ),
                  ]),
                ))));
  }
}
