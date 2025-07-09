import 'package:flutter/material.dart';
import '../../widgets/customer/customer_header.dart';
import '../../widgets/customer/customer_menu.dart';
import '../../widgets/customer/cus_order_content.dart';

class CustomerOrder extends StatelessWidget {
  const CustomerOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomerHeader(),
      ),
      body: const CusOrderContent(),
      bottomNavigationBar: const CustomerMenu(selectedIndex: 1),
    );
  }
}
