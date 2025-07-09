import 'package:flutter/material.dart';
import '../../widgets/customer/customer_header.dart';
import '../../widgets/customer/customer_menu.dart';
import '../../widgets/customer/cus_home_content.dart'; 

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomerHeader(),
      ),
      body: const CusHomeContent(),
      bottomNavigationBar: const CustomerMenu(selectedIndex: 0),
    );
  }
}
