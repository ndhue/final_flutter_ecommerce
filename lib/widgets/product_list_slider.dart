import 'package:final_ecommerce/models/new_product_model.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/screens/product/product_catalog.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'product_card.dart';

class ProductListSlider extends StatefulWidget {
  final String title;
  final Function(NewProduct)? onProductSelected;

  const ProductListSlider({
    super.key,
    required this.title,
    this.onProductSelected,
  });

  @override
  State<ProductListSlider> createState() => _ProductListSliderState();
}

class _ProductListSliderState extends State<ProductListSlider> {
  late ProductProvider productProvider;
  List<NewProduct> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productProvider = Provider.of<ProductProvider>(context, listen: false);
      _fetchProducts();
    });
  }

  Future<void> _fetchProducts() async {
    if (products.isNotEmpty) {
      return; // Prevent re-fetching if products are already loaded
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      switch (widget.title) {
        case 'Best Sellers':
          products = await productProvider.getBestSellers();
          break;
        case 'Promotional':
          products = await productProvider.getPromotionalProducts();
          break;
        case 'New Products':
          products = await productProvider.getNewProducts();
          break;
        default:
          products = [];
      }
    } catch (e) {
      error = e.toString();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductCatalog(category: widget.title),
                  ),
                );
              },
              child: const Text(
                'See All',
                style: TextStyle(color: primaryColor, fontSize: 12),
              ),
            ),
          ],
        ),
        if (isLoading) const ProductListSkeleton(),
        if (error != null) Center(child: Text('Error: $error')),
        if (!isLoading && error == null)
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.take(6).length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    if (widget.onProductSelected != null) {
                      widget.onProductSelected!(product);
                    }
                  },
                  child: SizedBox(
                    width: 180,
                    child: ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetails(product: product),
                          ),
                        );
                      },
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
