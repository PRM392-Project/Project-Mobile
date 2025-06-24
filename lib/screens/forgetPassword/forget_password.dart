import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  int uiRoleIndex = 0; // 0: Customer, 1: Designer

  bool _isLoading = false;

  void _submitRequest() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("Vui lòng nhập email");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final roleInDb = uiRoleIndex == 0 ? 2 : 1; // 2 = Customer, 1 = Designer

    try {
      final response = await UserService.forgetPassword(
        email: email,
        role: roleInDb,
      );

      if (response != null && response['statusCode'] == 200) {
        _showMessage("Yêu cầu thành công! Vui lòng kiểm tra email.");
      } else {
        _showMessage(response?['message'] ?? "Đã xảy ra lỗi.");
      }
    } catch (e) {
      _showMessage("Lỗi: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showMessage(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/full_logo_green.png',
                width: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              const Text(
                'QUÊN MẬT KHẨU',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF3F5139),
                ),
              ),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [uiRoleIndex == 0, uiRoleIndex == 1],
                onPressed: (index) {
                  setState(() {
                    uiRoleIndex = index;
                  });
                },

                borderRadius: BorderRadius.circular(30),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF3B4F39),
                color: const Color(0xFF3B4F39),
                splashColor: const Color(0x553B4F39),
                hoverColor: const Color(0x223B4F39),
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
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4F39),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Gửi yêu cầu', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: const Text(
                  'Quay lại đăng nhập',
                  style: TextStyle(
                    color: Color(0xFF3B4F39),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
