import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:final_ecommerce/screens/product/product_details.dart';
import 'package:final_ecommerce/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/routes/route_constants.dart';
import '/widgets/buttons/cart_button.dart';
import 'components/filter_section.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({super.key});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "Search result";
  String _selectedSortOption = 'sellingPrice_asc';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          searchQuery = args;
          searchController.text = args;
        });
        _fetchSearchResults();
      });
    }
  }

  void _fetchSearchResults() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.fetchProductsByKeyword(
      keyword: searchQuery,
      orderBy: _selectedSortOption.split('_')[0],
      descending: _selectedSortOption.contains('_desc'),
      isInitial: true,
    );
  }

  void onSortPressed() {
    showSortByBottomSheet(context, (sortOption) {
      setState(() {
        _selectedSortOption = sortOption;
      });
      _fetchSearchResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, categoriesScreenRoute);
            }
          },
        ),
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          onSubmitted: (value) {
            setState(() {
              searchQuery = value.isEmpty ? "Search result" : value;
            });
            _fetchSearchResults();
          },
        ),
        actions: const [CartButton()],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final filteredProducts = provider.products;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search result for "$searchQuery"',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort, color: Colors.black),
                      onPressed: onSortPressed,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      filteredProducts.isEmpty
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
              ],
            ),
          );
        },
      ),
    );
  }
}
