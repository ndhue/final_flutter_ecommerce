import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
    _initializeDates(); // Initialize dates in a separate method
    _fetchOrders();
  }

  void _initializeDates() {
    // Initialize fromDate to 30 days ago (start of day)
    fromDate = DateTime.now().subtract(const Duration(days: 30));
    fromDate = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);

    // Initialize toDate to today (end of day)
    toDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      23,
      59,
      59,
    );
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

  String _getLastestStatus(Map<String, dynamic> order) {
    final history = order['statusHistory'];
    if (history is! List || history.isEmpty) return 'unknown';

    final lastItem = history.first;
    if (lastItem is Map) {
      return lastItem['status']?.toString().toLowerCase() ?? 'unknown';
    } else {
      return lastItem.toString().toLowerCase();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersFromFirestore(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;

            // Extract the time from the first element of statusHistory
            List<dynamic>? statusHistory =
                data['statusHistory'] as List<dynamic>?;
            DateTime? orderTime;

            if (statusHistory != null && statusHistory.isNotEmpty) {
              if (statusHistory[0] is Map) {
                // Handle the case where statusHistory[0] is a Map
                dynamic timeValue = (statusHistory[0] as Map)['time'];

                if (timeValue is String) {
                  // If time is a String, parse it
                  orderTime = DateTime.tryParse(timeValue);
                } else if (timeValue is Timestamp) {
                  // If time is already a Timestamp, convert it to DateTime
                  orderTime = timeValue.toDate();
                }
              }
            }

            // Add orderTime to the data map
            data['orderTime'] = orderTime;

            return data;
          })
          .where((order) {
            // Now filter based on the extracted orderTime
            final orderTime = order['orderTime'] as DateTime?;
            if (orderTime == null) {
              return false; // Skip orders with no valid orderTime
            }
            return orderTime.isAfter(
                  from.subtract(const Duration(microseconds: 1)),
                ) &&
                orderTime.isBefore(to.add(const Duration(microseconds: 1)));
          })
          .toList();
    } catch (e) {
      throw Exception('Can not get data from Firestore: $e');
    }
  }

  int getTotalOrders() => filteredOrders.length;

  int getPendingOrders() =>
      filteredOrders
          .where((order) => _getLastestStatus(order) == 'pending')
          .length;
  int getConfirmedOrders() =>
      filteredOrders
          .where((order) => _getLastestStatus(order) == 'confirmed')
          .length;

  int getCanceledOrders() =>
      filteredOrders.where((order) {
        final status = _getLastestStatus(order);
        return status == 'canceled' || status == 'cancelled';
      }).length;

  int getDeliveredOrders() =>
      filteredOrders
          .where((order) => _getLastestStatus(order) == 'delivered')
          .length;

  int getCompletedOrders() =>
      filteredOrders
          .where((order) => _getLastestStatus(order) == 'completed')
          .length;

  int getShippedOrders() =>
      filteredOrders
          .where((order) => _getLastestStatus(order) == 'shipped')
          .length;

  double calculateRevenue() {
    return filteredOrders
        .where((order) => _getLastestStatus(order) == 'completed')
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
      if (_getLastestStatus(order) != 'completed') continue;

      final details = order['orderDetails'] as List<dynamic>? ?? [];
      for (final item in details) {
        final productId = item['productId']?.toString();
        if (productId == null) continue;

        final quantityRaw = item['quantity'];
        final quantity =
            (quantityRaw is int)
                ? quantityRaw
                : int.tryParse(quantityRaw.toString()) ?? 1;

        double costPrice = productCostCache[productId] ?? 0.0;

        if (!productCostCache.containsKey(productId)) {
          try {
            final productDoc =
                await FirebaseFirestore.instance
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
    final revenue = calculateRevenue();
    final costPrice = await calculateCostPrice();
    return revenue - costPrice;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage));

    final pending = getPendingOrders();
    final confirmed = getConfirmedOrders();
    final revenue = calculateRevenue();
    final canceled = getCanceledOrders();
    final delivered = getDeliveredOrders();
    final shipped = getShippedOrders();
    final completed = getCompletedOrders();

    final statusCounts = {
      'Pending': pending,
      'Confirmed': confirmed,
      'Canceled': canceled,
      'Shipped': shipped,
      'Delivered': delivered,
      'Completed': completed,
    };

    final statusColor = {
      'Pending': Colors.orange,
      'Confirmed': Colors.green,
      'Shipped': Colors.purple,
      'Canceled': Colors.red,
      'Delivered': Colors.blue,
      'Completed': Colors.teal,
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

    // Check screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 1200 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date filter controls
                  _buildDateFilterControls(),
                  SizedBox(height: isLargeScreen ? 24 : 16),

                  // Statistics title
                  Text(
                    'Naturify shop data statistics',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 24 : 16),

                  // Statistics cards - use grid layout on larger screens
                  isLargeScreen
                      ? _buildStatsGridView(revenue, completed)
                      : _buildStatsMobileView(revenue, completed),

                  SizedBox(height: isLargeScreen ? 32 : 24),

                  // Charts in columns for large screens
                  if (filteredOrders.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'No orders found in the selected date range',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    isLargeScreen
                        ? _buildChartsRowLayout(
                          pieSections,
                          statusCounts,
                          statusColor,
                        )
                        : _buildChartsMobileLayout(
                          pieSections,
                          statusCounts,
                          statusColor,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGridView(double revenue, int completed) {
    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 1.7,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Total Orders', getTotalOrders()),
        _buildStatCard('Completed', completed),
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
    );
  }

  Widget _buildStatsMobileView(double revenue, int completed) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatCard('Total Orders', getTotalOrders()),
        _buildStatCard('Completed', completed),
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
    );
  }

  Widget _buildChartsRowLayout(
    List<PieChartSectionData> pieSections,
    Map<String, int> statusCounts,
    Map<String, Color> statusColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie chart on the left side
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 400,
            child: _buildPieChart(pieSections, statusCounts, statusColor),
          ),
        ),
        const SizedBox(width: 24),
        // Bar chart on the right side
        Expanded(
          flex: 1,
          child: SizedBox(height: 400, child: _buildTopSellingBarChart()),
        ),
      ],
    );
  }

  Widget _buildChartsMobileLayout(
    List<PieChartSectionData> pieSections,
    Map<String, int> statusCounts,
    Map<String, Color> statusColor,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: _buildPieChart(pieSections, statusCounts, statusColor),
        ),
        const SizedBox(height: 24),
        SizedBox(height: 300, child: _buildTopSellingBarChart()),
      ],
    );
  }

  Widget _buildDateFilterControls() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isLargeScreen ? 24 : 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date Range Filter',
                style: TextStyle(
                  fontSize: isLargeScreen ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _buildDatePicker('From:', fromDate!, (picked) {
                    setState(() {
                      fromDate = picked;
                      // Ensure fromDate is not after toDate
                      if (toDate != null && fromDate!.isAfter(toDate!)) {
                        toDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          23,
                          59,
                          59,
                        );
                      }
                    });
                  }),
                  _buildDatePicker('To:', toDate!, (picked) {
                    setState(() {
                      toDate = picked;
                      // Ensure toDate is not before fromDate
                      if (fromDate != null && toDate!.isBefore(fromDate!)) {
                        fromDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                        );
                      }
                    });
                  }),
                  ElevatedButton.icon(
                    onPressed: _fetchOrders,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 24 : 16,
                        vertical: isLargeScreen ? 16 : 12,
                      ),
                    ),
                    icon: const Icon(Icons.filter_alt),
                    label: const Text("Apply Filter"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, num value, {bool isLoading = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isLargeScreen ? 14 : 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                  (title == 'Revenue' || title == 'Profit')
                      ? _formatCurrency(value)
                      : value.toString(),
                  style: TextStyle(
                    fontSize: isLargeScreen ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartLegend(
    Map<String, int> statusCounts,
    Map<String, Color> statusColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Wrap(
      spacing: isLargeScreen ? 16 : 8,
      runSpacing: isLargeScreen ? 12 : 8,
      alignment: WrapAlignment.center,
      children:
          statusCounts.entries
              .where((e) => e.value > 0)
              .map(
                (entry) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isLargeScreen ? 16 : 12,
                      height: isLargeScreen ? 16 : 12,
                      decoration: BoxDecoration(
                        color: statusColor[entry.key],
                        borderRadius: BorderRadius.circular(
                          isLargeScreen ? 4 : 2,
                        ),
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 8 : 4),
                    Text(
                      '${entry.key} (${entry.value})',
                      style: TextStyle(fontSize: isLargeScreen ? 14 : 12),
                    ),
                  ],
                ),
              )
              .toList(),
    );
  }

  Widget _buildPieChart(
    List<PieChartSectionData> sections,
    Map<String, int> statusCounts,
    Map<String, Color> statusColor,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPieChartLegend(statusCounts, statusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingBarChart() {
    final productSales = <String, int>{};

    for (final order in filteredOrders) {
      if (_getLastestStatus(order) != 'completed') continue;

      final details = order['orderDetails'] as List<dynamic>?;
      if (details == null) continue;

      for (final item in details) {
        final productName = item['productName']?.toString() ?? 'Unknown';
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
      return const Center(
        child: Text('No best selling product data available'),
      );
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
              'Top 5 Best Selling Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups:
                      topProducts.take(5).toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: product.value.toDouble(),
                              color: _getBarColor(index),
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
                            String productName = topProducts[value.toInt()].key;
                            if (productName.length > 10) {
                              productName =
                                  productName.substring(0, 10) + '...';
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
                        interval:
                            maxSales > 10 ? (maxSales / 5).ceilToDouble() : 1,
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
                    getDrawingHorizontalLine:
                        (value) => FlLine(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: isLargeScreen ? 14 : 12)),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today, size: 16),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    dialogBackgroundColor: Colors.white,
                    colorScheme: const ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              DateTime adjustedDate;
              if (label == 'To:') {
                // Set to 23:59:59 for "To" date
                adjustedDate = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  23,
                  59,
                  59,
                );
              } else {
                // Set to 00:00:00 for "From" date
                adjustedDate = DateTime(picked.year, picked.month, picked.day);
              }
              onPicked(adjustedDate);
            }
          },
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 16 : 12,
              vertical: isLargeScreen ? 12 : 8,
            ),
          ),
          label: Text(DateFormat('dd/MM/yyyy').format(initial)),
        ),
      ],
    );
  }
}
