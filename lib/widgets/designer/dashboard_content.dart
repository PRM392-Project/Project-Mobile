import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/user_service.dart';

const Color kPrimaryDarkGreen = Color(0xFF3F5139);

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  bool _isLoading = true;

  int _totalCustomers = 0;
  int _totalOrders = 0;
  int _totalRevenue = 0;
  int _pendingProducts = 0;

  Map<String, int> _orderStatusCount = {};
  List<Map<String, dynamic>> _orderStatusData = [];

  List<Map<String, dynamic>> _topProducts = [];

  List<Map<String, dynamic>> _topReviewedProducts = [];

  List<Map<String, dynamic>> _revenueData = [];
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final int currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadOrdersData(),
        _loadPendingProducts(),
        _loadTopProducts(),
        _loadTopReviewedProducts(),
        _loadRevenueData(),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrdersData() async {
    try {
      final response = await UserService.getAllOrdersByDesAPI();
      if (response['data'] != null && response['data'] != null) {
        final orders = response['data']['items'] as List;

        _totalOrders = response['data']['totalItems'] ?? 0;

        final uniqueCustomers =
            orders
                .map((order) => order['customer']?['name'])
                .where((name) => name != null)
                .toSet();
        _totalCustomers = uniqueCustomers.length;

        _totalRevenue = orders.fold(
          0,
          (sum, order) => sum + (order['orderPrice'] as num? ?? 0).toInt(),
        );

        _orderStatusCount = {};
        for (var order in orders) {
          final status = order['status'] as String? ?? 'Unknown';
          _orderStatusCount[status] = (_orderStatusCount[status] ?? 0) + 1;
        }

        _orderStatusData =
            _orderStatusCount.entries.map((entry) {
              return {
                'name': _getStatusLabel(entry.key),
                'value': entry.value,
                'rawStatus': entry.key,
              };
            }).toList();
      }
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  Future<void> _loadPendingProducts() async {
    try {
      final response = await UserService.getNewProductsAPI();
      if (response['data'] != null) {
        _pendingProducts = response['data']['totalItems'] ?? 0;
      }
    } catch (e) {
      print('Error loading pending products: $e');
    }
  }

  Future<void> _loadTopProducts() async {
    try {
      final response = await UserService.getTopProductsAPI();
      if (response['data'] != null && response['data'] is List) {
        final products =
            response['data'].map<Map<String, dynamic>>((product) {
              return {
                'name': product['productName'] ?? 'Unknown Product',
                'sales': product['quantitySold'] ?? 0,
              };
            }).toList();

        setState(() {
          _topProducts = products;
        });
      }
    } catch (e) {
      print('Error loading top products: $e');
    }
  }

  Future<void> _loadTopReviewedProducts() async {
    try {
      final response = await UserService.getTopProductsWithReviewsAPI();
      List<dynamic> productsData = [];
      if (response is Map<String, dynamic> && response['data'] != null) {
        if (response['data'] is List) {
          productsData = response['data'] as List<dynamic>;
        }
      } else if (response is List) {
        productsData = response;
      }

      setState(() {
        _topReviewedProducts =
            productsData.map<Map<String, dynamic>>((product) {
              if (product is Map<String, dynamic>) {
                final reviewsList = product['reviews'] as List? ?? [];
                final processedReviews =
                    reviewsList.map((review) {
                      if (review is Map<String, dynamic>) {
                        return {
                          'comment': review['comment'] ?? 'Không có bình luận',
                          'star': review['star'] ?? 5,
                          'customer': {
                            'id': review['customer']?['id'] ?? '',
                            'name': review['customer']?['name'] ?? 'Ẩn danh',
                          },
                          'date': review['date'] ?? '',
                        };
                      }
                      return review;
                    }).toList();

                return {
                  'productId': product['productId'] ?? '',
                  'productName':
                      product['productName'] ?? 'Sản phẩm không xác định',
                  'quantitySold': product['quantitySold'] ?? 0,
                  'reviews': processedReviews,
                };
              }
              return {
                'productId': '',
                'productName': 'Sản phẩm không xác định',
                'quantitySold': 0,
                'reviews': [],
              };
            }).toList();
      });
    } catch (e) {
      print('Error loading top reviewed products: $e');
    }
  }

  Future<void> _loadRevenueData() async {
    try {
      final response = await UserService.getDesignerRevenueByDayAPI(
        _selectedMonth,
        _selectedYear,
      );

      final rawData = response['data'] ?? [];

      final processedData =
          rawData.map<Map<String, dynamic>>((item) {
            return {
              'day': (item['day'] as num?)?.toInt(),
              'revenue': (item['revenue'] as num?)?.toInt(),
            };
          }).toList();

      processedData.sort(
        (a, b) => (a['day'] as int).compareTo(b['day'] as int),
      );

      setState(() {
        _revenueData = processedData;
      });
    } catch (e) {
      print('Error loading revenue data: $e');
    }
  }

  Future<void> _onMonthYearChanged() async {
    setState(() => _isLoading = true);
    await _loadRevenueData();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),

                        _buildStatsGrid(),
                        const SizedBox(height: 24),

                        _buildRevenueSection(),
                        const SizedBox(height: 24),

                        _buildTopProductsAndStatusSection(),
                        const SizedBox(height: 24),

                        _buildTopReviewedProductsSection(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.designerHomepage);
          },
        ),
        const SizedBox(width: 8),
        const Text(
          'Thống kê tổng quan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimaryDarkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Tổng người mua',
          value: _totalCustomers.toString(),
          icon: Icons.group,
          color: const Color(0xFF5B50E5),
          backgroundColor: const Color(0xFFE9E5FB),
          trend: '+8.5%',
          isPositive: true,
        ),
        _buildStatCard(
          title: 'Tổng đơn hàng',
          value: _totalOrders.toString(),
          icon: Icons.inventory,
          color: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFFFDEBD3),
          trend: '+1.3%',
          isPositive: true,
        ),
        _buildStatCard(
          title: 'Tổng doanh thu',
          value: _formatRevenue(_totalRevenue),
          icon: Icons.shopping_cart,
          color: const Color(0xFF22C55E),
          backgroundColor: const Color(0xFFDDF5EC),
          trend: '-4.3%',
          isPositive: false,
        ),
        _buildStatCard(
          title: 'Sản phẩm chờ',
          value: _pendingProducts.toString(),
          icon: Icons.access_time,
          color: const Color(0xFFF97316),
          backgroundColor: const Color(0xFFFFEFE3),
          trend: '+1.8%',
          isPositive: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String trend,
    required bool isPositive,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 10,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'So với hôm qua',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Doanh thu theo ngày trong tháng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryDarkGreen,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text('T${index + 1}'),
                            );
                          }),
                          onChanged: (value) async {
                            if (value != null) {
                              setState(() {
                                _selectedMonth = value;
                              });
                              await _onMonthYearChanged();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          items:
                              [
                                currentYear - 2,
                                currentYear - 1,
                                currentYear,
                              ].map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }).toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              setState(() {
                                _selectedYear = value;
                              });
                              await _onMonthYearChanged();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_revenueData.isEmpty)
              const Center(
                child: Text(
                  'Chưa có dữ liệu doanh thu',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            else
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _revenueData.map((data) {
                          final day = data['day'];
                          final revenue = data['revenue'];
                          final maxRevenue =
                              _revenueData.isNotEmpty
                                  ? _revenueData
                                      .map((e) => e['revenue'] as int)
                                      .reduce((a, b) => a > b ? a : b)
                                  : 1;
                          final heightRatio =
                              maxRevenue > 0 ? (revenue / maxRevenue) : 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF89B9AD),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _formatRevenueShort(revenue),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 20,
                                  height: (heightRatio * 120).clamp(4.0, 120.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF89B9AD),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  day.toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsAndStatusSection() {
    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái đơn hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 16),

                if (_orderStatusData.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Chưa có đơn hàng nào',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      const SizedBox(height: 16),

                      ..._orderStatusData.map((entry) {
                        final color = _getStatusColor(entry['rawStatus']);
                        final percentage =
                            _totalOrders > 0
                                ? (entry['value'] / _totalOrders * 100)
                                    .toStringAsFixed(1)
                                : '0';
                        final value = entry['value'] as int;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry['name'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$value đơn hàng',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$percentage%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top sản phẩm bán chạy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 16),

                if (_topProducts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Chưa có dữ liệu sản phẩm',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        _topProducts.length > 5 ? 5 : _topProducts.length,
                    itemBuilder: (context, index) {
                      final product = _topProducts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4DA8DA),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF4DA8DA,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Đã bán: ${product['sales'] ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF4DA8DA),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopReviewedProductsSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá gần đây theo sản phẩm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimaryDarkGreen,
              ),
            ),
            const SizedBox(height: 16),
            if (_topReviewedProducts.isEmpty)
              const Text(
                'Chưa có đánh giá nào',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    _topReviewedProducts.length > 3
                        ? 3
                        : _topReviewedProducts.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final product = _topReviewedProducts[index];
                  final reviews = product['reviews'] as List? ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['productName'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (reviews.isEmpty)
                        const Text(
                          'Chưa có đánh giá',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      else
                        ...reviews.take(2).map((review) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: kPrimaryDarkGreen
                                      .withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: kPrimaryDarkGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Khách: ${review['customer']?['name'] ?? 'Ẩn danh'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          review['comment'] ??
                                              'Không có bình luận',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      if (review['date'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            review['date'] ?? 'Không rõ ngày',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatRevenue(int revenue) {
    if (revenue >= 1000000) {
      if (revenue % 1000000 == 0) {
        return '${(revenue / 1000000).toInt()}M VNĐ';
      } else {
        return '${(revenue / 1000000).toStringAsFixed(2)}M VNĐ';
      }
    } else if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(1)}K VNĐ';
    } else {
      return '${revenue} VNĐ';
    }
  }

  String _formatRevenueShort(int revenue) {
    if (revenue >= 1000000) {
      return '${(revenue / 1000000).toStringAsFixed(1)}M';
    } else if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(0)}K';
    } else {
      return revenue.toString();
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ xác nhận';
      case 'Processing':
        return 'Đang xử lý';
      case 'Delivered':
        return 'Đã giao hàng';
      case 'Refunded':
        return 'Hoàn tiền';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFF9E9E9E);
      case 'Processing':
        return const Color(0xFFFF9800);
      case 'Delivered':
        return const Color(0xFF347433);
      case 'Refunded':
        return const Color(0xFFFF6F3C);
      case 'Cancelled':
        return const Color(0xFFB22222);
      default:
        return Colors.grey;
    }
  }
}
