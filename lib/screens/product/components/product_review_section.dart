import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ProductReviewSection extends StatefulWidget {
  final String productId;
  final List<ProductReview> reviews;

  const ProductReviewSection({
    super.key,
    required this.productId,
    required this.reviews,
  });

  @override
  State<ProductReviewSection> createState() => _ProductReviewSectionState();
}

class _ProductReviewSectionState extends State<ProductReviewSection> {
  final TextEditingController _commentController = TextEditingController();
  double _currentRating = 0.0;
  bool _isLoadingMore = false;
  bool _hasMoreReviews = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMoreReviews) {
      _loadMoreReviews();
    }
  }

  Future<void> _loadMoreReviews() async {
    setState(() {
      _isLoadingMore = true;
    });

    final productProvider = context.read<ProductProvider>();
    final newReviews = await productProvider.fetchProductReviews(
      productId: widget.productId,
      isInitial: false,
    );

    setState(() {
      if (newReviews.isEmpty) {
        _hasMoreReviews = false;
      } else {
        widget.reviews.addAll(newReviews);
      }
      _isLoadingMore = false;
    });
  }

  void _handleSubmit() async {
    final user = context.read<UserProvider>().user;

    if (_commentController.text.isEmpty || user == null) return;

    final productProvider = context.read<ProductProvider>();

    await productProvider.addReview(
      productId: widget.productId,
      username: user.fullName,
      comment: _commentController.text,
      rating: _currentRating > 0 ? _currentRating : null,
    );

    // Reload reviews after adding a new review
    final updatedReviews = await productProvider.fetchProductReviews(
      productId: widget.productId,
      isInitial: true,
    );

    _commentController.clear();
    setState(() {
      _currentRating = 0.0;
      widget.reviews.clear();
      widget.reviews.addAll(updatedReviews);
      _hasMoreReviews = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        /// Rating bar or login hint
        user == null
            ? const Text(
              'Login to rate this product!',
              style: TextStyle(color: Colors.grey),
            )
            : RatingBar.builder(
              initialRating: _currentRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder:
                  (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate:
                  (rating) => setState(() => _currentRating = rating),
            ),
        const SizedBox(height: 8),

        /// Comment input
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Write your comment...',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _handleSubmit,
            ),
          ),
        ),
        const SizedBox(height: 24),

        /// Review list
        if (widget.reviews.isEmpty)
          const Text(
            'No reviews yet. Be the first to review this product!',
            style: TextStyle(color: Colors.grey),
          )
        else
          SizedBox(
            height: 350,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.reviews.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.reviews.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final review = widget.reviews[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  color: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatDateTime(review.createdAt.toDate()),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        if (review.rating != null && review.rating! > 0)
                          RatingBarIndicator(
                            rating: review.rating!.toDouble(),
                            itemBuilder:
                                (context, index) =>
                                    const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 16,
                            direction: Axis.horizontal,
                          ),
                        const SizedBox(height: 4),
                        Text(review.comment),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
