import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../routes/app_routes.dart';

const Color kPrimaryDarkGreen = Color(0xFF3F5139);

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final int totalOrders = 12;
    final int pendingOrders = 3;
    final int completedOrders = 9;
    final int revenue = 15400000;

    final List<Map<String, String>> recentFeedbacks = [
      {'customer': 'Nguyễn Văn A', 'feedback': 'Thiết kế rất đẹp, tôi rất ưng ý!'},
      {'customer': 'Trần Thị B', 'feedback': 'Giao file nhanh chóng và chất lượng.'},
      {'customer': 'Lê Văn C', 'feedback': 'Rất chuyên nghiệp và thân thiện.'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.designerHomepage);
                    },
                  ),
                  const SizedBox(width: 8),

                ],
              ),
              const SizedBox(height: 16),

              // Revenue card full width
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Doanh thu tháng này',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat("#,###", "vi_VN").format(revenue)} VNĐ',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3F5139)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Thống kê đơn hàng
              Row(
                children: [
                  _buildStatCard('Tổng đơn', totalOrders, Colors.blue),
                  _buildStatCard('Đang xử lý', pendingOrders, Colors.orange),
                  _buildStatCard('Hoàn tất', completedOrders, Colors.green),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Feedback gần đây',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryDarkGreen),
              ),
              const SizedBox(height: 12),

              ...recentFeedbacks.map((feedback) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: kPrimaryDarkGreen,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(feedback['customer'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(feedback['feedback'] ?? ''),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
