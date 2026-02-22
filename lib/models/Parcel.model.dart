import 'package:nova_post/models/Location.model.dart';

class Parcel {
  final String id;
  final int number;
  final String description;
  final double weight;
  final Location destination;
  final Location startLocation;
  final String senderId;
  final String receiverId;

  Parcel({
    required this.id,
    required this.number,
    required this.description,
    required this.weight,
    required this.destination,
    required this.startLocation,
    required this.senderId,
    required this.receiverId,
  });

  Map<String, dynamic> toMap() => {
        'number': number,
        'description': description,
        'weight': weight,
        'destination': destination.toMap(),
        'startLocation': startLocation.toMap(),
        'senderId': senderId,
        'receiverId': receiverId,
      };

  factory Parcel.fromMap(Map<String, dynamic> map, String id) {
    return Parcel(
      id: id,
      number: map['number'],
      description: map['description'],
      weight: map['weight'].toDouble(),
      destination: Location.fromMap(map['destination']),
      startLocation: Location.fromMap(map['startLocation']),
      senderId: map['senderId'],
      receiverId: map['receiverId'],
    );
  }
}
