
// models/product.dart
class Product {
  final String id;
  final String ferreteriaId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? image;
  final bool inStock;
  final int stockQuantity;
  final String unit; // unidad, caja, metro, etc.

  Product({
    required this.id,
    required this.ferreteriaId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.image,
    required this.inStock,
    required this.stockQuantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ferreteriaId': ferreteriaId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'inStock': inStock ? 1 : 0,
      'stockQuantity': stockQuantity,
      'unit': unit,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      ferreteriaId: map['ferreteriaId'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      category: map['category'],
      image: map['image'],
      inStock: map['inStock'] == 1,
      stockQuantity: map['stockQuantity'],
      unit: map['unit'],
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
}



