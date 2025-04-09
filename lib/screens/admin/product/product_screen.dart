import 'package:final_ecommerce/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:final_ecommerce/data/mock_data.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int get totalProducts {
    int total = 0;
    for (var product in products) {
      for (var variant in product.variants) {
        if (variant.inventory > 0) {
          total = total + variant.inventory + product.salesCount;
        }
      }
    }
    return total;
  }

  int get inStockProducts {
    int total = 0;
    for (var product in products) {
      for (var variant in product.variants) {
        if (variant.inventory > 0) {
          total += variant.inventory;
        }
      }
    }
    return total;
  }

  int get activeProdcucts {
    int total = 0;
    for (var product in products) {
      if (product.activated) total++;
    }
    return total;
  }

  int get totalInventory {
    int total = 0;
    for (var product in products) {
      for (var variant in product.variants) {
        total += variant.inventory;
      }
    }
    return total;
  }

  int get activeProducts => products.where((p) => p.activated).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  onPressed: () {
                    // Add product functionality
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
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
                        value: activeProdcucts,
                        icon: Icons.cancel,
                        color: Colors.orange,
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
                                                        product.images[0],
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
          // Xác định kích thước màn hình để điều chỉnh font size
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
                        Icon(icon, color: color, size: isSmallScreen ? 16 : 20),
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
