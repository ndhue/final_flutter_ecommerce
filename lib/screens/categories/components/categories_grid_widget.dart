import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class CategoriesGridView extends StatelessWidget {
  const CategoriesGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, // Horizontal space between items
      runSpacing: 10, // Vertical space between rows
      alignment: WrapAlignment.start, // Center align items
      children:
          categories.map((category) {
            return SizedBox(
              width:
                  MediaQuery.of(context).size.width / 3 -
                  18, // Ensures 3 items per row
              child: CategoryCard(category: category),
            );
          }).toList(),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        onTap: () => {},
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
