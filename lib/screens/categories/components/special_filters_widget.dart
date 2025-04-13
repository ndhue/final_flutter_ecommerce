import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/screens/product/product_catalog.dart';
import 'package:flutter/material.dart';

import 'categories_grid_widget.dart';

class SpecialFiltersWidget extends StatelessWidget {
  const SpecialFiltersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, // Horizontal space between items
      runSpacing: 10, // Vertical space between rows
      alignment: WrapAlignment.start,
      children:
          specialCategories.map((category) {
            return SizedBox(
              width:
                  MediaQuery.of(context).size.width / 3 -
                  18, // Ensures 3 items per row
              child: CategoryCard(
                category: category,
                onTap: () {
                  // Handle tap event
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductCatalog(category: category.name),
                    ),
                  );
                },
              ),
            );
          }).toList(),
    );
  }
}
