import 'package:final_ecommerce/models/product_model.dart';
import 'package:final_ecommerce/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/models/variant_model.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showEditForm = false;
  Product? _editingProduct;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _priceController = TextEditingController();
  final _variants = <Variant>[]; // List of variants for the product
  bool _activated = true;

  @override
  void initState() {
    super.initState();
    final productProvider = context.read<ProductProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productProvider.fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _costPriceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Statistics getters
  int get totalProducts => products.length;

  int get inStockProducts {
    int total = 0;
    for (var product in products) {
      for (var variant in product.variants) {
        if (variant.inventory > 0) {
          total += 1;
        }
      }
    }
    return total;
  }

  int get activeProducts => products.where((p) => p.activated).length;

  void _editProduct(Product product) {
    setState(() {
      _editingProduct = product;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _imageUrlController.text =
          product.images.isNotEmpty ? product.images[0] : '';
      _activated = product.activated;
      _showEditForm = true;
      _costPriceController.text = product.variants.first.costPrice.toString();
      _priceController.text = product.variants.first.sellingPrice.toString();
    });
  }

  void _deleteProduct(Product product) {
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
                onPressed: () {
                  setState(() {
                    products.remove(product);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} deleted successfully'),
                    ),
                  );
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

  void _submitEdit() {
    if (_formKey.currentState!.validate() && _editingProduct != null) {
      setState(() {
        _editingProduct!.name = _nameController.text;
        _editingProduct!.description = _descriptionController.text;
        if (_imageUrlController.text.isNotEmpty) {
          _editingProduct!.images = [_imageUrlController.text];
        }
        _editingProduct!.activated = _activated;

        _showEditForm = false;
        _editingProduct = null;
        _nameController.clear();
        _descriptionController.clear();
        _imageUrlController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      _showEditForm = false;
      _editingProduct = null;
      _nameController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts =
        products
            .where(
              (product) =>
                  product.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  product.id.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_showEditForm) _buildEditForm(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (!_showEditForm) ...[
                    Row(
                      children: [
                        _buildStatCard(
                          total: totalProducts,
                          title: 'Total Products',
                          value: totalProducts,
                          icon: Icons.inventory,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          total: totalProducts,
                          title: 'In Stock',
                          value: inStockProducts,
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          total: totalProducts,
                          title: 'Active Products',
                          value: activeProducts,
                          icon: Icons.cancel,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product List',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: DataTable(
                                    dividerThickness: 1,
                                    dataRowMinHeight: 60,
                                    dataRowMaxHeight: 120,
                                    columnSpacing: 24,
                                    headingRowHeight: 50,
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                          (states) => Colors.grey[50],
                                        ),
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'ID',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PRODUCT',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'DESCRIPTION',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'VARIANTS',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PRICE',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        numeric: true,
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'STATUS',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'ACTIONS',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows:
                                        filteredProducts.map((product) {
                                          final variant =
                                              product.variants.first;
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  product.id,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      child: Image.network(
                                                        product
                                                                .images
                                                                .isNotEmpty
                                                            ? product.images[0]
                                                            : 'https://via.placeholder.com/40',
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => Container(
                                                              width: 40,
                                                              height: 40,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                              child: const Icon(
                                                                Icons.image,
                                                                size: 20,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    SizedBox(
                                                      width: 150,
                                                      child: Text(
                                                        product.name,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    product.description,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 250,
                                                  child: Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children:
                                                        product.variants.map((
                                                          variant,
                                                        ) {
                                                          return Chip(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey
                                                                    .shade100,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                              side: BorderSide(
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade300,
                                                              ),
                                                            ),
                                                            label: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  width: 12,
                                                                  height: 12,
                                                                  margin:
                                                                      const EdgeInsets.only(
                                                                        right:
                                                                            6,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        variant
                                                                            .color,
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                    border: Border.all(
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  variant.name,
                                                                  style:
                                                                      const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '\$${variant.sellingPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Switch(
                                                  value: product.activated,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      product.activated = value;
                                                    });
                                                  },
                                                  activeColor: Colors.green,
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                      ),
                                                      onPressed:
                                                          () => _editProduct(
                                                            product,
                                                          ),
                                                      color: Colors.blue,
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        size: 20,
                                                      ),
                                                      onPressed:
                                                          () => _deleteProduct(
                                                            product,
                                                          ),
                                                      color: Colors.red,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildEditForm() {
  return Card(
    margin: const EdgeInsets.all(16),
    elevation: 3,
    child :SingleChildScrollView(
       child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView( // Nếu danh sách variant dài
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costPriceController,
                decoration: const InputDecoration(
                  labelText: 'Cost Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Selling Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter selling price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: _activated,
                    onChanged: (value) {
                      setState(() {
                        _activated = value;
                      });
                    },
                  ),
                  const Text('Active'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _cancelEdit,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitEdit,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Variants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: _variants.map((variant) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(variant.name),
                      subtitle: Text(
                        "Giá: ${variant.currentPrice} | Kho: ${variant.inventory}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                             // _editVariant(variant); // xử lý chỉnh sửa
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              //_deleteVariant(variant); // xử lý xóa
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement _addVariant functionality
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Variant"),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    )
   
  );
}

  Widget _buildStatCard({
    required String title,
    required int value,
    required int total,
    required IconData icon,
    required Color color,
  }) {
    double percentage = total == 0 ? 0 : (value / total) * 100;

    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                              size: isSmallScreen ? 16 : 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
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
                          fontSize: isSmallScreen ? 18 : 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: isSmallScreen ? 50 : 60,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: percentage,
                            color: color,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: isSmallScreen ? 15 : 20,
                            titleStyle: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 100 - percentage,
                            color: color.withOpacity(0.1),
                            radius: isSmallScreen ? 15 : 20,
                            showTitle: false,
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius: isSmallScreen ? 10 : 12,
                        startDegreeOffset: -90,
                      ),
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
