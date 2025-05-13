import 'package:final_ecommerce/screens/product/product_catalog.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

import 'components/categories_grid_widget.dart';
import 'components/search_bar_widget.dart';
import 'components/special_filters_widget.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Material(
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 1000 : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isLargeScreen ? defaultPadding * 1.5 : defaultPadding,
            ),
            child: Column(
              children: [
                const SearchBarWidget(),
                const SizedBox(height: defaultPadding),
                const SpecialFiltersWidget(),
                const SizedBox(height: defaultPadding),
                Expanded(
                  child: CategoriesGridView(
                    onCategorySelected: (category) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductCatalog(category: category),
                        ),
                      );
                    },
                    gridCrossAxisCount: isLargeScreen ? 6 : 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
