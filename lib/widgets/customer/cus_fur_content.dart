import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../routes/app_routes.dart';
import '../../services/user_service.dart';
import 'package:intl/intl.dart';

const Color kPrimaryDarkGreen = Color(0xFF3F5139);

class CusFurContent extends StatefulWidget {
  const CusFurContent({Key? key}) : super(key: key);

  @override
  State<CusFurContent> createState() => _CusFurContentState();
}

class _CusFurContentState extends State<CusFurContent> {
  List<dynamic> _originalDesigns = [];
  List<dynamic> _filteredDesigns = [];
  String _sortBy = 'price';
  bool _isAscending = true;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchFurnitures();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String formatCurrency(double amount) {
    final formatter =
    NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(amount);
  }

  Future<void> _fetchFurnitures() async {
    setState(() => _isLoading = true);

    try {
      final response = await UserService.getAllFurnitures();
      if (response != null && response['data'] != null) {
        List<dynamic> items = response['data']['items'];
        List<dynamic> approvedProducts = [];

        for (var item in items) {
          final detailResponse = await UserService.getProductById(item['id']);
          if (detailResponse?['data']?['approved'] == true) {
            approvedProducts.add(item);
          }
        }

        setState(() {
          _originalDesigns = approvedProducts;
          _filteredDesigns = approvedProducts;
          _applySorting();
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      String keyword = _searchController.text.trim().toLowerCase();
      setState(() {
        _filteredDesigns = _originalDesigns.where((item) {
          return (item['name'] ?? '').toLowerCase().contains(keyword);
        }).toList();
        _applySorting();
      });
    });
  }

  void _applySorting() {
    _filteredDesigns.sort((a, b) {
      final aValue = a[_sortBy] ?? 0;
      final bValue = b[_sortBy] ?? 0;
      return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  void _onSortChange(String field) {
    setState(() {
      if (_sortBy == field) {
        _isAscending = !_isAscending;
      } else {
        _sortBy = field;
        _isAscending = true;
      }
      _applySorting();
    });
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kPrimaryDarkGreen, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSortOption('Giá', 'price', isFirst: true),
          _buildSortOption('Lượt mua', 'purchaseCount'),
          _buildSortOption('Đánh giá', 'rating', isLast: true),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String field,
      {bool isFirst = false, bool isLast = false}) {
    final isActive = _sortBy == field;
    final icon = isActive
        ? (_isAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.unfold_more;

    return Expanded(
      child: InkWell(
        onTap: () => _onSortChange(field),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              right: isLast
                  ? BorderSide.none
                  : BorderSide(color: kPrimaryDarkGreen, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: kPrimaryDarkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: kPrimaryDarkGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_filteredDesigns.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy sản phẩm phù hợp',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: _filteredDesigns.length,
      itemBuilder: (context, index) {
        final item = _filteredDesigns[index];
        final id = item['id'];
        final name = item['name'] ?? '';
        final price = item['price'] ?? 0;
        final rating = item['rating'] ?? 0;
        final imageSource = item['primaryImage']?['imageSource'];

        return GestureDetector(
          onTap: () async {
            final response = await UserService.getProductById(id);
            if (response?['data'] != null) {
              Navigator.pushNamed(
                context,
                AppRoutes.customerFurDetail,
                arguments: response['data'],
              );
            }
          },
          child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBCD4B5),
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: imageSource != null && imageSource.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child:
                    Image.network(imageSource, fit: BoxFit.contain),
                  )
                      : const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 40, color: Colors.white54),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Giá: ${formatCurrency(price)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 12),
                            const SizedBox(width: 4),
                            Text('$rating', style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // 🏷️ Style + Categories hiển thị tag
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final style = item['style']?['name']?.toString();
                              final categories = (item['categories'] as List<dynamic>? ?? [])
                                  .map((cat) => cat['name'].toString())
                                  .toList();
                              final List<String> allTags = [];
                              if (style != null) allTags.add(style);
                              allTags.addAll(categories);

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: allTags.map((tag) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E0E0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.customerHomepage);
                    },
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          hintText: 'Tìm kiếm...',
                          fillColor: Colors.grey[200],
                          filled: true,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSortBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
