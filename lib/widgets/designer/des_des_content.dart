import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_routes.dart';
import '../../services/user_service.dart';

const Color kPrimaryDarkGreen = Color(0xFF3F5139);

class DesDesContent extends StatefulWidget {
  const DesDesContent({Key? key}) : super(key: key);

  @override
  State<DesDesContent> createState() => _DesDesContentState();
}

class _DesDesContentState extends State<DesDesContent> {
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
    _fetchDesigns();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Future<void> _fetchDesigns() async {
    setState(() => _isLoading = true);
    final response = await UserService.getAllDesignsByDes();
    if (response != null && response['data'] != null) {
      setState(() {
        _originalDesigns = response['data']['items'];
        _filteredDesigns = List.from(_originalDesigns);
        _applySorting();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleActiveStatus(String designId, bool currentStatus) async {
    try {
      final response = await UserService.updateStatusDesignAPI(
        designId,
        !currentStatus,
      );

      if (response != null) {
        setState(() {
          final originalIndex = _originalDesigns.indexWhere(
            (design) => design['id'] == designId,
          );
          if (originalIndex != -1) {
            _originalDesigns[originalIndex]['active'] = !currentStatus;
          }

          final filteredIndex = _filteredDesigns.indexWhere(
            (design) => design['id'] == designId,
          );
          if (filteredIndex != -1) {
            _filteredDesigns[filteredIndex]['active'] = !currentStatus;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentStatus ? 'Đã hiển thị sản phẩm' : 'Đã ẩn sản phẩm',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: kPrimaryDarkGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Có lỗi xảy ra khi cập nhật trạng thái',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Có lỗi xảy ra khi cập nhật trạng thái',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      String keyword = _searchController.text.trim().toLowerCase();
      setState(() {
        _filteredDesigns =
            _originalDesigns.where((item) {
              return (item['name'] ?? '').toLowerCase().contains(keyword);
            }).toList();
        _applySorting();
      });
    });
  }

  void _applySorting() {
    setState(() {
      _filteredDesigns.sort((a, b) {
        final aVal = a[_sortBy] ?? 0;
        final bVal = b[_sortBy] ?? 0;
        return _isAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      });
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

  Widget _buildSortOption(
    String label,
    String field, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isActive = _sortBy == field;
    final icon =
        isActive
            ? (_isAscending ? Icons.arrow_upward : Icons.arrow_downward)
            : Icons.unfold_more;

    return Expanded(
      child: InkWell(
        onTap: () => _onSortChange(field),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              right:
                  isLast
                      ? BorderSide.none
                      : BorderSide(color: kPrimaryDarkGreen, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
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

  Widget _buildDesignList() {
    if (_filteredDesigns.isEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy thiết kế phù hợp",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDesigns.length,
      itemBuilder: (context, index) {
        final item = _filteredDesigns[index];
        final name = item['name'] ?? '';
        final price = item['price'] ?? 0;
        final rating = item['rating'] ?? 0;
        final imageSource = item['primaryImage']?['imageSource'];
        final isActive = item['active'] ?? true;
        final designId = item['id'] ?? '';

        return GestureDetector(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Stack(
              children: [
                SizedBox(
                  height: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Container(
                            color: const Color(0xFFBCD4B5),
                            child:
                                imageSource != null && imageSource.isNotEmpty
                                    ? Image.network(
                                      imageSource,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    )
                                    : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.white54,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Giá: ${formatCurrency(price)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$rating',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleActiveStatus(designId, isActive),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isActive ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
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
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.designerHomepage,
                      );
                    },
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
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
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildDesignList(),
            ),
          ],
        ),
      ),
    );
  }
}
