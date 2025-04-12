import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/screens/home/components/categories_section.dart';
import 'package:final_ecommerce/screens/product/product_catalog.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/widgets_export.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<NewProduct>> _productSections = {};
  bool _isLoading = true;
  String? _error;
  late ProductProvider productProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productProvider = Provider.of<ProductProvider>(context, listen: false);
      _fetchAllProducts();
    });
  }

  Future<void> _fetchAllProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await productProvider.fetchProducts();

      _productSections = {
        'Best Sellers': await productProvider.getBestSellers(),
        'Promotional': await productProvider.getPromotionalProducts(),
        'New Products': await productProvider.getNewProducts(),
      };
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildSlider(String title) {
    final products = _productSections[title];

    return ProductListSlider(
      title: title,
      products: products ?? [],
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          defaultBorderRadius,
                        ),
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
                              builder:
                                  (context) =>
                                      ProductCatalog(category: category),
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
