import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/models/category_model.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class CategoriesSection extends StatelessWidget {
  final VoidCallback navigateToCategories;
  CategoriesSection({super.key, required this.navigateToCategories});

  // Create a new Category instance for the "All" category
  final allCategory = Category(
    id: 'all',
    name: 'All',
    image: 'all.png',
    description: 'All categories',
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...categories.take(4).map((category) {
          return CategoryWidget(category: category);
        }),
        CategoryWidget(category: allCategory, navigate: navigateToCategories),
      ],
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final Category category;
  final VoidCallback? navigate;

  const CategoryWidget({super.key, required this.category, this.navigate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 70,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: navigate ?? () => debugPrint('Navigate to ${category.name}'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(
              'assets/images/categories/${category.image}',
              height: 36,
              width: 36,
            ),
            Text(
              category.name,
              style: TextStyle(fontSize: 12, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}
