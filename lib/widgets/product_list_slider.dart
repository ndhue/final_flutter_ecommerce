import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'product_card.dart';

class ProductListSlider extends StatelessWidget {
  final String title;
  final List<Product> products;
  final VoidCallback? onSeeAllPressed;

  const ProductListSlider({
    super.key,
    required this.title,
    required this.products,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Take at most 6 products
    final displayProducts = products.take(6).toList();

    return Column(
      children: [
        // Header with title and see all button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: onSeeAllPressed,
              child: const Text(
                'See All',
                style: TextStyle(color: primaryColor, fontSize: 12),
              ),
            ),
          ],
        ),
        // Horizontal scrollable product list
        SizedBox(
          height: 220, // Fixed height for consistency
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayProducts.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 180, // Fixed width for each product card
                child: ProductCard(product: displayProducts[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
