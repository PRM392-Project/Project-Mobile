import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Vui lòng nhập đầy đủ mật khẩu.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Mật khẩu xác nhận không khớp.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await UserService.resetPassword(
        token: widget.token,
        newPassword: password,
      );

      if (response != null && response['statusCode'] == 200) {
        _showSuccessDialog();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thành công"),
        content: const Text("Mật khẩu đã được thay đổi. Vui lòng đăng nhập lại."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .popUntil((route) => route.isFirst); // Quay về màn hình đầu
              Navigator.pushReplacementNamed(context, '/login'); // Chuyển tới login
            },
            child: const Text("Quay về đăng nhập"),
          ),
        ],
      ),
    );
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
                'ĐẶT LẠI MẬT KHẨU',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF3F5139),
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Mật khẩu mới',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Xác nhận mật khẩu',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
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
                    : const Text('Xác nhận', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
