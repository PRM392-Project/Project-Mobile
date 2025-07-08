import 'package:flutter/material.dart';

class DesHeader extends StatelessWidget {
  const DesHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFF3F5139);

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo SnapRoom (text giả lập)
            SizedBox(
              height: 80,  
              width: 100,
              child: Image.asset(
                'assets/images/logo_white.png',
                fit: BoxFit.contain,
              ),
            ),


          ],
        ),
      ),
    );
  }
}