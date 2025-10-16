class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}