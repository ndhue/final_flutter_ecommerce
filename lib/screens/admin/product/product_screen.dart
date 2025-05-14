import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/new_product_model.dart';
import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:final_ecommerce/screens/admin/product/product_add.dart';
import 'package:final_ecommerce/screens/admin/product/product_detail.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLocalLoading = false;

  // Map to store variant counts for each product
  final Map<String, int> _variantCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
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
      await productProvider.fetchProducts(isInitial: true, includeInactive: true);

      if (mounted) {
        _loadVariantCounts(productProvider.products);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLocalLoading = false);
      }
    }
  }

  Future<void> _loadVariantCounts(List<NewProduct> products) async {
    try {
      for (var product in products) {
        // Skip if we already have the count
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Statistics getters
  int getTotalProducts(List<NewProduct> products) => products.length;

  int getInStockProducts(List<NewProduct> products) {
    return _variantCounts.values.where((itemCount) => itemCount > 0).length;
  }

  int getActiveProducts(List<NewProduct> products) =>
      products.where((p) => p.activated).length;

  void _viewProductDetails(NewProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProductDetailScreen(product: product),
      ),
    ).then((_) {
      // Refresh products list when returning from details
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
      // Refresh products list when returning from add screen
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

  Future<void> _loadMoreProducts() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    await productProvider.fetchProducts();
    if (mounted) {
      // Only load variant counts for newly loaded products
      _loadVariantCounts(
        productProvider.products
            .where((p) => !_variantCounts.containsKey(p.id))
            .toList(),
      );
    }
  }

  // Check if the screen is large
  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  // Check if the screen is medium
  bool _isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 800 && width <= 1200;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = _isLargeScreen(context);
    final bool isMediumScreen = _isMediumScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Management',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: _searchProducts,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                Expanded(
                  child:
                      isLoading && products.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : products.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No products found'
                                      : 'No products matching "$_searchQuery"',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _navigateToAddProduct,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add New Product'),
                                ),
                              ],
                            ),
                          )
                          : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
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
                                if (productProvider.hasMore && !isLoading)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _loadMoreProducts,
                                      child: const Text('Load More'),
                                    ),
                                  ),
                                if (isLoading && products.isNotEmpty)
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
    double percentage = total == 0 ? 0 : (value / total) * 100;

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
