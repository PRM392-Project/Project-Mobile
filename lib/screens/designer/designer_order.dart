import 'package:flutter/material.dart';
import '../../widgets/designer/des_header.dart';
import '../../widgets/designer/des_menu.dart';
import '../../widgets/designer/des_order_content.dart';

class DesignerOrder extends StatelessWidget {
  const DesignerOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: DesHeader(),
      ),
      body: const DesOrderContent(),
      bottomNavigationBar: const DesMenu(selectedIndex: 1),
    );
  }
}
