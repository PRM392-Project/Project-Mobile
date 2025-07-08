import 'package:flutter/material.dart';
import '../../widgets/designer/des_header.dart';
import '../../widgets/designer/des_des_content.dart';

class DesignerDesign extends StatelessWidget {
  const DesignerDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: DesHeader(),
      ),
      body: const DesDesContent(),
    );
  }
}
