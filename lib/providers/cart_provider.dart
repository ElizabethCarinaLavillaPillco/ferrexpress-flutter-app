// providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/ferreteria.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Ferreteria? _selectedFerreteria;

  Map<String, CartItem> get items => {..._items};
  Ferreteria? get selectedFerreteria => _selectedFerreteria;
  
  int get itemCount => _items.length;
  
  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee => _selectedFerreteria?.deliveryFee ?? 0.0;
  
  double get total => subtotal + deliveryFee;

  void setFerreteria(Ferreteria ferreteria) {
    if (_selectedFerreteria?.id != ferreteria.id) {
      _items.clear();
    }
    _selectedFerreteria = ferreteria;
    notifyListeners();
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
    } else if (_items.containsKey(productId)) {
      _items[productId]!.quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _selectedFerreteria = null;
    notifyListeners();
  }
}
