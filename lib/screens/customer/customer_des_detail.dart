import 'package:flutter/material.dart';
import '../../widgets/customer/customer_header.dart';
import '../../widgets/customer/cus_des_detail_content.dart';

class CustomerDesDetail extends StatelessWidget {
  final Map<String, dynamic> product;

  const CustomerDesDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomerHeader(),
      ),
      body: CusDesDetail(product: product),
    );
  }
}
