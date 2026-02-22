import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nova_post/models/Location.model.dart';
import 'package:nova_post/models/Parcel.model.dart';
import 'package:nova_post/models/Trace.model.dart';
import '../models/User.model.dart';

class FirebaseDbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(User user) {
    return _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<User?> getUser(String? uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return User.fromJson(doc.data()!);
  }

  Future<void> updateUser(User user) {
    return _db.collection('users').doc(user.id).update(user.toJson());
  }

  // Parcels
  Future<void> createParcel(Parcel parcel) {
    return _db.collection('parcels').doc(parcel.id).set(parcel.toMap());
  }

  Future<Parcel?> getParcel(String id) async {
    final doc = await _db.collection('parcels').doc(id).get();
    if (!doc.exists) return null;
    return Parcel.fromMap(doc.data()!, doc.id);
  }

  Future<List<Parcel>> getParcelsByUser(String userId) async {
    final snapshot = await _db
        .collection('parcels')
        .where('senderId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((d) => Parcel.fromMap(d.data(), d.id)).toList();
  }

  // Traces
  Future<void> createTrace(Trace trace) {
    return _db.collection('traces').doc(trace.id).set(trace.toMap());
  }

  Future<void> updateTraceLocation(
    String traceId,
    Location location,
  ) {
    return _db.collection('traces').doc(traceId).update({
      'currentLocation': location.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<Parcel?> getParcelById(String parcelId) async {
    final doc = await _db.collection('parcels').doc(parcelId).get();
    if (!doc.exists) return null;
    return Parcel.fromMap(doc.data()!, doc.id);
  }

  Future<Parcel?> getParcelByNumber(String parcelNumberStr) async {
    final parcelNumber = int.tryParse(parcelNumberStr);
    if (parcelNumber == null) return null;

    final snapshot = await _db
        .collection('parcels')
        .where('number', isEqualTo: parcelNumber)
        .limit(1)
        .get();

    print('snapshot docs count: ${snapshot.docs.length}');
    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return Parcel.fromMap(doc.data(), doc.id);
  }

  Future<List<Trace>> getTracesForParcel(String parcelId) async {
    final snapshot = await _db
        .collection('traces')
        .where('parcelId', isEqualTo: parcelId)
        // .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((d) => Trace.fromMap(d.data(), d.id)).toList();
  }
}
