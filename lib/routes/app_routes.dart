import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/customer/customer_homepage.dart';
import '../screens/designer/designer_dashboard.dart';
import '../screens/designer/designer_profile.dart';
import '../screens/customer/customer_profile.dart';
import '../screens/customer/customer_design.dart';
import '../screens/customer/customer_furniture.dart';
import '../screens/designer/designer_homepage.dart';
import '../screens/designer/designer_furniture.dart';
import '../screens/designer/designer_design.dart';
import '../screens/designer/designer_order.dart';
import '../screens/designer/designer_order_detail.dart';
import '../screens/customer/customer_order.dart';
import '../screens/customer/customer_order_detail.dart';
import '../screens/customer/customer_fur_detail.dart';
import '../screens/customer/customer_des_detail.dart';
import '../screens/customer/customer_cart.dart';
import '../screens/forgetPassword/forget_password.dart';
import '../screens/forgetPassword/reset_password.dart';
import '../screens/customer/customer_chat_list.dart';
import '../screens/customer/customer_chat.dart';
import '../screens/designer/designer_chat_list.dart';
import '../screens/designer/designer_chat.dart';
import '../screens/customer/customer_designers.dart';
import '../screens/customer/customer_des_product.dart';


class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String customerHomepage = '/customerHomepage';
  static const String designerDashboard = '/designerDashboard';
  static const String designerProfile = '/designerProfile';
  static const String customerProfile = '/customerProfile';
  static const String customerDesign = '/customerDesign';
  static const String customerFurniture = '/customerFurniture';
  static const String designerHomepage = '/designerHomepage';
  static const String designerFurniture = '/designerFurniture';
  static const String designerDesign = '/designerDesign';
  static const String designerOrder = '/designerOrder';
  static const String designerOrderDetail = '/designerOrderDetail';
  static const String customerOrder = '/customerOrder';
  static const String customerOrderDetail = '/customerOrderDetail';
  static const String customerFurDetail = '/customerFurDetail';
  static const String customerDesDetail = '/customerDesDetail';
  static const String customerCart = '/customerCart';
  static const String forgetPassword = '/forgetPassword';
  static const String resetPassword = '/resetPassword';
  static const String chatList = '/chatList';
  static const String chatDetail = '/chatDetail';
  static const String desChatList = '/desChatList';
  static const String desChatDetail = '/desChatDetail';
  static const String customerDesigners = '/customerDesigners';
  static const String customerDesignerProduct = '/customerDesignerProduct';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case customerHomepage:
        return MaterialPageRoute(builder: (_) => const CustomerHomePage());

      case designerDashboard:
        return MaterialPageRoute(builder: (_) => const DesignerDashboard());

      case designerProfile:
        return MaterialPageRoute(builder: (_) => const DesignerProfile());

      case customerProfile:
        return MaterialPageRoute(builder: (_) => const CustomerProfile());

      case customerDesignerProduct:
        final designerId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CustomerDesignerProduct(designerId: designerId),
        );

      case customerDesign:
        return MaterialPageRoute(builder: (_) => const CustomerDesign());

      case customerFurniture:
        return MaterialPageRoute(builder: (_) => const CustomerFurniture());

      case designerHomepage:
        return MaterialPageRoute(builder: (_) => const DesignerHomepage());

      case designerFurniture:
        return MaterialPageRoute(builder: (_) => const DesignerFurniture());

      case customerFurDetail:
        final product = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(builder: (_) => CustomerFurDetail(product: product),);

      case customerDesDetail:
        final product = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(builder: (_) => CustomerDesDetail(product: product),);

      case designerDesign:
        return MaterialPageRoute(builder: (_) => const DesignerDesign());

      case designerOrder:
        return MaterialPageRoute(builder: (_) => const DesignerOrder());

      case designerOrderDetail:
        final orderId = settings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => DesignerOrderDetail(orderId: orderId));

      case customerOrder:
        return MaterialPageRoute(builder: (_) => const CustomerOrder());

      case customerDesigners:
        return MaterialPageRoute(builder: (_) => const CustomerDesigners());

      case customerOrderDetail:
        final orderId = settings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => CustomerOrderDetail(orderId: orderId));

      case customerCart:
        return MaterialPageRoute(builder: (_) => const CustomerCart());

      case forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());

      case chatList:
        return MaterialPageRoute(builder: (_) => const CustomerChatList());

      case desChatList:
        return MaterialPageRoute(builder: (_) => const DesignerChatList());

      case AppRoutes.chatDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['conversationId'] == null || args['senderName'] == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("Lỗi: Thiếu tham số conversationId hoặc senderName")),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => CustomerChat(
            conversationId: args['conversationId'] ?? '',
            senderName: args['senderName'] ?? 'Không rõ',
            designerId: args.containsKey('designerId') ? args['designerId'] : null, // ✅ kiểm tra an toàn
            onMessageSent: args['onMessageSent'],
          ),
        );

      case desChatDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['conversationId'] == null || args['senderName'] == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("Lỗi: Thiếu tham số conversationId hoặc senderName")),
            ),
          );
        }
        final conversationId = args['conversationId'] as String;
        final senderName = args['senderName'] as String;
        return MaterialPageRoute(
          builder: (_) => DesignerChat(
            conversationId: conversationId,
            senderName: senderName,
          ),
        );

      case resetPassword:
        final token = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text('No route defined'))),
        );
    }
  }
}
