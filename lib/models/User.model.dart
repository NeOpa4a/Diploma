class User {
  String id;
  String name;
  String phoneNumber;
  DateTime createdAt;

  User(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
