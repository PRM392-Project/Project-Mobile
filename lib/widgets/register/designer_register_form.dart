import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/user_service.dart';

class DesignerRegisterForm extends StatefulWidget {
  const DesignerRegisterForm({super.key});

  @override
  State<DesignerRegisterForm> createState() => _DesignerRegisterFormState();
}

class _DesignerRegisterFormState extends State<DesignerRegisterForm> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final portfolioController = TextEditingController();

  bool isLoading = false;

  Future<void> registerDesigner() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await UserService.registerDesigner(
        name: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        applicationUrl: portfolioController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
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
        const SizedBox(height: 16),
        CustomTextField(
          controller: portfolioController,
          hintText: 'Portfolio link',
          icon: Icons.assignment,
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: isLoading ? null : registerDesigner,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B4F39),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Đăng ký', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
