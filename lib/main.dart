import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/location_provider.dart';
import 'services/database_service.dart';
import 'screens/splash_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await DatabaseService.instance.database; // <-- tu función que llama a sqflite
  }
  // Inicializar base de datos
  
  //await DatabaseService.instance.database;
  
  // Configurar orientación
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const FerreXpresssApp());
}

class FerreXpresssApp extends StatelessWidget {
  const FerreXpresssApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'FerreXpresss',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}