import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_wrapper.dart';
import 'routes/app_routes.dart';
import 'providers/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapRoom',
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
