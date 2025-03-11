import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/models/category_model.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  final ValueNotifier<Color> _boxColor = ValueNotifier<Color>(
    Colors.transparent,
  );

  CategoryWidget({super.key, required this.category});

  void _changeColor() {
    _boxColor.value =
        _boxColor.value == Colors.transparent
            ? Colors.grey[100]!
            : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeColor,
      behavior: HitTestBehavior.opaque,
      child: ValueListenableBuilder<Color>(
        valueListenable: _boxColor,
        builder: (context, color, child) {
          return Container(
            color: color,
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  'assets/images/categories/${category.icon}',
                  height: 40,
                  width: 40,
                ),
                Text(
                  category.name,
                  style: TextStyle(fontSize: 12, color: iconColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: categories
          .map((category) {
            return CategoryWidget(category: category);
          })
          .toList(growable: false),
    );
  }
}
