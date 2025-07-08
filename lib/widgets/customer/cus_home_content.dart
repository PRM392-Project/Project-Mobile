import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../services/user_service.dart';  // sửa lại đúng đường dẫn của bạn

class CusHomeContent extends StatefulWidget {
  const CusHomeContent({Key? key}) : super(key: key);

  @override
  State<CusHomeContent> createState() => _CusHomeContentState();
}

class _CusHomeContentState extends State<CusHomeContent> {
  static const Color titleColor = Color(0xFF3F5139);

  @override
  void initState() {
    super.initState();
    _loadCartCount(); // Gọi API ngay khi màn hình được khởi tạo
  }

  Future<void> _loadCartCount() async {
    try {
      final response = await UserService.getAllCart();
      final count = response['data']['orderDetails']?.length ?? 0;

      if (mounted) {
        Provider.of<CartProvider>(context, listen: false).setItemCount(count);
      }
    } catch (e) {
      debugPrint('Lỗi khi load giỏ hàng: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/cus_home_banner.png',
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 40,
                  bottom: 40,
                  child: SizedBox(
                    width: size.width / 2 - 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Flexible(
                          child: Text(
                            "KHÁM PHÁ SNAPROOM",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            "Hãy cùng chúng tôi tạo nên không gian sống mơ ước của bạn",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildMenuItem(
                  context,
                  'assets/images/cus_home_fur.png',
                  'NỘI THẤT',
                  AppRoutes.customerFurniture,
                ),
                _buildMenuItem(
                  context,
                  'assets/images/cus_home_inter.png',
                  'BẢN VẼ',
                  AppRoutes.customerDesign,
                ),
                _buildMenuItem(
                  context,
                  'assets/images/cus_home_des.png',
                  'NHÀ THIẾT KẾ',
                  AppRoutes.customerDesigners,
                ),
                _buildMenuItem(
                  context,
                  'assets/images/cus_home_connect.png',
                  'TRÒ CHUYỆN',
                  AppRoutes.chatList,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/cus_home_foot.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_white.png',
                    width: 200,
                    height: 70,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Nơi sáng tạo không gian sống của bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconWithTitle(Icons.verified, 'Được chứng nhận'),
                _buildIconWithTitle(Icons.thumb_up, 'Đáng tin cậy'),
                _buildIconWithTitle(Icons.support_agent, 'Luôn hỗ trợ'),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String imagePath,
    String title,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF3F5139),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithTitle(IconData iconData, String title) {
    return Column(
      children: [
        Icon(
          iconData,
          size: 20,
          color: titleColor,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
