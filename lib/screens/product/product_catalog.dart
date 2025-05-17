import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:final_ecommerce/screens/product/components/filter_section.dart';
import 'package:final_ecommerce/screens/product/product_details.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/widgets/product_card.dart';
import '/widgets/skeletons.dart';

class ProductCatalog extends StatefulWidget {
  final String category;

  const ProductCatalog({super.key, required this.category});

  @override
  State<ProductCatalog> createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  late ProductProvider _productProvider;
  late List<String> _selectedCategies;
  late List<String> _selectedBrands;
  late RangeValues _selectedRange;
  late String _selectedSortOption;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedCategies = [widget.category];
    _selectedBrands = [];
    _selectedSortOption = 'sellingPrice_asc';
    _selectedRange = const RangeValues(0, 100000000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productProvider = Provider.of<ProductProvider>(context, listen: false);
      _fetchInitialProducts();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialProducts() async {
    await _productProvider.fetchProducts(
      category: [widget.category],
      isInitial: true,
    );
  }

  @override
  void didUpdateWidget(ProductCatalog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _selectedCategies = [widget.category];
      _fetchInitialProducts();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_productProvider.isLoading &&
        _productProvider.hasMore) {
      _productProvider.fetchProducts(
        orderBy: _selectedSortOption.split('_')[0],
        descending: _selectedSortOption.contains('_desc'),
        category: _selectedCategies,
        brand: _selectedBrands,
        minPrice: _selectedRange.start.toInt(),
        maxPrice: _selectedRange.end.toInt(),
        isInitial: false,
      );
    }
  }

  void onSortPressed() {
    showSortByBottomSheet(context, (sortOption) {
      setState(() {
        _selectedSortOption = sortOption;
      });
      _productProvider.fetchProducts(
        orderBy: sortOption.split('_')[0],
        descending: sortOption.contains('_desc'),
        category: _selectedCategies,
        brand: _selectedBrands,
        minPrice: _selectedRange.start.toInt(),
        maxPrice: _selectedRange.end.toInt(),
        isInitial: true,
      );
    });
  }

  void onFilterPressed() {
    showFilterBottomSheet(
      context,
      currentRange: _selectedRange,
      currentCategories: _selectedCategies,
      currentBrands: _selectedBrands,
      onApplyFilter: (categories, brands, range) {
        setState(() {
          _selectedCategies = categories;
          _selectedBrands = brands;
          _selectedRange = range;
        });
        _productProvider.fetchProducts(
          category: categories,
          brand: brands,
          minPrice: range.start.toInt(),
          maxPrice: range.end.toInt(),
          isInitial: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    final int gridCrossAxisCount = isLargeScreen ? 4 : 2;

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: defaultPadding),
        backgroundColor: Colors.white,
        title: Align(
          alignment: isLargeScreen ? Alignment.center : Alignment.centerLeft,
          child: Row(
            mainAxisSize: isLargeScreen ? MainAxisSize.min : MainAxisSize.max,
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
        centerTitle: isLargeScreen,
        actions: [CartButton()],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final filteredProducts = provider.products;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 1200 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.isLoading && filteredProducts.isEmpty)
                      const Expanded(child: ProductCatalogSkeleton()),

                    if (!provider.isLoading && filteredProducts.isNotEmpty)
                      Align(
                        child: Text(
                          '${filteredProducts.length} Items',
                          style: TextStyle(fontSize: 16, color: iconColor),
                        ),
                      ),
                    FilterSection(
                      onSortPressed: onSortPressed,
                      onFilterPressed: onFilterPressed,
                      selectedSortOption: _selectedSortOption,
                    ),
                    const SizedBox(height: 20),

                    if (!provider.isLoading || filteredProducts.isNotEmpty)
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
                                : NotificationListener<ScrollNotification>(
                                  onNotification: (scrollNotification) {
                                    if (scrollNotification
                                        is ScrollEndNotification) {
                                      _onScroll();
                                    }
                                    return false;
                                  },
                                  child: GridView.builder(
                                    controller: _scrollController,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: gridCrossAxisCount,
                                          childAspectRatio: 0.75,
                                          crossAxisSpacing:
                                              isLargeScreen ? 20 : 10,
                                          mainAxisSpacing:
                                              isLargeScreen ? 20 : 10,
                                        ),
                                    itemCount:
                                        filteredProducts.length +
                                        (provider.isLoading ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == filteredProducts.length &&
                                          provider.isLoading) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      final product = filteredProducts[index];
                                      return ProductCard(
                                        key: ValueKey(product.id),
                                        product: product,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ProductDetails(
                                                    product: product,
                                                  ),
                                            ),
                                          );
                                        },
                                        imgWidth: isLargeScreen ? 250 : 100,
                                      );
                                    },
                                  ),
                                ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
