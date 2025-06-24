import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/register/customer_register_form.dart';
import '../../widgets/register/designer_register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int selectedIndex = 0; // 0: Customer, 1: Designer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/full_logo_green.png',
                width: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 50),
              const Text(
                'TẠO TÀI KHOẢN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF3F5139),
                ),
              ),
              const SizedBox(height: 12),
              ToggleButtons(
                isSelected: [selectedIndex == 0, selectedIndex == 1],
                onPressed: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(30),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF3B4F39),
                color: const Color(0xFF3B4F39),
                borderColor: const Color(0xFF3B4F39),
                borderWidth: 1.5,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                constraints: const BoxConstraints(minHeight: 42, minWidth: 120),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Khách hàng'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Nhà thiết kế'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: selectedIndex == 0
                      ? const CustomerRegisterForm()
                      : const DesignerRegisterForm(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Color(0xFF3B4F39)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
