import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now().subtract(const Duration(days: 30));
    toDate = DateTime.now();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final orders = await _fetchOrdersFromFirestore(fromDate!, toDate!);
      setState(() {
        filteredOrders = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersFromFirestore(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .where('createdAt', isGreaterThanOrEqualTo: from)
              .where('createdAt', isLessThanOrEqualTo: to)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Không thể lấy dữ liệu từ Firestore: $e');
    }
  }

  int getTotalOrders() => filteredOrders.length;

  int getCompletedOrders() =>
      filteredOrders
          .where(
            (order) =>
                order['orderStatus']?.toString().toLowerCase() == 'completed',
          )
          .length;

  int getPendingOrders() =>
      filteredOrders
          .where(
            (order) =>
                order['orderStatus']?.toString().toLowerCase() == 'pending',
          )
          .length;

  int getCanceledOrders() =>
      filteredOrders.where((order) {
        final status = order['orderStatus']?.toString().toLowerCase();
        return status == 'canceled' || status == 'cancelled';
      }).length;

  double calculateRevenue() {
    return filteredOrders
        .where(
          (order) =>
              order['orderStatus']?.toString().toLowerCase() == 'completed',
        )
        .fold(0.0, (sum, order) {
          final total = order['total'];
          if (total is String) {
            return sum + (double.tryParse(total) ?? 0.0);
          } else if (total is num) {
            return sum + total.toDouble();
          }
          return sum;
        });
  }

 Future<double> calculateCostPrice() async {
  double totalCost = 0.0;
  final productCostCache = <String, double>{};

  for (final order in filteredOrders) {
    debugPrint('Processing order ${order['id']} - Status: ${order['orderStatus']}');
    if (order['orderStatus']?.toString().toLowerCase() != 'completed') {
      debugPrint('Skipped order ${order['id']} - Status: ${order['orderStatus']}');
      continue;
    }

    final details = order['orderDetails'] as List<dynamic>? ?? [];
    for (final item in details) {
      final productId = item['productId']?.toString();
      debugPrint('Product ID: $productId');
      if (productId == null) continue;

      // ✅ Đảm bảo quantity là int
      final quantityRaw = item['quantity'];
      final quantity = (quantityRaw is int)
          ? quantityRaw
          : int.tryParse(quantityRaw.toString()) ?? 1;

      debugPrint('Product: $productId, Quantity: $quantity');

      double costPrice = 0.0;

      if (productCostCache.containsKey(productId)) {
        costPrice = productCostCache[productId]!;
      } else {
        try {
          final productDoc = await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .get();

          if (!productDoc.exists) {
            debugPrint('Product $productId does not exist!');
            continue;
          }

          final data = productDoc.data()!;
          final rawCost = data['costPrice'] ?? 0.0;
          costPrice = rawCost is num ? rawCost.toDouble() : 0.0;
          productCostCache[productId] = costPrice;
        } catch (e) {
          debugPrint('Error fetching product $productId: $e');
          continue;
        }
      }

      final addedCost = costPrice * quantity;
      totalCost += addedCost;
      debugPrint('Cost for $productId: $costPrice');
      debugPrint('Added cost: $addedCost for $productId');
    }
  }

  debugPrint('Total cost calculated: $totalCost');
  return totalCost;
}

Future<double> calculateProfit() async {
  final revenue = calculateRevenue();
  final costPrice = await calculateCostPrice();
  print('Revenue: $revenue, Cost: $costPrice');
  return revenue - costPrice;
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage));

    final total = getTotalOrders();
    final completed = getCompletedOrders();
    final pending = getPendingOrders();
    final revenue = calculateRevenue();

    final canceled = getCanceledOrders();

    final statusCounts = {
      'Pending': pending,
      'Completed': completed,
      'Canceled': canceled,
    };

    final statusColor = {
      'Pending': Colors.orange,
      'Completed': Colors.green,
      'Canceled': Colors.red,
    };

    final pieSections =
        statusCounts.entries
            .where((e) => e.value > 0)
            .map(
              (entry) => PieChartSectionData(
                value: entry.value.toDouble(),
                title: '${entry.value}',
                color: statusColor[entry.key],
                radius: 30,
                titleStyle: TextStyle(
                  fontSize: 14,
                  color: entry.key == 'Pending' ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                _buildDatePicker('From:', fromDate!, (picked) {
                  setState(() {
                    fromDate = picked;
                    if (toDate != null && picked.isAfter(toDate!)) {
                      toDate = picked.add(const Duration(days: 1));
                    }
                  });
                }),
                const SizedBox(width: 20),
                _buildDatePicker('To:', toDate!, (picked) {
                  setState(() {
                    toDate = picked;
                    if (fromDate != null && picked.isBefore(fromDate!)) {
                      fromDate = picked.subtract(const Duration(days: 1));
                    }
                  });
                }),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _fetchOrders,
                  child: const Text("Filter"),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fromDate != null && toDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Naturify shop data statistics',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard('Total Orders', total),
                  _buildStatCard('Completed', completed),
                  _buildStatCard('Revenue', revenue),
                  FutureBuilder<double>(
                    future: calculateProfit(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatCard(
                          'Profit',
                          0,
                        ); // Show 0 while loading
                      } else if (snapshot.hasError) {
                        return _buildStatCard('Profit', 0); // Handle error case
                      } else {
                        return _buildStatCard('Profit', snapshot.data ?? 0);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (filteredOrders.isEmpty)
                const Center(child: Text('No orders found'))
              else ...[
                SizedBox(height: 300, child: _buildPieChart(pieSections)),
                const SizedBox(height: 24),
                SizedBox(height: 300, child: _buildTopSellingBarChart()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, num value) {
    return Container(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                (title == 'Revenue' || title == 'Profit')
                    ? _formatCurrency(value)
                    : value.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<PieChartSectionData> sections) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
            startDegreeOffset: -90,
          ),
        ),
      ),
    );
  }

 Widget _buildTopSellingBarChart() {
  // Tính toán sản phẩm bán chạy từ filteredOrders
  final productSales = <String, int>{};

  for (final order in filteredOrders) {
    if (order['orderStatus']?.toString().toLowerCase() != 'completed') continue;

    final details = order['orderDetails'] as List<dynamic>?;
    if (details == null) continue;

    for (final item in details) {
      final productName = item['name']?.toString() ?? 'Unknown';
      final quantity = item['quantity'] is int ? item['quantity'] as int : 0;
      productSales.update(
        productName,
        (value) => value + quantity,
        ifAbsent: () => quantity,
      );
    }
  }

  final topProducts =
      productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5);

  if (topProducts.isEmpty) {
    return const Center(child: Text('No best selling product data available'));
  }

  final maxSales = topProducts.first.value.toDouble();

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm bán chạy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: topProducts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: product.value.toDouble(),
                        color: _getBarColor(
                          index,
                        ), // Ensure _getBarColor is defined
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < topProducts.length) {
                          // Giới hạn tên sản phẩm dài
                          String productName =
                              topProducts[value.toInt()].key;
                          // Giới hạn độ dài tên sản phẩm
                          if (productName.length > 10) {
                            productName = productName.substring(0, 10) + '...';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxSales > 10
                          ? (maxSales / 5).ceilToDouble()
                          : 1,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                maxY: maxSales * 1.2,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Color _getBarColor(int index) {
    // Define colors for the bars based on the index
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  String _formatCurrency(num value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value);
  }

  Widget _buildDatePicker(
    String label,
    DateTime initial,
    Function(DateTime) onPicked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) onPicked(picked);
          },
          child: Text(DateFormat('dd/MM/yyyy').format(initial)),
        ),
      ],
    );
  }
}
