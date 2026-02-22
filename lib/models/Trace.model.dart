import 'package:nova_post/models/Location.model.dart';

class Trace {
  final String id;
  final String status;
  final String driverId;
  final String parcelId;
  final String description;
  final Location currentLocation;
  final DateTime timestamp;

  Trace({
    required this.id,
    required this.status,
    required this.driverId,
    required this.parcelId,
    required this.description,
    required this.currentLocation,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'status': status,
        'driverId': driverId,
        'parcelId': parcelId,
        'description': description,
        'currentLocation': currentLocation.toMap(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory Trace.fromMap(Map<String, dynamic> map, String id) {
    return Trace(
      id: id,
      status: map['status'],
      driverId: map['driverId'],
      parcelId: map['parcelId'],
      description: map['description'],
      currentLocation: Location.fromMap(map['currentLocation']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
