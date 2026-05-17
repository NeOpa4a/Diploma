import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nova_post/models/Location.model.dart';
import 'package:nova_post/models/Parcel.model.dart';
import 'package:nova_post/models/Trace.model.dart';

final _db = FirebaseFirestore.instance;

Future<void> createTestData() async {
  try {
    final random = Random();

    final phone1 = '+380966759845';
    final phone2 = '+380966759846';

    print('🔍 Searching users...');

    final user1Query = await _db
        .collection('users')
        .where('phone_number', isEqualTo: phone1)
        .get();

    final user2Query = await _db
        .collection('users')
        .where('phone_number', isEqualTo: phone2)
        .get();

    if (user1Query.docs.isEmpty) {
      throw Exception('User with phone $phone1 not found');
    }

    if (user2Query.docs.isEmpty) {
      throw Exception('User with phone $phone2 not found');
    }

    final user1Id = user1Query.docs.first.id;
    final user2Id = user2Query.docs.first.id;

    print('Users found: $user1Id & $user2Id');

    // 📦 Parcel
    final parcelId = _db.collection('parcels').doc().id;

    final parcel = Parcel(
      id: parcelId,
      number: 10002,
      description: 'Parcel between two real users',
      weight: 3.2,
      paid: true,
      destination: Location(
        latitude: 50.45 + random.nextDouble() / 10,
        longitude: 30.52 + random.nextDouble() / 10,
      ),
      startLocation: Location(
        latitude: 50.4501,
        longitude: 30.5234,
      ),
      senderId: user1Id,
      receiverId: user2Id,
    );

    print('Creating parcel...');
    await _db.collection('parcels').doc(parcelId).set(parcel.toMap());

    // 🚚 Traces
    final statuses = ['Created', 'Picked up', 'In transit', 'Delivered'];

    print('🚚 Creating traces...');

    for (int i = 0; i < statuses.length; i++) {
      try {
        final traceId = _db.collection('traces').doc().id;

        final trace = Trace(
          id: traceId,
          status: statuses[i],
          driverId: i % 2 == 0 ? user1Id : user2Id,
          parcelId: parcelId,
          description: 'Status update: ${statuses[i]}',
          currentLocation: Location(
            latitude: 50.45 + random.nextDouble() / 10,
            longitude: 30.52 + random.nextDouble() / 10,
          ),
          timestamp: DateTime.now()
              .subtract(Duration(hours: (statuses.length - i) * 4)),
        );

        await _db.collection('traces').doc(traceId).set(trace.toMap());

        print('   ✔ Trace created: ${statuses[i]}');
      } catch (e, stack) {
        print('Error creating trace "${statuses[i]}": $e');
        print(stack);
      }
    }

    print('SUCCESS: Parcel + traces created!');
  } catch (e, stack) {
    print('ERROR in createTestDataForTwoUsers: $e');
    print('Stack trace:\n$stack');
  }
}
