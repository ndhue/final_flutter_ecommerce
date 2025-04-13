import 'package:final_ecommerce/screens/home/components/categories_section.dart';
import 'package:final_ecommerce/screens/product/product_catalog.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/widgets_export.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget buildSlider(String title) {
    return ProductListSlider(
      title: title,
      onProductSelected: (product) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(product: product),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                child: Image.asset(
                  'assets/images/banner.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              CategoriesSection(
                onCategorySelected: (category) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductCatalog(category: category),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              buildSlider("Best Sellers"),
              buildSlider("Promotional"),
              buildSlider("New Products"),
            ],
          ),
        ),
      ),
    );
  }
}
