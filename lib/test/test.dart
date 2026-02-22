import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nova_post/models/Location.model.dart';
import 'package:nova_post/models/Parcel.model.dart';
import 'package:nova_post/models/Trace.model.dart';

final _db = FirebaseFirestore.instance;

Future<void> createTestData() async {
  final random = Random();

  // Юзер 1 - вже існуючий
  final existingUserId = '4qlYSP8plUgP2NALk063d5tKTmo2';

  // Юзер 2 - новий
  final user2Id = _db.collection('users').doc().id;
  await _db.collection('users').doc(user2Id).set({
    'phone': '+380992223344',
  });

  // Створюємо тестову посилку
  final parcelId = _db.collection('parcels').doc().id;
  final parcel = Parcel(
    id: parcelId,
    number: 10001,
    description: 'Test parcel to DB',
    weight: 2.5,
    destination: Location(
      latitude: 50.4501 + random.nextDouble() / 10,
      longitude: 30.5234 + random.nextDouble() / 10,
    ),
    startLocation: Location(
      latitude: 50.4501,
      longitude: 30.5234,
    ),
    senderId: existingUserId,
    receiverId: user2Id,
  );

  await _db.collection('parcels').doc(parcelId).set(parcel.toMap());

  // Створюємо кілька Trace для посилки
  final statuses = ['Created', 'Picked up', 'In transit', 'Delivered'];

  for (int i = 0; i < statuses.length; i++) {
    final traceId = _db.collection('traces').doc().id;
    final trace = Trace(
      id: traceId,
      status: statuses[i],
      driverId: i % 2 == 0 ? existingUserId : user2Id,
      parcelId: parcelId,
      description: 'Status update: ${statuses[i]}',
      currentLocation: Location(
        latitude: 50.4501 + random.nextDouble() / 10,
        longitude: 30.5234 + random.nextDouble() / 10,
      ),
      timestamp:
          DateTime.now().subtract(Duration(hours: (statuses.length - i) * 5)),
    );

    await _db.collection('traces').doc(traceId).set(trace.toMap());
  }

  print('✅ Test parcel and traces created successfully!');
}
