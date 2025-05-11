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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;
    final horizontalPadding =
        isLargeScreen
            ? screenWidth *
                0.1 // 10% of screen width on large screens
            : defaultPadding;
    final verticalPadding = isLargeScreen ? defaultPadding * 2 : defaultPadding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner with constraints for web
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 1000 : double.infinity,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                    child: Image.asset(
                      'assets/images/banner.png',
                      width: double.infinity,
                      height: isLargeScreen ? 300 : 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Center categories for better web display
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 1000 : double.infinity,
                  ),
                  child: CategoriesSection(
                    onCategorySelected: (category) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductCatalog(category: category),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Product sliders with constraints
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 1000 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSlider("Best Sellers"),
                      SizedBox(height: verticalPadding),
                      buildSlider("Promotional"),
                      SizedBox(height: verticalPadding),

                      buildSlider("New Products"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
