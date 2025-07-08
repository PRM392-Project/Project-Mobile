import 'dart:async';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';

const Color kPrimaryDarkGreen = Color(0xFF3F5139);

class CusDesignerList extends StatefulWidget {
  const CusDesignerList({Key? key}) : super(key: key);

  @override
  State<CusDesignerList> createState() => _CusDesignerListState();
}

class _CusDesignerListState extends State<CusDesignerList> {
  List<dynamic> _originalDesigners = [];
  List<dynamic> _filteredDesigners = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchDesigners();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchDesigners() async {
    setState(() => _isLoading = true);
    try {
      final response = await UserService.getAllAccounts(role: 1);
      if (response != null &&
          response["statusCode"] == 200 &&
          response["data"]?["items"] != null) {
        final items = response["data"]["items"];
        setState(() {
          _originalDesigners = items;
          _filteredDesigners = items;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách designer: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      String keyword = _searchController.text.trim().toLowerCase();
      setState(() {
        _filteredDesigners = _originalDesigners.where((designer) {
          final name = (designer['name'] ?? '').toLowerCase();
          final email = (designer['email'] ?? '').toLowerCase();
          return name.contains(keyword) || email.contains(keyword);
        }).toList();
      });
    });
  }

  Widget _buildDesignerGrid() {
    if (_filteredDesigners.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy nhà thiết kế nào',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDesigners.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final designer = _filteredDesigners[index];
        final avatar = designer['avatarSource'];
        final name = designer['name'] ?? 'Chưa có tên';
        final email = designer['email'] ?? '';

        return GestureDetector(
          onTap: () {
            final designerId = designer['id'];
            Navigator.pushNamed(
              context,
              AppRoutes.customerDesignerProduct,
              arguments: designerId,
            );
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
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: const Color(0xFFBCD4B5),
                  ),
                  child: avatar != null && avatar.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 40, color: Colors.white54),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                          textAlign: TextAlign.center,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.customerHomepage);
                    },
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDesignerGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
