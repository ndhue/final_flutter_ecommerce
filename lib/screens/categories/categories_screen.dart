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
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          spacing: defaultPadding,
          children: [
            const SearchBarWidget(),
            const SpecialFiltersWidget(),
            const CategoriesGridView(),
          ],
        ),
      ),
    );
  }
}
