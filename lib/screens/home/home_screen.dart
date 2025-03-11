import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/screens/home/components/categories_section.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/widgets_export.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
            children: [
              // Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                child: Image.asset(
                  'assets/images/banner.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              CategoriesSection(),
              ProductListSlider(title: "Popular", products: products),
              ProductListSlider(title: "Discount", products: products),
            ],
          ),
        ),
      ),
    );
  }
}
