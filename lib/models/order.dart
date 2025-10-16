
// models/order.dart
class Order {
  final String id;
  final String userId;
  final String ferreteriaId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;

  Order({
    required this.id,
    required this.userId,
    required this.ferreteriaId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.estimatedDeliveryTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'ferreteriaId': ferreteriaId,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'paymentMethod': paymentMethod,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      ferreteriaId: map['ferreteriaId'],
      items: [], // Se cargan por separado
      subtotal: map['subtotal'],
      deliveryFee: map['deliveryFee'],
      total: map['total'],
      deliveryAddress: map['deliveryAddress'],
      deliveryLatitude: map['deliveryLatitude'],
      deliveryLongitude: map['deliveryLongitude'],
      paymentMethod: map['paymentMethod'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      estimatedDeliveryTime: map['estimatedDeliveryTime'] != null
          ? DateTime.parse(map['estimatedDeliveryTime'])
          : null,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'],
      unit: map['unit'],
    );
  }
}

enum OrderStatus {
  pending, // Pedido confirmado
  preparing, // Ferretería preparando
  readyForPickup, // Listo para recoger
  inTransit, // En camino
  delivered, // Entregado
  cancelled, // Cancelado
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pedido Confirmado';
      case OrderStatus.preparing:
        return 'Preparando Pedido';
      case OrderStatus.readyForPickup:
        return 'Listo para Recoger';
      case OrderStatus.inTransit:
        return 'En Camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Tu pedido ha sido confirmado';
      case OrderStatus.preparing:
        return 'La ferretería está preparando tu pedido';
      case OrderStatus.readyForPickup:
        return 'El repartidor recogerá tu pedido pronto';
      case OrderStatus.inTransit:
        return 'Tu pedido está en camino';
      case OrderStatus.delivered:
        return 'Tu pedido ha sido entregado';
      case OrderStatus.cancelled:
        return 'El pedido fue cancelado';
    }
  }
}
