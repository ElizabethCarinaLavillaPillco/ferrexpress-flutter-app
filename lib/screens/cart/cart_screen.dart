import 'package:ferrexpresss/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (cartProvider.itemCount > 0)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpiar carrito'),
                    content: const Text('¿Estás seguro de que deseas eliminar todos los productos?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartProvider.clear();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Limpiar'),
            ),
        ],
      ),
      body: cartProvider.itemCount == 0
          ? _buildEmptyCart(context)
          : Column(
              children: [
                // Ferreteria info
                if (cartProvider.selectedFerreteria != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartProvider.selectedFerreteria!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${cartProvider.selectedFerreteria!.estimatedDeliveryTime} min • S/ ${cartProvider.selectedFerreteria!.deliveryFee.toStringAsFixed(2)} delivery',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn()
                      .slideY(begin: -0.2, end: 0),
                
                // Cart items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartProvider.items.values.toList()[index];
                      return _buildCartItem(context, cartItem, cartProvider)
                          .animate()
                          .fadeIn(delay: (50 * index).ms)
                          .slideX(begin: 0.2, end: 0);
                    },
                  ),
                ),
                
                // Summary
                _buildSummary(context, cartProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade300,
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Agrega productos de tu ferretería favorita',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.store),
            label: const Text('Explorar Ferreterías'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.construction,
              color: AppColors.primary,
              size: 35,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${cartItem.product.price.toStringAsFixed(2)} / ${cartItem.product.unit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: S/ ${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity controls
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        if (cartItem.quantity < cartItem.product.stockQuantity) {
                          cartProvider.updateQuantity(
                            cartItem.product.id,
                            cartItem.quantity + 1,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Stock máximo alcanzado'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () {
                        cartProvider.updateQuantity(
                          cartItem.product.id,
                          cartItem.quantity - 1,
                        );
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                onPressed: () {
                  cartProvider.removeItem(cartItem.product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${cartItem.product.name} eliminado'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', 'S/ ${cartProvider.subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Delivery',
              'S/ ${cartProvider.deliveryFee.toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              'S/ ${cartProvider.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.checkout);
                },
                child: const Text('Continuar con el pago'),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn()
        .slideY(begin: 1, end: 0);
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}