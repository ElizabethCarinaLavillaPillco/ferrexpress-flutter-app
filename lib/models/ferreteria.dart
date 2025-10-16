
// models/ferreteria.dart
class Ferreteria {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String? image;
  final double rating;
  final int reviewCount;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final double deliveryFee;
  final int estimatedDeliveryTime; // en minutos

  Ferreteria({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.image,
    required this.rating,
    required this.reviewCount,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    required this.deliveryFee,
    required this.estimatedDeliveryTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen ? 1 : 0,
      'deliveryFee': deliveryFee,
      'estimatedDeliveryTime': estimatedDeliveryTime,
    };
  }

  factory Ferreteria.fromMap(Map<String, dynamic> map) {
    return Ferreteria(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      phone: map['phone'],
      image: map['image'],
      rating: map['rating'],
      reviewCount: map['reviewCount'],
      openTime: map['openTime'],
      closeTime: map['closeTime'],
      isOpen: map['isOpen'] == 1,
      deliveryFee: map['deliveryFee'],
      estimatedDeliveryTime: map['estimatedDeliveryTime'],
    );
  }

  double distanceFrom(double lat, double lon) {
    // Fórmula de Haversine simplificada
    const double earthRadius = 6371; // km
    double dLat = _toRadians(latitude - lat);
    double dLon = _toRadians(longitude - lon);
    
    double a = (dLat / 2).abs() * (dLat / 2).abs() +
        _toRadians(lat).abs() * _toRadians(latitude).abs() *
        (dLon / 2).abs() * (dLon / 2).abs();
    
    double c = 2 * (a.abs() < 1 ? a.abs() : 1);
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * 3.141592653589793 / 180;
  }
}
