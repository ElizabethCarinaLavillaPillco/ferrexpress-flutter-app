import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/order.dart';
import '../../services/database_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'yape';
  bool _isProcessing = false;
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    _addressController.text = authProvider.user?.address ??
        locationProvider.currentAddress ??
        '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu dirección de entrega'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == 'tarjeta') {
      _showCardPaymentDialog();
    } else if (_selectedPaymentMethod == 'yape') {
      _showYapePaymentDialog();
    } else {
      await _confirmOrder();
    }
  }

  void _showCardPaymentDialog() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pago con Tarjeta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn()
                  .slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 24),
              
              TextFormField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Vencimiento',
                        hintText: 'MM/AA',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 200.ms),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre en la tarjeta',
                  hintText: 'Juan Pérez',
                  prefixIcon: Icon(Icons.person),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmOrder();
                      },
                      child: const Text('Pagar'),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _showYapePaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C1D5F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  size: 100,
                  color: Color(0xFF6C1D5F),
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 20),
              
              const Text(
                'Escanea el código QR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms),
              
              const SizedBox(height: 8),
              
              Text(
                'Abre tu app de Yape y escanea el código',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms),
              
              const SizedBox(height: 24),
              
              const Text(
                'Esperando confirmación...',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C1D5F),
                      ),
                      child: const Text('Ya pagué'),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    setState(() => _isProcessing = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Simular procesamiento
    await Future.delayed(const Duration(seconds: 2));

    // Crear orden
    final orderId = const Uuid().v4();
    final now = DateTime.now();
    final estimatedDelivery = now.add(
      Duration(minutes: cartProvider.selectedFerreteria!.estimatedDeliveryTime),
    );

    final order = Order(
      id: orderId,
      userId: authProvider.user!.id,
      ferreteriaId: cartProvider.selectedFerreteria!.id,
      items: cartProvider.items.values.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          price: cartItem.product.price,
          quantity: cartItem.quantity,
          unit: cartItem.product.unit,
        );
      }).toList(),
      subtotal: cartProvider.subtotal,
      deliveryFee: cartProvider.deliveryFee,
      total: cartProvider.total,
      deliveryAddress: _addressController.text.trim(),
      deliveryLatitude: locationProvider.currentPosition?.latitude ?? -13.5226,
      deliveryLongitude: locationProvider.currentPosition?.longitude ?? -71.9673,
      paymentMethod: _selectedPaymentMethod,
      status: OrderStatus.pending,
      createdAt: now,
      estimatedDeliveryTime: estimatedDelivery,
    );

    await DatabaseService.instance.createOrder(order);

    // Simular actualización de estado después de unos segundos
    _simulateOrderProgress(orderId);

    // Limpiar carrito
    cartProvider.clear();

    setState(() => _isProcessing = false);

    if (mounted) {
      // Mostrar diálogo de éxito
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 80,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                const Text(
                  '¡Pedido confirmado!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 200.ms),
                
                const SizedBox(height: 12),
                
                Text(
                  'Tu pedido será entregado en aproximadamente ${cartProvider.selectedFerreteria!.estimatedDeliveryTime} minutos',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 300.ms),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar diálogo
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.orderTracking,
                        (route) => route.settings.name == AppRoutes.home,
                        arguments: orderId,
                      );
                    },
                    child: const Text('Rastrear pedido'),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar diálogo
                    Navigator.of(context).pop(); // Volver al carrito
                    Navigator.of(context).pop(); // Volver a home
                  },
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _simulateOrderProgress(String orderId) async {
    // Simular progreso del pedido en background
    Future.delayed(const Duration(seconds: 30), () {
      DatabaseService.instance.updateOrderStatus(orderId, OrderStatus.preparing);
    });
    
    Future.delayed(const Duration(seconds: 60), () {
      DatabaseService.instance.updateOrderStatus(orderId, OrderStatus.readyForPickup);
    });
    
    Future.delayed(const Duration(seconds: 90), () {
      DatabaseService.instance.updateOrderStatus(orderId, OrderStatus.inTransit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Pedido'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dirección de entrega
            Text(
              'Dirección de entrega',
              style: Theme.of(context).textTheme.titleLarge,
            )
                .animate()
                .fadeIn()
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Ingresa tu dirección completa',
                prefixIcon: Icon(Icons.location_on),
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),
            
            // Método de pago
            Text(
              'Método de pago',
              style: Theme.of(context).textTheme.titleLarge,
            )
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 12),
            
            _buildPaymentOption(
              'yape',
              'Yape',
              Icons.qr_code,
              const Color(0xFF6C1D5F),
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: 12),
            
            _buildPaymentOption(
              'tarjeta',
              'Tarjeta de crédito/débito',
              Icons.credit_card,
              AppColors.primary,
            )
                .animate()
                .fadeIn(delay: 350.ms)
                .slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: 12),
            
            _buildPaymentOption(
              'efectivo',
              'Efectivo contra entrega',
              Icons.payments,
              AppColors.success,
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: 32),
            
            // Resumen del pedido
            Text(
              'Resumen del pedido',
              style: Theme.of(context).textTheme.titleLarge,
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    'S/ ${cartProvider.subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
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
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Confirmar y Pagar'),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 700.ms)
          .slideY(begin: 1, end: 0),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon, Color color) {
    final isSelected = _selectedPaymentMethod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
              ),
          ],
        ),
      ),
    );
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