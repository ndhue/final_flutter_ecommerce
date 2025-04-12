import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.product});
  final NewProduct product;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late VariantProvider _variantProvider;
  late NewProduct productSelected;
  late NewVariant? variantSelected;
  int _currentImageIndex = 0;
  Color? _selectedColor;
  Variant? _selectedVariant;
  double _rating = 0;
  int _totalReview = 0;
  int _visibleReviews = 5;

  @override
  void initState() {
    super.initState();
    productSelected = widget.product;
    _selectedColor = hexToColor(productSelected.availableColors[0]);
    _rating = productSelected.rating;
    _totalReview = productSelected.totalReviews;
    variantSelected = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _variantProvider = Provider.of<VariantProvider>(context, listen: false);
      _fetchVariantByColor(productSelected.availableColors[0]);
    });
  }

  Future<void> _fetchVariantByColor(String colorCode) async {
    await _variantProvider.fetchVariantByColor(
      productId: productSelected.id,
      colorCode: colorCode,
    );
    setState(() {
      variantSelected = _variantProvider.selectedVariant;
    });
  }

  void _selectColor(Color color) {
    _fetchVariantByColor(colorToHex(color));
    setState(() {
      _selectedColor = color;
    });
  }

  void _nextImage() {
    if (_currentImageIndex < productSelected.images.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
      });
    }
  }

  void _showMoreReviews() {
    setState(() {
      _visibleReviews += 5;
    });
  }

  // void _addToCart(BuildContext context) {
  //   if (_selectedVariant == null) return;
  //   Provider.of<CartProvider>(
  //     context,
  //     listen: false,
  //   ).addToCart(productSelected, _selectedVariant!);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         '${productSelected.name} (${_selectedVariant!.name}) đã được thêm vào giỏ hàng',
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final colors =
        productSelected.availableColors
            .map((colorHex) => hexToColor(colorHex))
            .toSet();

    final List<String> reviewImages = [
      'assets/images/order-1.jpg',
      'assets/images/order-2.jpg',
      'assets/images/order-3.jpg',
    ];

    final hasDiscount = productSelected.discount > 0;
    final discountPercent = (productSelected.discount * 100).round();
    final discountPrice =
        productSelected.sellingPrice * (100 - discountPercent) / 100;

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
                    width:
                        MediaQuery.of(context).size.width > 600
                            ? 500
                            : MediaQuery.of(context).size.width,
                    height: 300,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _currentImageIndex > 0 ? _previousImage : null,
                  ),
                ),
                Positioned(
                  right: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
                    '${productSelected.name} ${variantSelected?.colorName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        FormatHelper.formatCurrency(discountPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          FormatHelper.formatCurrency(
                            productSelected.sellingPrice,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (variantSelected != null &&
                      variantSelected!.inventory == 0) ...[
                    const Text(
                      'Out of stock',
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (colors.isNotEmpty) ...[
                    const Text(
                      'Choose the color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children:
                          colors
                              .map(
                                (color) => GestureDetector(
                                  onTap: () => _selectColor(color),
                                  child: ColorOption(
                                    color,
                                    isSelected: _selectedColor == color,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Description of product',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productSelected.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 8),
                  Text(
                    '($_totalReview reviews)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        _visibleReviews > _totalReview
                            ? _totalReview
                            : _visibleReviews,
                    itemBuilder: (context, index) {
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
                                    'Người dùng $index',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Sản phẩm tuyệt vời!',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  if (reviewImages.length > index &&
                                      reviewImages[index].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
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
                  if (_visibleReviews < _totalReview)
                    TextButton(
                      onPressed: _showMoreReviews,
                      child: const Text(
                        'Read more',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                variantSelected != null && variantSelected!.inventory > 0
                    ? primaryColor
                    : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed:
              variantSelected != null && variantSelected!.inventory > 0
                  ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${productSelected.name} (${variantSelected!.colorName}) đã được thêm vào giỏ hàng',
                        ),
                      ),
                    );
                  }
                  : null,
          child: const Text(
            'Add to Cart',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  const ColorOption(this.color, {super.key, this.isSelected = false});
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
