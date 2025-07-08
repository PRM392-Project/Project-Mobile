import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';

class DesProfileContent extends StatefulWidget {
  const DesProfileContent({super.key});

  @override
  State<DesProfileContent> createState() => _DesProfileContentState();
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _submitChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await UserService.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: "Đổi mật khẩu thành công!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Đổi mật khẩu thất bại.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.6;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16), bottom: Radius.circular(16)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with rounded top corners
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF3F5139),
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: const Text(
                          "Đổi mật khẩu",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTextField(
                            controller: _currentPasswordController,
                            label: "Mật khẩu hiện tại",
                            validator: (value) => value == null || value.isEmpty
                                ? "Không được để trống"
                                : null,
                          ),
                          _buildTextField(
                            controller: _newPasswordController,
                            label: "Mật khẩu mới",
                            validator: (value) => value == null || value.length < 5
                                ? "Ít nhất 6 ký tự"
                                : null,
                          ),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: "Xác nhận mật khẩu mới",
                            validator: (value) => value != _newPasswordController.text
                                ? "Mật khẩu xác nhận không khớp"
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF3F5139),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Hủy"),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F5139),
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text("Đổi mật khẩu"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF3F5139)),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3F5139)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      cursorColor: Color(0xFF3F5139),
    );
  }


}

class _DesProfileContentState extends State<DesProfileContent> {
  Map<String, dynamic>? userInfo;
  static const Color darkGreen = Color(0xFF3F5139);

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("TOKEN: $token");

    if (token != null && token.isNotEmpty) {
      try {
        final decoded = JwtDecoder.decode(token);
        print("DECODED: $decoded");

        setState(() {
          userInfo = decoded;
        });
      } catch (e) {
        print("Decode error: $e");
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final name = userInfo?['Name'] ?? 'Unknown';
    final role = userInfo?['Role'] ?? 'Unknown';
    final email = (userInfo?['Email']?.toString().isNotEmpty ?? false) ? userInfo!['Email'].toString() : 'Unknown';
    final phone = (userInfo?['ContactNumber']?.toString().isNotEmpty ?? false) ? userInfo!['ContactNumber'].toString() : '0586564774';
    final address = (userInfo?['Address']?.toString().isNotEmpty ?? false) ? userInfo!['Address'].toString() : 'Unknown';
    final avatarUrl = userInfo?['AvatarSource'] ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: darkGreen,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.designerHomepage);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        offset: const Offset(0, 40),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == 'change_password') {
                            showDialog(
                              context: context,
                              builder: (context) => const ChangePasswordDialog(),
                            );
                          } else if (value == 'language') {
                            Fluttertoast.showToast(msg: "Tính năng đang được phát triển");
                          }
                        },
                        itemBuilder: (BuildContext context) => const [
                          PopupMenuItem(
                            value: 'change_password',
                            child: Text('Đổi mật khẩu'),
                          ),
                          PopupMenuItem(
                            value: 'language',
                            child: Text('Ngôn ngữ'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 70, bottom: 24),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(role, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.location_on, color: Colors.black54, size: 16),
                          SizedBox(width: 4),
                          Text('HO CHI MINH CITY', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/images/avatar_placeholder.png') as ImageProvider,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 170),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 20, 0),
            child: Column(
              children: [
                _buildInfoRow(Icons.email, 'Email', email),
                _buildInfoRow(Icons.phone, 'Contact Number', phone),
                _buildInfoRow(Icons.home, 'Address', address),
              ],
            ),
          ),
          const SizedBox(height: 90),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: darkGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Unknown',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
