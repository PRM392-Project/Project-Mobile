import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Thêm dòng này
import '../../routes/app_routes.dart';
import '../../providers/cart_provider.dart'; // Thêm dòng này

class CustomerHeader extends StatelessWidget {
  const CustomerHeader({Key? key}) : super(key: key);

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 100,
              child: Image.asset(
                'assets/images/logo_white.png',
                fit: BoxFit.contain,
              ),
            ),

            Row(
              children: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.customerCart);
                      },
                      icon: const Icon(Icons.shopping_cart),
                      color: Colors.white,
                      tooltip: 'Cart',
                    ),
                    Positioned(
                      right: 1,
                      top: 1,
                      child: Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          if (cartProvider.itemCount == 0) return const SizedBox();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                '${cartProvider.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),

                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
