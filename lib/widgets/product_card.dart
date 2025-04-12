import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:flutter/material.dart';

import '../models/models_export.dart';

class ProductCard extends StatelessWidget {
  final NewProduct product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount > 0;
    final discountPercent = (product.discount * 100).round();
    final discountPrice = product.sellingPrice * (100 - discountPercent) / 100;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.network(
                  product.images.first,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (hasDiscount)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: errorColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-$discountPercent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: darkTextColor),
                ),
                SizedBox(
                  height: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatHelper.formatCurrency(discountPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),
                      if (hasDiscount)
                        Text(
                          FormatHelper.formatCurrency(product.sellingPrice),
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name} đã được thêm vào giỏ hàng',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text("Add to Cart"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
