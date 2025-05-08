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
    _initializeDates();
    _fetchOrders();
  }

  void _initializeDates() {
    fromDate = DateTime.now().subtract(const Duration(days: 30));
    toDate = DateTime.now();
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
        errorMessage = 'Failed to load data: ${e.toString()}';
      });
      _showErrorSnackbar(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersFromFirestore(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: from)
          .where('createdAt', isLessThanOrEqualTo: to)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data()..['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Firestore fetch error: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Statistics calculation methods
  int get totalOrders => filteredOrders.length;

  int get completedOrders => filteredOrders
      .where((order) => order['orderStatus']?.toString().toLowerCase() == 'completed')
      .length;

  int get pendingOrders => filteredOrders
      .where((order) => order['orderStatus']?.toString().toLowerCase() == 'pending')
      .length;

  int get canceledOrders => filteredOrders.where((order) {
        final status = order['orderStatus']?.toString().toLowerCase();
        return status == 'canceled' || status == 'cancelled';
      }).length;

  double get revenue {
    return filteredOrders
        .where((order) => order['orderStatus']?.toString().toLowerCase() == 'completed')
        .fold(0.0, (sum, order) {
          final total = order['total'];
          if (total is String) return sum + (double.tryParse(total) ?? 0.0);
          if (total is num) return sum + total.toDouble();
          return sum;
        });
  }

  Future<double> calculateCostPrice() async {
    double totalCost = 0.0;
    final productCostCache = <String, double>{};

    for (final order in filteredOrders) {
      if (order['orderStatus']?.toString().toLowerCase() != 'completed') continue;

      final details = order['orderDetails'] as List<dynamic>? ?? [];
      for (final item in details) {
        final productId = item['productId']?.toString();
        if (productId == null) continue;

        final quantity = item['quantity'] is int 
            ? item['quantity'] as int 
            : int.tryParse(item['quantity'].toString()) ?? 1;

        double costPrice = productCostCache[productId] ?? 0.0;
        
        if (!productCostCache.containsKey(productId)) {
          try {
            final productDoc = await FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .get();

            if (productDoc.exists) {
              final data = productDoc.data()!;
              final rawCost = data['costPrice'] ?? 0.0;
              costPrice = rawCost is num ? rawCost.toDouble() : 0.0;
              productCostCache[productId] = costPrice;
            }
          } catch (e) {
            debugPrint('Error fetching product $productId: $e');
          }
        }

        totalCost += costPrice * quantity;
      }
    }

    return totalCost;
  }

  Future<double> calculateProfit() async {
    final cost = await calculateCostPrice();
    return revenue - cost;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage));

    final statusCounts = {
      'Pending': pendingOrders,
      'Completed': completedOrders,
      'Canceled': canceledOrders,
    };

    final pieSections = statusCounts.entries
        .where((e) => e.value > 0)
        .map((entry) => PieChartSectionData(
              value: entry.value.toDouble(),
              title: '${entry.value}',
              color: _getStatusColor(entry.key),
              radius: 30,
              titleStyle: TextStyle(
                fontSize: 14,
                color: entry.key == 'Pending' ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date filter controls
              _buildDateFilterControls(),
              const SizedBox(height: 16),
              
              // Statistics title
              const Text(
                'Naturify shop data statistics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Statistics cards
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard('Total Orders', totalOrders),
                  _buildStatCard('Completed', completedOrders),
                  _buildStatCard('Revenue', revenue),
                  FutureBuilder<double>(
                    future: calculateProfit(),
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        'Profit',
                        snapshot.data ?? 0,
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Charts
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

Widget _buildDateFilterControls() {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        const Spacer(), // Đẩy tất cả sang phải
        _buildDatePicker('From:', fromDate!, (picked) {
          setState(() {
            fromDate = picked;
            if (toDate != null && picked.isAfter(toDate!)) {
              toDate = picked.add(const Duration(days: 1));
            }
          });
        }),
        const SizedBox(width: 16),
        _buildDatePicker('To:', toDate!, (picked) {
          setState(() {
            toDate = picked;
            if (fromDate != null && picked.isBefore(fromDate!)) {
              fromDate = picked.subtract(const Duration(days: 1));
            }
          });
        }),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _fetchOrders,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text("Filter"),
        ),
      ],
    ),
  );
}

  Widget _buildStatCard(String title, num value, {bool isLoading = false}) {
    return SizedBox(
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
              isLoading
                  ? const SizedBox(
                      height: 24,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Text(
                      _formatValue(title, value),
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

  String _formatValue(String title, num value) {
    return (title == 'Revenue' || title == 'Profit')
        ? _formatCurrency(value)
        : value.toString();
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
    final productSales = <String, int>{};

    for (final order in filteredOrders) {
      if (order['orderStatus']?.toString().toLowerCase() != 'completed') continue;

      final details = order['orderDetails'] as List<dynamic>? ?? [];
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

    final topProducts = productSales.entries.toList()
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
              'Top Selling Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: topProducts.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: _getBarColor(entry.key),
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: _buildBarChartTitles(topProducts, maxSales),
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

  FlTitlesData _buildBarChartTitles(List<MapEntry<String, int>> products, double maxSales) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() < products.length) {
              String name = products[value.toInt()].key;
              if (name.length > 10) name = '${name.substring(0, 10)}...';
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(name, style: const TextStyle(fontSize: 10)),
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
          interval: maxSales > 10 ? (maxSales / 5).ceilToDouble() : 1,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Text(
            value.toInt().toString(),
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
    );
  }

  Color _getStatusColor(String status) {
    return {
      'Pending': Colors.orange,
      'Completed': Colors.green,
      'Canceled': Colors.red,
    }[status] ?? Colors.grey;
  }

  Color _getBarColor(int index) {
    const colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];
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
            final picked = await showDatePicker(
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