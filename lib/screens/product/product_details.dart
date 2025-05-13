import 'dart:async';

import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:final_ecommerce/widgets/widgets_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'components/product_review_section.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, this.product, this.productId});
  final NewProduct? product;
  final String? productId;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late VariantProvider _variantProvider;
  late ProductProvider _productProvider;
  NewProduct? productSelected;
  NewVariant? variantSelected;
  int _currentImageIndex = 0;
  Color? _selectedColor;
  double _rating = 0;
  int _totalReview = 0;
  List<ProductReview> _reviews = [];
  bool _isLoadingReviews = true;
  Timer? _reviewCheckTimer;
  bool _isCheckingForNewReviews = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _variantProvider = Provider.of<VariantProvider>(context, listen: false);
      _productProvider = Provider.of<ProductProvider>(context, listen: false);

      if (widget.product != null) {
        _initializeProduct(widget.product!);
      } else if (widget.productId != null) {
        await _fetchProductDetails(widget.productId!);
      }

      _startReviewCheckTimer();
    });
  }

  @override
  void dispose() {
    _reviewCheckTimer?.cancel();
    super.dispose();
  }

  void _handleReviewAdded() {
    _refreshProductDetails();
  }

  Future<void> _refreshProductDetails() async {
    if (productSelected == null) return;

    try {
      await _productProvider.reloadProduct(productSelected!.id);

      final updatedProduct = await _productProvider.fetchProductById(
        productSelected!.id,
      );

      if (mounted) {
        setState(() {
          productSelected = updatedProduct;
          _rating = updatedProduct.rating;
          _totalReview = updatedProduct.totalReviews;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing product details: $e');
    }
  }

  void _startReviewCheckTimer() {
    _reviewCheckTimer = Timer.periodic(const Duration(seconds: 15), (
      timer,
    ) async {
      // Prevent concurrent checks
      if (_isCheckingForNewReviews || !mounted || productSelected == null) {
        return;
      }

      _isCheckingForNewReviews = true;

      try {
        final hasNewReviews = await _productProvider.checkForNewReviews(
          productSelected!.id,
        );

        if (hasNewReviews && mounted) {
          await _refreshReviewsOnly();
        }
      } finally {
        if (mounted) {
          _isCheckingForNewReviews = false;
        }
      }
    });
  }

  Future<void> _refreshReviewsOnly() async {
    if (!mounted || productSelected == null) return;

    try {
      final reviews = await _productProvider.fetchProductReviews(
        productId: productSelected!.id,
        isInitial: true,
      );

      final updatedProduct = await _productProvider.fetchProductById(
        productSelected!.id,
      );

      if (mounted) {
        setState(() {
          productSelected = updatedProduct;
          _rating = updatedProduct.rating;
          _totalReview = updatedProduct.totalReviews;
          _reviews = List<ProductReview>.from(reviews);
        });
      }
    } catch (e) {
      debugPrint('Error refreshing reviews: $e');
    }
  }

  Future<void> _fetchProductDetails(String productId) async {
    final fetchedProduct = await _productProvider.fetchProductById(productId);
    _initializeProduct(fetchedProduct);
  }

  void _initializeProduct(NewProduct product) {
    setState(() {
      productSelected = product;
      _selectedColor = hexToColor(product.availableColors[0]);
      _rating = product.rating;
      _totalReview = product.totalReviews;
      variantSelected = null;
    });
    _fetchVariantByColor(product.availableColors[0]);
    _fetchProductReviews();
  }

  Future<void> _fetchVariantByColor(String colorCode) async {
    await _variantProvider.fetchVariantByColor(
      productId: productSelected!.id,
      colorCode: colorCode,
    );
    setState(() {
      variantSelected = _variantProvider.selectedVariant;
    });
  }

  Future<void> _fetchProductReviews() async {
    if (!mounted) return;

    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final reviews = await _productProvider.fetchProductReviews(
        productId: productSelected!.id,
        isInitial: true,
      );

      if (mounted) {
        setState(() {
          _reviews = List<ProductReview>.from(reviews);
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
      debugPrint('Error fetching product reviews: $e');
    }
  }

  void _selectColor(Color color) {
    debugPrint('Selected color: ${colorToHex(color)}');
    _fetchVariantByColor(colorToHex(color));
    setState(() {
      _selectedColor = color;
    });
  }

  void _nextImage() {
    if (_currentImageIndex < productSelected!.images.length - 1) {
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

  void _addToCart(BuildContext context) {
    Provider.of<CartProvider>(context, listen: false).addToCart(
      CartItem(
        product: CartProduct(
          id: productSelected!.id,
          name: productSelected!.name,
          imageUrl: productSelected!.images[0],
          price: productSelected!.sellingPrice,
          discount: productSelected!.discount,
        ),
        variant: CartVariant(
          variantId: variantSelected!.variantId,
          colorCode: variantSelected!.colorCode,
          colorName: variantSelected!.colorName,
        ),
        quantity: 1,
      ),
    );
    Fluttertoast.showToast(
      msg:
          '${productSelected!.name} (${variantSelected!.colorName}) has been added to the cart',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (productSelected == null) {
      return const Scaffold(body: ProductDetailsSkeleton());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    final colors =
        productSelected!.availableColors
            .map((colorHex) => hexToColor(colorHex))
            .toSet();

    final hasDiscount = productSelected!.discount > 0;
    final discountPercent = (productSelected!.discount * 100).round();
    final discountPrice =
        productSelected!.sellingPrice * (100 - discountPercent) / 100;

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: defaultPadding),
        backgroundColor: Colors.white,
        title: const Text(
          'Details Product',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: isLargeScreen,
        actions: [CartButton()],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 1200 : double.infinity,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
              child:
                  isLargeScreen
                      ? _buildLargeScreenLayout(
                        colors,
                        hasDiscount,
                        discountPrice,
                        discountPercent,
                      )
                      : _buildMobileLayout(
                        colors,
                        hasDiscount,
                        discountPrice,
                        discountPercent,
                      ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? 1200 : double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isLargeScreen ? 200 : 16.0,
            16.0,
            isLargeScreen ? 200 : 16.0,
            32.0,
          ),
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
                      _addToCart(context);
                    }
                    : null,
            child: const Text(
              'Add to Cart',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(
    Set<Color> colors,
    bool hasDiscount,
    double discountPrice,
    int discountPercent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImageSection(),
              const SizedBox(height: 40),
              _buildReviewSection(),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${productSelected!.name} ${variantSelected?.colorName}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    FormatHelper.formatCurrency(discountPrice),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 12),
                    Text(
                      FormatHelper.formatCurrency(
                        productSelected!.sellingPrice,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (variantSelected != null &&
                  variantSelected!.inventory == 0) ...[
                const Text(
                  'Out of stock',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                const SizedBox(height: 16),
              ],
              if (colors.isNotEmpty) ...[
                const Text(
                  'Choose the color',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12.0,
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
              const SizedBox(height: 24),
              _buildRatingIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Description of product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                productSelected!.description,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    Set<Color> colors,
    bool hasDiscount,
    double discountPrice,
    int discountPercent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImageSection(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${productSelected!.name} ${variantSelected?.colorName}',
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
                        productSelected!.sellingPrice,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              _buildRatingIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Description of product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                productSelected!.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildReviewSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImageSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.network(
                productSelected!.images[_currentImageIndex],
                width: isLargeScreen ? 500 : screenWidth,
                height: isLargeScreen ? 450 : 300,
                fit: BoxFit.contain,
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
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                onPressed: _currentImageIndex > 0 ? _previousImage : null,
              ),
            ),
            Positioned(
              right: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black54,
                ),
                onPressed:
                    _currentImageIndex < productSelected!.images.length - 1
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
            productSelected!.images.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentImageIndex == index ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              ignoreGestures: true,
              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder:
                  (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {},
            ),
            const SizedBox(width: 8),
            Text(
              '$_rating/5.0',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '($_totalReview reviews)',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return _isLoadingReviews
        ? const Center(child: CircularProgressIndicator())
        : ProductReviewSection(
          productId: productSelected!.id,
          reviews: _reviews,
          onReviewAdded: _handleReviewAdded,
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
