import 'package:flutter/material.dart';
import '../../widgets/customer/customer_header.dart';
import '../../widgets/customer/cus_cart_content.dart';
import '../../widgets/customer/customer_menu.dart';

class CustomerCart extends StatelessWidget {
  const CustomerCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomerHeader(),
      ),
      body: const CusCartContent(),
      bottomNavigationBar: const CustomerMenu(selectedIndex: 5),
    );
  }
}
