import 'package:flutter/material.dart';
import '../../widgets/designer/des_profile_content.dart';
import '../../widgets/designer/des_menu.dart';


class DesignerProfile extends StatelessWidget {
  const DesignerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: DesProfileContent(),
      bottomNavigationBar: DesMenu(selectedIndex: 3),
    );
  }
}
