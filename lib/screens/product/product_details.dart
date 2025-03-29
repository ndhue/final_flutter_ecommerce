import 'package:final_ecommerce/providers/cart_provider.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.product});

  final Product product;

  @override
  // ignore: library_private_types_in_public_api
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Product productSelected;
  int _currentImageIndex = 0;
  String? _selectedStorage;
  Color? _selectedColor;
  double _rating = 0;
  int _totalReview = 0;
  int _visibleReviews = 5;
  @override
  void initState() {
    super.initState();
    productSelected = widget.product;
    _selectedColor =
        productSelected.variants.isNotEmpty
            ? productSelected.variants[0].color
            : null;
    _selectedStorage =
        productSelected.variants.isNotEmpty
            ? productSelected.variants[0].name
            : null;
    _rating = productSelected.rating;
    _totalReview = productSelected.totalReviews;
    //_comment =productSelected.
  }

  void _nextImage() {
    if (_currentImageIndex < productSelected.images.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  void _showMoreReviews() {
    setState(() {
      _visibleReviews += 5; // Tăng số lượng bình luận hiển thị thêm 5
    });
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _selectStorage(String storage) {
    setState(() {
      _selectedStorage = storage;
    });
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasColorOptions = productSelected.variants.any(
      (variant) => variant.isColor,
    );

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: defaultPadding),
        backgroundColor: Colors.white,
        title: const Text(
          'Details Product',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [CartButton()],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Image.network(
                    productSelected.images[_currentImageIndex],
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _currentImageIndex > 0 ? _previousImage : null,
                  ),
                ),
                Positioned(
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed:
                        _currentImageIndex < productSelected.images.length - 1
                            ? _nextImage
                            : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                productSelected.images.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentImageIndex == index
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productSelected.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${productSelected.variants[0].sellingPrice}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (hasColorOptions) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Choose the color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children:
                          productSelected.variants
                              .where((variant) => variant.isColor)
                              .map(
                                (variant) => GestureDetector(
                                  onTap:
                                      () => _selectColor(
                                        variant.color ?? Colors.transparent,
                                      ),
                                  child: ColorOption(
                                    variant.color ?? Colors.transparent,
                                    isSelected: _selectedColor == variant.color,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Choose the storage',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 10.0,
                    children:
                        productSelected.variants.map((variant) {
                          return GestureDetector(
                            onTap: () => _selectStorage(variant.name),
                            child: StorageOption(
                              variant.name,
                              isSelected: _selectedStorage == variant.name,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description of product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productSelected.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Rating Section
                  const Text(
                    'Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 24,
                        itemPadding: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                        ),
                        itemBuilder:
                            (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_rating/5',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Comment Section
                  Text(
                    '($_totalReview reviews)', // Hiển thị tổng số đánh giá
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _visibleReviews>_totalReview ?_totalReview :_visibleReviews, // Replace with actual comment count
                    itemBuilder: (context, index) {
                      // Dữ liệu mẫu cho ảnh (thay bằng dữ liệu thực tế)
                      final List<String> reviewImages = [
                        '/assets/images/review-1.jpg',
                        '/assets/images/order-2.jpg',
                        '',
                        '/assets/images/order-3.jpg',

                        '',
                        '/assets/images/review-1.jpg'
                      ];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Anonymous Participant $index',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Hàng xịn.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  // Hiển thị ảnh nếu có
                                  if (reviewImages[index].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        reviewImages[index],
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
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

                  if (_visibleReviews <
                      _totalReview) // Hiển thị nút "Xem thêm" nếu còn bình luận chưa hiển thị
                    TextButton(
                      onPressed: _showMoreReviews,
                      child: const Text(
                        'Xem thêm',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            Provider.of<CartProvider>(
              context,
              listen: false,
            ).addToCart(productSelected);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${productSelected.name} đã được thêm vào giỏ hàng',
                ),
              ),
            );
          },
          child: const Text(
            'Add to Cart',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class StorageOption extends StatelessWidget {
  final String storage;
  const StorageOption(this.storage, {this.isSelected = false});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: 2,
        ),
      ),
      child: Text(
        storage,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  const ColorOption(this.color, {this.isSelected = false});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: 2,
        ),
      ),
    );
  }
}
