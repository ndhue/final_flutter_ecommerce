import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/screens/product/product_catalog.dart';
import 'package:flutter/material.dart';

import 'categories_grid_widget.dart';

class SpecialFiltersWidget extends StatelessWidget {
  const SpecialFiltersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    // Define number of items per row based on screen width
    final itemsPerRow = isLargeScreen ? 6 : 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final calculatedItemWidth = (containerWidth / itemsPerRow) - 10;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.start,
          children:
              specialCategories.map((category) {
                return SizedBox(
                  width: calculatedItemWidth,
                  child: CategoryCard(
                    key: ValueKey(category.name),
                    category: category,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProductCatalog(category: category.name),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
