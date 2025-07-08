import 'package:flutter/material.dart';
import '../../../services/user_service.dart';

class ReviewContent extends StatefulWidget {
  final String productId;
  final List<Map<String, dynamic>> reviews;
  final VoidCallback onSubmitted;

  const ReviewContent({
    Key? key,
    required this.productId,
    required this.reviews,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  State<ReviewContent> createState() => _ReviewContentState();
}

class _ReviewContentState extends State<ReviewContent> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedStar = 5;
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final response = await UserService.reviewProduct(
      productId: widget.productId,
      comment: comment,
      star: _selectedStar,
    );

    if (response != null && response['success'] == true) {
      setState(() {
        _commentController.clear();
        _selectedStar = 5;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi đánh giá thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      widget.onSubmitted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi đánh giá thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                icon: Icon(
                  star <= _selectedStar ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _selectedStar = star;
                  });
                },
              );
            }),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập bình luận...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F5139),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi đánh giá'),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // --- ĐƯỜNG KẺ NGĂN CÁCH ---
        const Divider(thickness: 1.2),

        const SizedBox(height: 16),
        // --- DANH SÁCH ĐÁNH GIÁ ---
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Đánh giá của khách hàng khác',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        ...widget.reviews.map((review) {
          final userName = review['customer']?['name'] ?? 'Người dùng';
          final rating = review['star'] ?? 0;
          final comment = review['comment'] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên người dùng + sao
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Bình luận trong khung
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFBCD4B5),
                    ),
                    child: Text(
                      comment,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 16),
      ],
    );
  }
}
