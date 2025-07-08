import 'package:flutter/material.dart';
import '../../widgets/customer/customer_header.dart';
import '../../widgets/customer/cus_designer_product.dart';

class CustomerDesignerProduct extends StatelessWidget {
  final String designerId;

  const CustomerDesignerProduct({super.key, required this.designerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomerHeader(),
      ),
      body: CusDesignerProduct(designerId: designerId),
    );
  }
}
