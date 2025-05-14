import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/new_product_model.dart';
import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:final_ecommerce/screens/admin/product/product_add.dart';
import 'package:final_ecommerce/screens/admin/product/product_detail.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ActivationFilter { all, active, inactive }

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLocalLoading = false;
  String _selectedCategory = 'All';
  bool _isLoadingMore = false;
  ActivationFilter _activationFilter = ActivationFilter.all;
  final Map<String, int> _variantCounts = {};

  int _totalProductCount = 0;
  int _activeProductCount = 0;
  int _inStockProductCount = 0;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
      _fetchProductStats();
    });
  }

  Future<void> _fetchProductStats() async {
    if (!mounted) return;

    setState(() => _isLoadingStats = true);

    try {
      final firestore = FirebaseFirestore.instance;

      final totalCountSnapshot =
          await firestore.collection('products').count().get();
      final totalCount = totalCountSnapshot.count;

      final activeCountSnapshot =
          await firestore
              .collection('products')
              .where('activated', isEqualTo: true)
              .count()
              .get();
      final activeCount = activeCountSnapshot.count;

      int inStockCount = 0;
      final productsWithVariants = await firestore.collection('products').get();

      for (var doc in productsWithVariants.docs) {
        final variantsSnapshot =
            await firestore
                .collection('products')
                .doc(doc.id)
                .collection('variantInventory')
                .get();

        if (variantsSnapshot.docs.isNotEmpty) {
          inStockCount++;
        }
      }

      if (mounted) {
        setState(() {
          _totalProductCount = totalCount!;
          _activeProductCount = activeCount!;
          _inStockProductCount = inStockCount;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching product stats: $e');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() => _isLocalLoading = true);

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    try {
      productProvider.resetPagination();

      if (_selectedCategory != 'All') {
        await productProvider.fetchProducts(
          isInitial: true,
          includeInactive: _activationFilter != ActivationFilter.active,
          category: [_selectedCategory],
          activationStatus: _getActivationFilterValue(),
        );
      } else {
        await productProvider.fetchProducts(
          isInitial: true,
          includeInactive: _activationFilter != ActivationFilter.active,
          activationStatus: _getActivationFilterValue(),
        );
      }

      if (mounted) {
        // Load variant counts for all products
        await _loadVariantCounts(productProvider.products);
        // Reset the loading more flag
        _isLoadingMore = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
        debugPrint('$e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLocalLoading = false);
      }
    }
  }

  bool? _getActivationFilterValue() {
    switch (_activationFilter) {
      case ActivationFilter.active:
        return true;
      case ActivationFilter.inactive:
        return false;
      case ActivationFilter.all:
        return null;
    }
  }

  void _onActivationFilterChanged(ActivationFilter filter) {
    if (_activationFilter == filter) return;

    setState(() {
      _activationFilter = filter;
    });
    _loadProducts();
  }

  Future<void> _loadVariantCounts(List<NewProduct> products) async {
    try {
      for (var product in products) {
        if (_variantCounts.containsKey(product.id)) {
          continue;
        }

        final variantSnapshot =
            await FirebaseFirestore.instance
                .collection('products')
                .doc(product.id)
                .collection('variantInventory')
                .get();

        if (mounted) {
          setState(() {
            _variantCounts[product.id] = variantSnapshot.docs.length;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading variant counts: $e');
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
    await _fetchProductStats();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
      _searchController.clear();
      _variantCounts.clear();
    });
    _loadProducts();

    if (category == 'All') {
      _fetchProductStats();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    try {
      if (_selectedCategory != 'All') {
        await productProvider.fetchProducts(
          category: [_selectedCategory],
          includeInactive: _activationFilter != ActivationFilter.active,
          activationStatus: _getActivationFilterValue(),
        );
      } else {
        await productProvider.fetchProducts(
          includeInactive: _activationFilter != ActivationFilter.active,
          activationStatus: _getActivationFilterValue(),
        );
      }

      if (mounted) {
        final newProducts =
            productProvider.products
                .where((p) => !_variantCounts.containsKey(p.id))
                .toList();

        await _loadVariantCounts(newProducts);

        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading more products: $e');
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  bool _isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 800 && width <= 1200;
  }

  int getTotalProducts(List<NewProduct> products) =>
      _isLoadingStats || _selectedCategory != 'All'
          ? products.length
          : _totalProductCount;

  int getInStockProducts(List<NewProduct> products) {
    if (_isLoadingStats || _selectedCategory != 'All') {
      int count = 0;
      for (var product in products) {
        if (_variantCounts.containsKey(product.id) &&
            _variantCounts[product.id]! > 0) {
          count++;
        }
      }
      return count;
    }
    return _inStockProductCount;
  }

  int getActiveProducts(List<NewProduct> products) =>
      _isLoadingStats || _selectedCategory != 'All'
          ? products.where((p) => p.activated).length
          : _activeProductCount;

  void _viewProductDetails(NewProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProductDetailScreen(product: product),
      ),
    ).then((_) {
      _refreshProducts();
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isNotEmpty) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.resetPagination();
      productProvider.fetchProductsByKeyword(keyword: query, isInitial: true);
    } else {
      _refreshProducts();
    }
  }

  void _deleteProduct(NewProduct product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete ${product.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    Navigator.pop(context);
                    setState(() => _isLocalLoading = true);

                    final productProvider = Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    );
                    await productProvider.deleteProduct(product.id);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} deleted successfully'),
                        ),
                      );

                      // Refresh products
                      await _refreshProducts();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting product: $e')),
                      );
                      setState(() => _isLocalLoading = false);
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductPage()),
    ).then((_) {
      _refreshProducts();
    });
  }

  Future<void> _updateProductStatus(String productId, bool newStatus) async {
    setState(() => _isLocalLoading = true);
    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      await productProvider.updateProductStatus(productId, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product ${newStatus ? 'activated' : 'deactivated'} successfully',
            ),
          ),
        );
        setState(() => _isLocalLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product status: $e')),
        );
        setState(() => _isLocalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = _isLargeScreen(context);
    final bool isMediumScreen = _isMediumScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddProduct,
            tooltip: 'Add New Product',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLocalLoading ? null : _refreshProducts,
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final products = productProvider.products;
            final isLoading = productProvider.isLoading || _isLocalLoading;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Search field
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _searchQuery.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _searchProducts('');
                                      },
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: _searchProducts,
                          textInputAction: TextInputAction.search,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Category dropdown
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCategory,
                              hint: const Text('Filter by Category'),
                              icon: const Icon(Icons.filter_list),
                              items:
                                  productCategories.map((String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _onCategoryChanged(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Add activation filter segmented button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<ActivationFilter>(
                          segments: const [
                            ButtonSegment<ActivationFilter>(
                              value: ActivationFilter.all,
                              label: Text('All'),
                              icon: Icon(Icons.view_list),
                            ),
                            ButtonSegment<ActivationFilter>(
                              value: ActivationFilter.active,
                              label: Text('Active'),
                              icon: Icon(Icons.toggle_on),
                            ),
                            ButtonSegment<ActivationFilter>(
                              value: ActivationFilter.inactive,
                              label: Text('Inactive'),
                              icon: Icon(Icons.toggle_off),
                            ),
                          ],
                          selected: {_activationFilter},
                          onSelectionChanged: (
                            Set<ActivationFilter> selection,
                          ) {
                            if (selection.isNotEmpty) {
                              _onActivationFilterChanged(selection.first);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Display active category filter if one is selected
                if (_selectedCategory != 'All')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Chip(
                      label: Text('Category: $_selectedCategory'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _onCategoryChanged('All'),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),

                Expanded(
                  child:
                      isLoading && products.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : products.isEmpty
                          ? _buildEmptyProductsView(_searchQuery)
                          : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // Display loading indicator for stats if needed
                                if (_isLoadingStats)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Center(
                                      child: LinearProgressIndicator(
                                        backgroundColor: Colors.transparent,
                                        minHeight: 2,
                                      ),
                                    ),
                                  ),

                                Row(
                                  children: [
                                    _buildStatCard(
                                      total: getTotalProducts(products),
                                      title: 'Total Products',
                                      value: getTotalProducts(products),
                                      icon: Icons.inventory,
                                      color: Colors.blueAccent,
                                      isLargeScreen: isLargeScreen,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatCard(
                                      total: getTotalProducts(products),
                                      title: 'In Stock',
                                      value: getInStockProducts(products),
                                      icon: Icons.check_circle,
                                      color: Colors.green,
                                      isLargeScreen: isLargeScreen,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatCard(
                                      total: getTotalProducts(products),
                                      title: 'Active Products',
                                      value: getActiveProducts(products),
                                      icon: Icons.toggle_on,
                                      color: Colors.orange,
                                      isLargeScreen: isLargeScreen,
                                    ),
                                  ],
                                ),

                                // If filtering by category, show a note about stats
                                if (_selectedCategory != 'All')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Note: Statistics shown are for the "${_selectedCategory}" category only',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 24),
                                Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Product List',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (isLargeScreen || isMediumScreen)
                                              ElevatedButton.icon(
                                                onPressed:
                                                    _navigateToAddProduct,
                                                icon: const Icon(Icons.add),
                                                label: const Text(
                                                  'Add New Product',
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProductTable(
                                          products,
                                          isLargeScreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (productProvider.hasMore &&
                                    !isLoading &&
                                    !_isLoadingMore)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _loadMoreProducts,
                                      child: const Text('Load More'),
                                    ),
                                  ),
                                if ((isLoading || _isLoadingMore) &&
                                    products.isNotEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyProductsView(String searchQuery) {
    // Create an appropriate message based on filters
    String message;
    if (searchQuery.isNotEmpty) {
      message = 'No products matching "$searchQuery"';
    } else if (_selectedCategory != 'All') {
      message =
          'No ${_activationFilter != ActivationFilter.all ? _getActivationText().toLowerCase() + " " : ""}products in category "$_selectedCategory"';
    } else if (_activationFilter != ActivationFilter.all) {
      message = 'No ${_getActivationText().toLowerCase()} products found';
    } else {
      message = 'No products found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add New Product'),
          ),
        ],
      ),
    );
  }

  String _getActivationText() {
    switch (_activationFilter) {
      case ActivationFilter.active:
        return 'Active';
      case ActivationFilter.inactive:
        return 'Inactive';
      case ActivationFilter.all:
      default:
        return 'All';
    }
  }

  Widget _buildProductTable(List<NewProduct> products, bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              dividerThickness: 1,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 120,
              columnSpacing: isLargeScreen ? 40 : 24,
              headingRowHeight: 50,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Colors.grey[50],
              ),
              columns: [
                const DataColumn(
                  label: Text(
                    'Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Cost price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                const DataColumn(
                  label: Text(
                    'Selling price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                const DataColumn(
                  label: Text(
                    'Variant Count',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                if (isLargeScreen)
                  const DataColumn(
                    label: Text(
                      'Created Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: List.generate(products.length, (index) {
                final product = products[index];
                final variantCount = _variantCounts[product.id] ?? 0;

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              product.images[0],
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, size: 20),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: isLargeScreen ? 250 : 150,
                            child: Text(
                              product.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _viewProductDetails(product),
                    ),
                    DataCell(
                      SizedBox(
                        width: isLargeScreen ? 150 : 100,
                        child: Text(
                          product.category,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(FormatHelper.formatCurrency(product.costPrice)),
                    ),
                    DataCell(
                      Text(FormatHelper.formatCurrency(product.sellingPrice)),
                    ),
                    DataCell(
                      variantCount == -1
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            variantCount.toString(),
                            style: TextStyle(
                              color:
                                  variantCount == 0 ? Colors.red : Colors.black,
                            ),
                          ),
                    ),
                    if (isLargeScreen)
                      DataCell(
                        Text(
                          FormatHelper.formatDateTime(
                            product.createdAt.toDate(),
                          ),
                        ),
                      ),
                    DataCell(
                      // Using a stateful builder to avoid calling setState during build
                      StatefulBuilder(
                        builder: (context, setInnerState) {
                          return Switch(
                            value: product.activated,
                            onChanged: (bool value) {
                              // Don't call setState directly during build to avoid the error
                              _updateProductStatus(product.id, value);
                            },
                            activeColor: Colors.green,
                          );
                        },
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.visibility,
                              size: isLargeScreen ? 24 : 20,
                            ),
                            onPressed: () => _viewProductDetails(product),
                            color: Colors.blue,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: isLargeScreen ? 24 : 20,
                            ),
                            onPressed: () => _deleteProduct(product),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required int total,
    required IconData icon,
    required Color color,
    bool isLargeScreen = false,
  }) {
    // Ensure we don't divide by zero
    double percentage = total == 0 ? 0 : (value / total) * 100;

    // Ensure the percentage is between 0 and 100
    percentage = percentage.clamp(0, 100);

    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth < 300;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: color,
                              size:
                                  isLargeScreen
                                      ? 28
                                      : (isSmallScreen ? 16 : 20),
                            ),
                            SizedBox(width: isLargeScreen ? 12 : 8),
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize:
                                      isLargeScreen
                                          ? 18
                                          : (isSmallScreen ? 12 : 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize:
                              isLargeScreen ? 32 : (isSmallScreen ? 18 : 24),
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLargeScreen ? 24 : 16),
                  SizedBox(
                    height: isLargeScreen ? 80 : (isSmallScreen ? 50 : 60),
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: percentage,
                            color: color,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius:
                                isLargeScreen ? 30 : (isSmallScreen ? 15 : 20),
                            titleStyle: TextStyle(
                              fontSize:
                                  isLargeScreen
                                      ? 16
                                      : (isSmallScreen ? 10 : 12),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 100 - percentage,
                            color: color.withOpacity(0.1),
                            radius:
                                isLargeScreen ? 30 : (isSmallScreen ? 15 : 20),
                            showTitle: false,
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius:
                            isLargeScreen ? 20 : (isSmallScreen ? 10 : 12),
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                  if (isLargeScreen)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.grey.shade200,
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            flex: percentage.round(),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: color,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: (100 - percentage).round(),
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
