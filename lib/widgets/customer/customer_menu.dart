import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class CustomerMenu extends StatelessWidget {
  final int selectedIndex;

  const CustomerMenu({
    required this.selectedIndex,
    Key? key,
  }) : super(key: key);

  void _handleTap(BuildContext context, int index) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.customerHomepage);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.customerOrder);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.chatList);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.customerProfile);
        break;
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData iconData,
    String label,
    int index, {
    bool hasNotification = false,
  }) {
    bool isSelected = selectedIndex == index;
    final activeColor = const Color(0xFF3F5139);
    final inactiveColor = Colors.grey.shade600;

    return Flexible(
      child: InkWell(
        onTap: () => _handleTap(context, index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    iconData,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 28,
                  ),
                  if (hasNotification)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 3,
                  width: 28,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                )
              else
                const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 65),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, Icons.home, 'Trang chủ', 0),
            _buildNavItem(context, Icons.article, 'Đơn hàng', 1),
            _buildNavItem(context, Icons.message, 'Trò chuyện', 2),
            _buildNavItem(context, Icons.person, 'Hồ sơ', 3),
          ],
        ),
      ),
    );
  }
}
