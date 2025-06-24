import 'package:flutter/material.dart';

class BuyMenu extends StatelessWidget {
  final VoidCallback? onContact;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  const BuyMenu({
    Key? key,
    this.onContact,
    this.onAddToCart,
    this.onBuyNow,
  }) : super(key: key);

  final Color borderColor = const Color(0xFF3F5139);

  Widget _buildButton({
    required int index,
    required String label,
    IconData? icon,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        highlightColor: borderColor.withOpacity(0.3),
        splashColor: borderColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: index != 2
                  ? BorderSide(color: borderColor, width: 1)
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: borderColor,
                  size: 20,
                ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: borderColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          _buildButton(index: 0, label: 'Liên hệ', icon: Icons.chat, onTap: onContact),
          _buildButton(index: 1, label: 'Thêm vào giỏ', icon: Icons.add_shopping_cart, onTap: onAddToCart),
          _buildButton(index: 2, label: 'Mua ngay', icon: Icons.shopping_bag, onTap: onBuyNow),
        ],
      ),
    );
  }
}
