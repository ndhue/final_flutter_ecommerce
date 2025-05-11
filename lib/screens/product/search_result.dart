import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:final_ecommerce/screens/product/product_details.dart';
import 'package:final_ecommerce/utils/constants.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: isLargeScreen,
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
        title:
            isLargeScreen
                ? Container(
                  width: screenWidth * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search products...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        searchQuery = value.isEmpty ? "Search result" : value;
                      });
                      _fetchSearchResults();
                    },
                  ),
                )
                : TextField(
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 1200 : double.infinity,
          ),
          child: Consumer<ProductProvider>(
            builder: (context, provider, child) {
              final filteredProducts = provider.products;

              return Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isLargeScreen ? 16.0 : 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Search result for "$searchQuery"',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 24 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              if (!filteredProducts.isEmpty)
                                Text(
                                  '${filteredProducts.length} items',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isLargeScreen ? 16 : 14,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.sort,
                                  color: Colors.black,
                                ),
                                onPressed: onSortPressed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child:
                          filteredProducts.isEmpty
                              ? _buildEmptyResultsView()
                              : _buildProductGrid(
                                filteredProducts,
                                isLargeScreen,
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResultsView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products found for "$searchQuery"',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try using different keywords or browse categories',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              searchController.clear();
              Navigator.pushReplacementNamed(context, categoriesScreenRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Browse Categories'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<NewProduct> products, bool isLargeScreen) {
    final crossAxisCount = isLargeScreen ? 4 : 2;
    final spacing = isLargeScreen ? 20.0 : 10.0;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetails(product: product),
              ),
            );
          },
          imgWidth: isLargeScreen ? 250 : 100,
        );
      },
    );
  }
}
