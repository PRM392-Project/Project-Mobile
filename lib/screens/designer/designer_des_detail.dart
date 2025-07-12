import 'package:flutter/material.dart';
import '../../widgets/designer/des_header.dart';
import '../../widgets/designer/des_des_detail_content.dart';

class DesignerDesDetail extends StatelessWidget {
  final Map<String, dynamic> product;

  const DesignerDesDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: DesHeader(),
      ),
      body: DesDesDetailContent(product: product),
    );
  }
} 