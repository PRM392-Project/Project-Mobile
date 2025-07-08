import 'package:flutter/material.dart';
import '../../widgets/designer/des_header.dart';
import '../../widgets/designer/des_menu.dart';
import '../../widgets/designer/des_home_content.dart';

class DesignerHomepage extends StatelessWidget {
  const DesignerHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: DesHeader(),
      ),
      body: const DesHomeContent(),
      bottomNavigationBar: const DesMenu(selectedIndex: 0),
    );
  }
}
