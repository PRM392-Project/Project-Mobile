import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';
import 'package:intl/intl.dart';

class DesFurDetailContent extends StatefulWidget {
  final Map<String, dynamic> product;

  const DesFurDetailContent({Key? key, required this.product})
    : super(key: key);

  @override
  State<DesFurDetailContent> createState() => _DesFurDetailContentState();
}

class _DesFurDetailContentState extends State<DesFurDetailContent> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isEditing = false;
  bool _isLoading = false;
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _loadProduct(widget.product);
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.product['name'] ?? '');
    _priceController = TextEditingController(text: (widget.product['price'] ?? 0).toString());
    _descriptionController = TextEditingController(text: widget.product['description'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadProduct(Map<String, dynamic> productData) {
    setState(() {
      _reviews = List<Map<String, dynamic>>.from(productData['reviews'] ?? []);
    });
  }

  Future<void> _updateProduct() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || priceText.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giá phải là số dương')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await UserService.updateProduct(
        productId: widget.product['id'].toString(),
        name: name,
        price: price,
        description: description,
      );

      if (response != null) {
        // Cập nhật lại dữ liệu local
        widget.product['name'] = name;
        widget.product['price'] = price;
        widget.product['description'] = description;
        
        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật sản phẩm thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Reset lại giá trị ban đầu
      _nameController.text = widget.product['name'] ?? '';
      _priceController.text = (widget.product['price'] ?? 0).toString();
      _descriptionController.text = widget.product['description'] ?? '';
    });
  }



  String formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatCurrency.format(amount);
  }



  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = _isEditing ? _nameController.text : (product['name'] ?? '');
    final price = _isEditing 
        ? (double.tryParse(_priceController.text) ?? product['price'] ?? 0)
        : (product['price'] ?? 0);
    final rating = product['rating'] ?? 0;
    final imageSource = product['primaryImage']?['imageSource'];
    final description = _isEditing ? _descriptionController.text : (product['description'] ?? '');
    final designerName = product['designer']?['name'] ?? 'Không rõ';

    const mainTextColor = Color(0xFF3F5139);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.designerFurniture,
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _isEditing
                        ? TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: mainTextColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tên sản phẩm',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          )
                        : Text(
                            name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: mainTextColor,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: const Color(0xFFBCD4B5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          imageSource != null
                              ? Image.network(
                                imageSource,
                                width: double.infinity,
                                height: 270,
                                fit: BoxFit.contain,
                              )
                              : Container(
                                width: double.infinity,
                                height: 220,
                                color: const Color(0xFFBCD4B5),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _isEditing
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Giá:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _priceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: 'Nhập giá sản phẩm',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          suffixText: 'VND',
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Giá:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        formatCurrency(price),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 20),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (product['style']?['name'] != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        product['style']['name'],
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                    ),
                                  ...((product['categories'] ?? []) as List<dynamic>).map<Widget>((cat) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        cat['name'] ?? '',
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        const Text(
                          'Mô tả sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _isEditing
                            ? TextField(
                                controller: _descriptionController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Nhập mô tả sản phẩm',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              )
                            : Text(
                                description.isNotEmpty
                                    ? description
                                    : 'Chưa có mô tả.',
                                style: const TextStyle(fontSize: 16, height: 1.5),
                              ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$rating / 5.0',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Nút chỉnh sửa
                        Row(
                          children: [
                            if (!_isEditing)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Chỉnh sửa'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF40543C),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            if (_isEditing) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _updateProduct,
                                  icon: _isLoading 
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(_isLoading ? 'Đang lưu...' : 'Lưu'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF40543C),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _cancelEdit,
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Hủy'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                'Đánh giá',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Hiển thị danh sách đánh giá
            if (_reviews.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review['customer']?['name'] ?? 'Khách hàng',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  Icons.star,
                                  size: 16,
                                  color: i < (review['star'] ?? 0)
                                      ? Colors.orange
                                      : Colors.grey[300],
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review['comment'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (_reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Chưa có đánh giá nào.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 