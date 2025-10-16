import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../models/ferreteria.dart';
import '../../services/database_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Order? _order;
  Ferreteria? _ferreteria;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    
    // Actualizar cada 5 segundos para simular cambios en tiempo real
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadOrder();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    final order = await DatabaseService.instance.getOrderById(widget.orderId);
    
    if (order != null) {
      final ferreteria = await DatabaseService.instance.getFerreteriaById(
        order.ferreteriaId,
      );
      
      setState(() {
        _order = order;
        _ferreteria = ferreteria;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rastrear Pedido'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rastrear Pedido'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              const Text(
                'No se encontró el pedido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastrear Pedido'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado actual destacado
              _buildCurrentStatusCard()
                  .animate()
                  .fadeIn()
                  .slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 24),
              
              // Timeline de estados
              Text(
                'Seguimiento del pedido',
                style: Theme.of(context).textTheme.titleLarge,
              )
                  .animate()
                  .fadeIn(delay: 100.ms),
              
              const SizedBox(height: 16),
              
              _buildTimeline()
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 32),
              
              // Información de la ferretería
              Text(
                'Información de la ferretería',
                style: Theme.of(context).textTheme.titleLarge,
              )
                  .animate()
                  .fadeIn(delay: 300.ms),
              
              const SizedBox(height: 12),
              
              if (_ferreteria != null)
                _buildFerreteriaInfo()
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
              
              const SizedBox(height: 32),
              
              // Detalles del pedido
              Text(
                'Detalles del pedido',
                style: Theme.of(context).textTheme.titleLarge,
              )
                  .animate()
                  .fadeIn(delay: 500.ms),
              
              const SizedBox(height: 12),
              
              _buildOrderDetails()
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _order!.status == OrderStatus.delivered
          ? Container(
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showRatingDialog();
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('Calificar experiencia'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent3,
                    ),
                  ),
                ),
              ),
            )
              .animate()
              .fadeIn()
              .slideY(begin: 1, end: 0)
          : null,
    );
  }

  Widget _buildCurrentStatusCard() {
    final status = _order!.status;
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms),
          
          const SizedBox(height: 16),
          
          Text(
            status.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            status.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (_order!.estimatedDeliveryTime != null &&
              status != OrderStatus.delivered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Llega a las ${DateFormat('HH:mm').format(_order!.estimatedDeliveryTime!)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final statuses = OrderStatus.values.where((s) => s != OrderStatus.cancelled).toList();
    final currentIndex = statuses.indexOf(_order!.status);
    
    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == statuses.length - 1;
        
        return _buildTimelineItem(
          status,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLast: isLast,
        );
      }),
    );
  }

  Widget _buildTimelineItem(
    OrderStatus status, {
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final color = isCompleted ? AppColors.primary : Colors.grey.shade300;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? AppColors.accent3 : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : _getStatusIcon(status),
                color: Colors.white,
                size: 20,
              ),
            )
                .animate(
                  target: isCurrent ? 1 : 0,
                  onPlay: (controller) => isCurrent ? controller.repeat() : null,
                )
                .scale(end: const Offset(1.1, 1.1), duration: 1000.ms),
            
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: color,
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFerreteriaInfo() {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ferreteria!.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _ferreteria!.phone,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_in_talk),
            color: AppColors.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Llamar a ${_ferreteria!.phone}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('N° de pedido', '#${_order!.id.substring(0, 8).toUpperCase()}'),
          const Divider(height: 24),
          _buildDetailRow(
            'Fecha',
            DateFormat('dd/MM/yyyy HH:mm').format(_order!.createdAt),
          ),
          const Divider(height: 24),
          _buildDetailRow('Método de pago', _getPaymentMethodName(_order!.paymentMethod)),
          const Divider(height: 24),
          _buildDetailRow('Dirección de entrega', _order!.deliveryAddress),
          const Divider(height: 24),
          
          // Lista de productos
          const Text(
            'Productos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          
          ...(_order!.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.quantity}x ${item.productName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  'S/ ${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ))),
          
          const Divider(height: 24),
          
          _buildDetailRow('Subtotal', 'S/ ${_order!.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildDetailRow('Delivery', 'S/ ${_order!.deliveryFee.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildDetailRow(
            'Total',
            'S/ ${_order!.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.secondary;
      case OrderStatus.preparing:
        return AppColors.accent1;
      case OrderStatus.readyForPickup:
        return AppColors.accent3;
      case OrderStatus.inTransit:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.receipt_long;
      case OrderStatus.preparing:
        return Icons.shopping_bag;
      case OrderStatus.readyForPickup:
        return Icons.check_circle;
      case OrderStatus.inTransit:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.home;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'yape':
        return 'Yape';
      case 'tarjeta':
        return 'Tarjeta';
      case 'efectivo':
        return 'Efectivo';
      default:
        return method;
    }
  }

  void _showRatingDialog() {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent3.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: AppColors.accent3,
                    size: 50,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 20),
                
                const Text(
                  '¿Cómo fue tu experiencia?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms),
                
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: AppColors.accent3,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                    );
                  }),
                )
                    .animate()
                    .fadeIn(delay: 300.ms),
                
                const SizedBox(height: 20),
                
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Cuéntanos más sobre tu experiencia (opcional)',
                    border: OutlineInputBorder(),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms),
                
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Gracias por tu calificación!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent3,
                        ),
                        child: const Text('Enviar'),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}