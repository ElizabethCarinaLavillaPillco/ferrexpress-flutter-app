import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/ferreteria.dart';
import '../models/product.dart';
import '../models/order.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ferrexpress.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');

    // Tabla de ferreterías
    await db.execute('''
      CREATE TABLE ferreterias (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        phone TEXT NOT NULL,
        image TEXT,
        rating REAL NOT NULL,
        reviewCount INTEGER NOT NULL,
        openTime TEXT NOT NULL,
        closeTime TEXT NOT NULL,
        isOpen INTEGER NOT NULL,
        deliveryFee REAL NOT NULL,
        estimatedDeliveryTime INTEGER NOT NULL
      )
    ''');

    // Tabla de productos
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        ferreteriaId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        image TEXT,
        inStock INTEGER NOT NULL,
        stockQuantity INTEGER NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY (ferreteriaId) REFERENCES ferreterias (id)
      )
    ''');

    // Tabla de órdenes
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        ferreteriaId TEXT NOT NULL,
        subtotal REAL NOT NULL,
        deliveryFee REAL NOT NULL,
        total REAL NOT NULL,
        deliveryAddress TEXT NOT NULL,
        deliveryLatitude REAL NOT NULL,
        deliveryLongitude REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        estimatedDeliveryTime TEXT,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (ferreteriaId) REFERENCES ferreterias (id)
      )
    ''');

    // Tabla de items de orden
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id)
      )
    ''');

    // Insertar datos de prueba
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Ferreterías de ejemplo en Cusco
    final ferreterias = [
      {
        'id': 'f1',
        'name': 'Ferretería El Constructor',
        'address': 'Av. La Cultura 2345, Cusco',
        'latitude': -13.5226,
        'longitude': -71.9673,
        'phone': '984123456',
        'image': 'assets/images/ferreteria.jpg',
        'rating': 4.5,
        'reviewCount': 128,
        'openTime': '08:00',
        'closeTime': '20:00',
        'isOpen': 1,
        'deliveryFee': 5.0,
        'estimatedDeliveryTime': 30,
      },
      {
        'id': 'f2',
        'name': 'Mega Ferretería San Blas',
        'address': 'Cuesta San Blas 567, Cusco',
        'latitude': -13.5165,
        'longitude': -71.9775,
        'phone': '984234567',
        'image': 'assets/images/ferreteria2.jpg',
        'rating': 4.7,
        'reviewCount': 95,
        'openTime': '07:30',
        'closeTime': '21:00',
        'isOpen': 1,
        'deliveryFee': 3.5,
        'estimatedDeliveryTime': 25,
      },
      {
        'id': 'f3',
        'name': 'Ferretería Total',
        'address': 'Av. El Sol 890, Cusco',
        'latitude': -13.5184,
        'longitude': -71.9785,
        'phone': '984345678',
        'image': 'assets/images/ferreteria3.jpg',
        'rating': 4.3,
        'reviewCount': 76,
        'openTime': '08:00',
        'closeTime': '19:00',
        'isOpen': 1,
        'deliveryFee': 4.0,
        'estimatedDeliveryTime': 35,
      },
      {
        'id': 'f4',
        'name': 'Casa Gómez Ferretería',
        'address': 'Av. Tullumayo 1234, Cusco',
        'latitude': -13.5300,
        'longitude': -71.9650,
        'phone': '984456789',
        'image': 'assets/images/ferreteria4.jpg',
        'rating': 4.6,
        'reviewCount': 110,
        'openTime': '08:00',
        'closeTime': '20:00',
        'isOpen': 1,
        'deliveryFee': 4.5,
        'estimatedDeliveryTime': 28,
      },
    ];

    for (var ferreteria in ferreterias) {
      await db.insert('ferreterias', ferreteria);
    }

    // Productos de ejemplo
    final products = [
      // Productos Ferretería 1
      {
        'id': 'p1',
        'ferreteriaId': 'f1',
        'name': 'Martillo de Garra 16oz',
        'description': 'Martillo profesional con mango de fibra de vidrio',
        'price': 45.90,
        'category': 'Herramientas',
        'assets/images/martillo.jpg'
        'inStock': 1,
        'stockQuantity': 25,
        'unit': 'unidad',
      },
      {
        'id': 'p2',
        'ferreteriaId': 'f1',
        'name': 'Pintura Látex Blanco 1G',
        'description': 'Pintura látex lavable para interiores',
        'price': 89.90,
        'category': 'Pinturas',
        'image': 'assets/images/pintura.jpg',
        'inStock': 1,
        'stockQuantity': 15,
        'unit': 'galón',
      },
      {
        'id': 'p3',
        'ferreteriaId': 'f1',
        'name': 'Cemento Portland Tipo I',
        'description': 'Bolsa de cemento 42.5kg',
        'price': 28.50,
        'category': 'Construcción',
        'image': 'assets/images/cemento.jpg',
        'inStock': 1,
        'stockQuantity': 100,
        'unit': 'bolsa',
      },
      // Productos Ferretería 2
      {
        'id': 'p4',
        'ferreteriaId': 'f2',
        'name': 'Taladro Percutor 13mm',
        'description': 'Taladro eléctrico 750W con percutor',
        'price': 1089.90,
        'category': 'Herramientas Eléctricas',
        'image': 'assets/images/taladro.jpg',
        'inStock': 1,
        'stockQuantity': 8,
        'unit': 'unidad',
      },
      {
        'id': 'p5',
        'ferreteriaId': 'f2',
        'name': 'Tubería PVC 1/2" x 3m',
        'description': 'Tubería de PVC para agua fría',
        'price': 12.90,
        'category': 'Plomería',
        'image': 'assets/images/tubo.jpg',
        'inStock': 1,
        'stockQuantity': 50,
        'unit': 'tubo',
      },
      {
        'id': 'p6',
        'ferreteriaId': 'f2',
        'name': 'Brocha 3 pulgadas',
        'description': 'Brocha profesional de cerda sintética',
        'price': 15.90,
        'category': 'Pinturas',
        'image': 'assets/images/brocha.jpg',
        'inStock': 1,
        'stockQuantity': 30,
        'unit': 'unidad',
      },
      // Productos Ferretería 3
      {
        'id': 'p7',
        'ferreteriaId': 'f3',
        'name': 'Clavos de Acero 3"',
        'description': 'Clavos para construcción 1kg',
        'price': 8.50,
        'category': 'Fierrería',
        'image': 'assets/images/clavos.jpg',
        'inStock': 1,
        'stockQuantity': 200,
        'unit': 'kg',
      },
      {
        'id': 'p8',
        'ferreteriaId': 'f3',
        'name': 'Candado de Seguridad 50mm',
        'description': 'Candado laminado resistente al agua',
        'price': 32.90,
        'category': 'Cerrajería',
        'image': 'assets/images/candado.jpg',
        'inStock': 1,
        'stockQuantity': 20,
        'unit': 'unidad',
      },
      {
        'id': 'p9',
        'ferreteriaId': 'f3',
        'name': 'Sierra Copa 2"',
        'description': 'Broca copa para madera y metal',
        'price': 24.90,
        'category': 'Herramientas',
        'image': 'assets/images/sierra.jpg',
        'inStock': 1,
        'stockQuantity': 12,
        'unit': 'unidad',
      },
      // Productos Ferretería 4
      {
        'id': 'p10',
        'ferreteriaId': 'f4',
        'name': 'Cable Eléctrico 2.5mm x 100m',
        'description': 'Cable THW calibre 14 AWG',
        'price': 265.00,
        'category': 'Electricidad',
        'image': 'assets/images/cable.jpg',
        'inStock': 1,
        'stockQuantity': 5,
        'unit': 'rollo',
      },
      {
        'id': 'p11',
        'ferreteriaId': 'f4',
        'name': 'Llave Stilson 14"',
        'description': 'Llave ajustable para tuberías',
        'price': 56.90,
        'category': 'Herramientas',
        'image': 'assets/images/llave.jpg',
        'inStock': 1,
        'stockQuantity': 15,
        'unit': 'unidad',
      },
      {
        'id': 'p12',
        'ferreteriaId': 'f4',
        'name': 'Arena Fina para Construcción',
        'description': 'Saco de arena fina 40kg',
        'price': 15.00,
        'category': 'Construcción',
        'image': 'assets/images/arena.jpg',
        'inStock': 1,
        'stockQuantity': 80,
        'unit': 'saco',
      },
    ];

    for (var product in products) {
      await db.insert('products', product);
    }
  }

  // Métodos para usuarios
  Future<User?> createUser(String email, String password, String name, String phone) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    try {
      await db.insert('users', {
        'id': id,
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      });
      
      return User(id: id, email: email, name: name, phone: phone);
    } catch (e) {
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateUserLocation(String userId, String address, double lat, double lon) async {
    final db = await database;
    await db.update(
      'users',
      {'address': address, 'latitude': lat, 'longitude': lon},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Métodos para ferreterías
  Future<List<Ferreteria>> getAllFerreterias() async {
    final db = await database;
    final result = await db.query('ferreterias');
    return result.map((map) => Ferreteria.fromMap(map)).toList();
  }

  Future<Ferreteria?> getFerreteriaById(String id) async {
    final db = await database;
    final result = await db.query(
      'ferreterias',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Ferreteria.fromMap(result.first);
    }
    return null;
  }

  // Métodos para productos
  Future<List<Product>> getProductsByFerreteriaId(String ferreteriaId) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'ferreteriaId = ?',
      whereArgs: [ferreteriaId],
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  // Métodos para órdenes
  Future<String> createOrder(Order order) async {
    final db = await database;
    
    await db.insert('orders', order.toMap());
    
    for (var item in order.items) {
      await db.insert('order_items', {
        ...item.toMap(),
        'orderId': order.id,
      });
    }
    
    return order.id;
  }

  Future<Order?> getOrderById(String orderId) async {
    final db = await database;
    final orderResult = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );

    if (orderResult.isEmpty) return null;

    final order = Order.fromMap(orderResult.first);
    
    final itemsResult = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    
    final items = itemsResult.map((map) => OrderItem.fromMap(map)).toList();
    
    return Order(
      id: order.id,
      userId: order.userId,
      ferreteriaId: order.ferreteriaId,
      items: items,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      total: order.total,
      deliveryAddress: order.deliveryAddress,
      deliveryLatitude: order.deliveryLatitude,
      deliveryLongitude: order.deliveryLongitude,
      paymentMethod: order.paymentMethod,
      status: order.status,
      createdAt: order.createdAt,
      estimatedDeliveryTime: order.estimatedDeliveryTime,
    );
  }

  Future<List<Order>> getUserOrders(String userId) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    
    List<Order> orders = [];
    for (var map in result) {
      final order = await getOrderById(map['id'] as String);
      if (order != null) orders.add(order);
    }
    
    return orders;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final db = await database;
    await db.update(
      'orders',
      {'status': status.toString()},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}