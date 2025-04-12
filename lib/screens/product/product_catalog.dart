import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:final_ecommerce/screens/product/product_details.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/widgets/product_card.dart';

class ProductCatalog extends StatefulWidget {
  final String category;

  const ProductCatalog({super.key, required this.category});

  @override
  State<ProductCatalog> createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  late ProductProvider _productProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productProvider = Provider.of<ProductProvider>(context, listen: false);
      _fetchInitialProducts();
    });
  }

  Future<void> _fetchInitialProducts() async {
    await _productProvider.fetchProductsByCategory(
      category: widget.category,
      isInitial: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: defaultPadding),
        backgroundColor: Colors.white,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(
                widget.category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [CartButton()],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final filteredProducts = provider.products;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.isLoading && filteredProducts.isEmpty)
                  const Center(child: CircularProgressIndicator()),

                if (!provider.isLoading && filteredProducts.isNotEmpty)
                  Align(
                    child: Text(
                      '${filteredProducts.length} Items',
                      style: TextStyle(fontSize: 16, color: iconColor),
                    ),
                  ),

                const SizedBox(height: 20),

                Expanded(
                  child:
                      provider.isLoading && filteredProducts.isEmpty
                          ? const SizedBox()
                          : filteredProducts.isEmpty
                          ? const Center(
                            child: Text(
                              'No products found.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              ProductDetails(product: product),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.filter_alt, color: iconColor),
                          onPressed: () {},
                        ),
                        const Text('Filter'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.filter_list, color: iconColor),
                          onPressed: () {},
                        ),
                        const Text('Sort by'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
