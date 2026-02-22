class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() => {
        'lat': latitude,
        'lng': longitude,
      };

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['lat'],
      longitude: map['lng'],
    );
  }
}
