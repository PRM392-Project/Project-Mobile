import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/user_service.dart';

class CustomerRegisterForm extends StatefulWidget {
  const CustomerRegisterForm({super.key});

  @override
  State<CustomerRegisterForm> createState() => _CustomerRegisterFormState();
}

class _CustomerRegisterFormState extends State<CustomerRegisterForm> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerCustomer() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final response = await UserService.registerCustomer(
        name: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      debugPrint('Registration response: $response');

      messenger.showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('Registration error: $e');

      if (e is Exception && e.toString().contains("DioError")) {
        try {
          final error = e as dynamic;
          debugPrint('DioError response: ${error.response?.data}');
        } catch (_) {}
      }

      messenger.showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: usernameController,
          hintText: 'Tên người dùng',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: emailController,
          hintText: 'Gmail',
          icon: Icons.email,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: passwordController,
          hintText: 'Mật khẩu',
          icon: Icons.lock,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: confirmPasswordController,
          hintText: 'Xác nhận mật khẩu',
          icon: Icons.lock,
          obscureText: true,
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: isLoading ? null : registerCustomer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B4F39),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Đăng ký', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
