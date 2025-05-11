import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class CategoriesGridView extends StatelessWidget {
  final Function(String) onCategorySelected;
  final int gridCrossAxisCount;

  const CategoriesGridView({
    Key? key,
    required this.onCategorySelected,
    this.gridCrossAxisCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate item width based on available width
        final spacing = 10.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (gridCrossAxisCount - 1))) /
            gridCrossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: 10,
          children:
              categories.map((category) {
                return SizedBox(
                  key: ValueKey(category.name),
                  width: itemWidth,
                  child: CategoryCard(
                    category: category,
                    onTap: () => onCategorySelected(category.name),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        onTap: onTap, // Gọi callback khi click
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              category.icon != null
                  ? category.icon!
                  : Image.asset(
                    'assets/images/categories/${category.image}',
                    height: 40,
                    width: 40,
                  ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: const TextStyle(fontSize: 12, color: iconColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
