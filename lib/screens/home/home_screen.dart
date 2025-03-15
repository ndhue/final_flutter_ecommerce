import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/screens/home/components/categories_section.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/widgets_export.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? navigateToCategories;
  const HomeScreen({super.key, this.navigateToCategories});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              // Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                child: Image.asset(
                  'assets/images/banner.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              CategoriesSection(
                navigateToCategories: widget.navigateToCategories ?? () {},
              ),
              ProductListSlider(title: "Popular", products: products),
              ProductListSlider(title: "Discount", products: products),
            ],
          ),
        ),
      ),
    );
  }
}
