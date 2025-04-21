import 'package:final_ecommerce/data/mock_data.dart';
import 'package:final_ecommerce/data/orders_data.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //format date

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = getTotalOrders(orders);
    final completed = getCompletedOrders(orders);
    final pending = getPendingOrders(orders);
    final deliver = getDeliverOrders(orders);
    final revenue = calculateMonthlyRevenue(orders);
    final profit = calculateProfit(orders);
    final canceled = getCanceledOrders(orders);

    final orderData = {
      'Total Orders': total,
      'Completed': completed,
      'Revenue': revenue,
      'Profit': profit,
    };

    final statusCounts = {
      'Pending': pending,
      'Delivered': deliver,
      'Completed': completed,
      'Canceled': canceled,
    };

    final statusColor = {
      'Pending': Colors.orange,
      'Delivered': Colors.blue,
      'Completed': Colors.green,
      'Canceled': Colors.red,
    };
    DateTime selectedDate = DateTime.now();
    String selectedDay =
        'Ngày: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
    String selectedMonth =
        'Tháng: ${DateFormat('MM/yyyy').format(DateTime.now())}';
    String selectedYear = 'Năm: ${DateFormat('yyyy').format(DateTime.now())}';

    final pieSections =
        statusCounts.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.value}',
            color: statusColor[entry.key]!,
            radius: 30,
            titleStyle: TextStyle(
              fontSize: 14,
              color: entry.key == 'Packaging' ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
            showTitle: true,
          );
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final selected = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                  1000,
                  80,
                  10,
                  0,
                ), // Vị trí popup, bạn có thể tinh chỉnh
                items: [
                  const PopupMenuItem(
                    value: 'ngay',
                    child: Text('Sắp xếp theo Ngày'),
                  ),
                  const PopupMenuItem(
                    value: 'thang',
                    child: Text('Sắp xếp theo Tháng'),
                  ),
                  const PopupMenuItem(
                    value: 'nam',
                    child: Text('Sắp xếp theo Năm'),
                  ),
                ],
              );

              if (selected != null) {
                switch (selected) {
                  case 'ngay':
                    //dort ngày
                    break;
                  case 'thang':
                    //sort tháng
                    break;
                  case 'nam':
                    // sort năm
                    break;
                }
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          Widget orderCards = Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                orderData.entries.map((entry) {
                  return SizedBox(
                    width: isWideScreen ? (constraints.maxWidth / 4 - 24) : 160,
                    child: _buildStatCard(entry.key, entry.value),
                  );
                }).toList(),
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                orderCards,
                const SizedBox(height: 24),
                Expanded(
                  child:
                      isWideScreen
                          ? Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildPieChart(statusColor, pieSections),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: _buildTopSellingBarChart(),
                              ),
                            ],
                          )
                          : Column(
                            children: [
                              SizedBox(
                                height: 300,
                                child: _buildPieChart(statusColor, pieSections),
                              ),
                              const SizedBox(height: 16),
                              Expanded(child: _buildTopSellingBarChart()),
                            ],
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, num value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              (title == 'Revenue' || title == 'Profit')
                  ? FormatHelper.formatCurrency(value)
                  : value.toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, Color> statusColor,
    List<PieChartSectionData> pieSections,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest.shortestSide;
                  return PieChart(
                    PieChartData(
                      sections:
                          pieSections.map((section) {
                            return section.copyWith(radius: size * 0.15);
                          }).toList(),
                      centerSpaceRadius: size * 0.4,
                      sectionsSpace: 2,
                      startDegreeOffset: -90,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  statusColor.entries.map((entry) {
                    return _buildLegendItem(entry.key, entry.value);
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingBarChart() {
    final topProducts =
        List<Product>.from(products)
          ..sort((a, b) => b.salesCount.compareTo(a.salesCount))
          ..removeWhere((product) => product.salesCount == 0);

    final top5 = topProducts.take(5).toList();
    final barGroups =
        top5
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.salesCount.toDouble(),
                    color: _getBarColor(entry.key),
                    borderRadius: BorderRadius.circular(4),
                    width: 22,
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
            )
            .toList();

    final maxSales = top5.fold(
      0,
      (max, product) => product.salesCount > max ? product.salesCount : max,
    );

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
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      //tooltipBgColor: Colors.blueGrey.withOpacity(0.9),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final product = top5[group.x.toInt()];
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget:
                            (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        interval:
                            maxSales > 10 ? (maxSales / 5).ceilToDouble() : 1,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < top5.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                top5[value.toInt()].name,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 42,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (value) => FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                    checkToShowHorizontalLine: (value) => value % 5 == 0,
                  ),
                  barGroups: barGroups,
                  maxY: maxSales.toDouble() * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(int index) {
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];
    return colors[index % colors.length];
  }

  Widget _buildProductItem(String name, Color color, int sales) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$sales',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

num getTotalOrders(List<Map<String, dynamic>> orders) {
  num total = 0;
  for (var order in orders) {
    total += 1 ?? 0;
  }
  return total;
}

num getCompletedOrders(List<Map<String, dynamic>> orders) {
  num total = 0;
  for (var order in orders) {
    if (order['orderStatus'] == 'Completed') {
      total += 1 ?? 0;
    }
  }
  return total;
}

num getPendingOrders(List<Map<String, dynamic>> orders) {
  num total = 0;
  for (var order in orders) {
    if (order['orderStatus'] == 'Pending') {
      total += 1 ?? 0;
    }
  }
  return total;
}

num getDeliverOrders(List<Map<String, dynamic>> orders) {
  num total = 0;
  for (var order in orders) {
    if (order['orderStatus'] == 'Delivered') {
      total += 1 ?? 0;
    }
  }
  return total;
}

num getCanceledOrders(List<Map<String, dynamic>> orders) {
  num total = 0;
  for (var order in orders) {
    if (order['orderStatus'] == 'Cancelled') {
      total += 1 ?? 0;
    }
  }
  return total;
}

double calculateMonthlyRevenue(List<Map<String, dynamic>> orders) {
  final now = DateTime.now();
  double revenue = 0.0;

  for (final order in orders) {
    final createdAt = DateTime.parse(order['createdAt']);
    if (createdAt.month == now.month && createdAt.year == now.year) {
      for (final detail in order['orderDetails']) {
        final finalPrice = detail['finalPrice'];
        final quantity = detail['quantity'];
        revenue +=
            (finalPrice is String ? double.parse(finalPrice) : finalPrice) *
            quantity;
      }
    }
  }

  return revenue;
}

double calculateProfit(List<Map<String, dynamic>> orders) {
  final now = DateTime.now();
  double revenue = 0.0;

  for (final order in orders) {
    final createdAt = DateTime.parse(order['createdAt']);
    if (createdAt.month == now.month && createdAt.year == now.year) {
      for (final detail in order['orderDetails']) {
        final finalPrice = detail['finalPrice'];
        final quantity = detail['quantity'];
        revenue +=
            (finalPrice is String ? double.parse(finalPrice) : finalPrice) *
            quantity;
      }
    }
  }

  return revenue;
}
