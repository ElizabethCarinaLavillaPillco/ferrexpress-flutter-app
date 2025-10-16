import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/ferreteria.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';

class FerreteriaDetailScreen extends StatefulWidget {
  final Ferreteria ferreteria;

  const FerreteriaDetailScreen({super.key, required this.ferreteria});

  @override
  State<FerreteriaDetailScreen> createState() => _FerreteriaDetailScreenState();
}

class _FerreteriaDetailScreenState extends State<FerreteriaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todos';
  List<String> _categories = ['Todos'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseService.instance.getProductsByFerreteriaId(
      widget.ferreteria.id,
    );
    
    // Extraer categorías únicas
    final categories = products.map((p) => p.category).toSet().toList();
    categories.sort();
    
    setState(() {
      _products = products;
      _categories = ['Todos', ...categories];
      _isLoading = false;
    });
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Todos') return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.orangeGradient,
                    ),
                    child: const Icon(
                      Icons.store,
                      size: 100,
                      color: Colors.white54,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ferreteria.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.accent3,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.ferreteria.rating} (${widget.ferreteria.reviewCount} reseñas)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.cart);
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent3,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Productos'),
                  Tab(text: 'Información'),
                ],
              ),
            ),
          ),
          
          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: cartProvider.selectedFerreteria?.id == widget.ferreteria.id &&
              cartProvider.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.cart);
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.shopping_cart),
              label: Text('Ver carrito (${cartProvider.itemCount})'),
            )
              .animate()
              .fadeIn()
              .slideY(begin: 1, end: 0)
          : null,
    );
  }

  Widget _buildProductsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Category filter
        if (_categories.length > 1)
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                );
              },
            ),
          )
              .animate()
              .fadeIn()
              .slideY(begin: -0.2, end: 0),
        
        // Products grid
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No hay productos en esta categoría',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return _buildProductCard(product)
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isInCart = cartProvider.items.containsKey(product.id);
    final quantity = isInCart ? cartProvider.items[product.id]!.quantity : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image/icon
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.construction,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),
          
          // Product info
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Price
                  Text(
                    'S/ ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Stock
                  Text(
                    product.inStock ? 'Stock: ${product.stockQuantity}' : 'Sin stock',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: product.inStock ? AppColors.success : AppColors.error,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Add to cart button
                  if (!isInCart)
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: product.inStock
                            ? () {
                                cartProvider.setFerreteria(widget.ferreteria);
                                cartProvider.addItem(product);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} agregado al carrito'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Agregar',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () {
                              cartProvider.updateQuantity(product.id, quantity - 1);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () {
                              if (quantity < product.stockQuantity) {
                                cartProvider.updateQuantity(product.id, quantity + 1);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Información de contacto',
            [
              _buildInfoRow(Icons.phone, 'Teléfono', widget.ferreteria.phone),
              _buildInfoRow(
                Icons.location_on,
                'Dirección',
                widget.ferreteria.address,
              ),
            ],
          )
              .animate()
              .fadeIn()
              .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          _buildInfoSection(
            'Horario de atención',
            [
              _buildInfoRow(
                Icons.access_time,
                'Horario',
                '${widget.ferreteria.openTime} - ${widget.ferreteria.closeTime}',
              ),
              _buildInfoRow(
                Icons.circle,
                'Estado',
                widget.ferreteria.isOpen ? 'Abierto ahora' : 'Cerrado',
                valueColor: widget.ferreteria.isOpen
                    ? AppColors.success
                    : AppColors.error,
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 100.ms)
              .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          _buildInfoSection(
            'Delivery',
            [
              _buildInfoRow(
                Icons.delivery_dining,
                'Costo de envío',
                'S/ ${widget.ferreteria.deliveryFee.toStringAsFixed(2)}',
              ),
              _buildInfoRow(
                Icons.timer,
                'Tiempo estimado',
                '${widget.ferreteria.estimatedDeliveryTime} minutos',
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          _buildInfoSection(
            'Valoraciones',
            [
              _buildRatingBar(),
            ],
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              widget.ferreteria.rating.toString(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < widget.ferreteria.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.accent3,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.ferreteria.reviewCount} reseñas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}