import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'routes/app_routes.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      try {
        // Decode token để lấy role
        final decodedToken = JwtDecoder.decode(token);
        final role = decodedToken['Role'] ?? '';

        if (role == 'Customer') {
          Navigator.pushReplacementNamed(context, AppRoutes.customerHomepage);
        } else if (role == 'Designer') {
          Navigator.pushReplacementNamed(context, AppRoutes.designerHomepage);
        } else {
          // Nếu role không xác định
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } catch (e) {
        // Token bị lỗi / hết hạn
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
