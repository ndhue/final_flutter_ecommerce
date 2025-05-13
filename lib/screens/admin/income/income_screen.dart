import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/orders_model.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'order_details_screen.dart';

class OrderManagerScreen extends StatefulWidget {
  @override
  State<OrderManagerScreen> createState() => _OrderManagerScreenState();
}

class _OrderManagerScreenState extends State<OrderManagerScreen> {
  late Future<List<OrderModel>> _ordersFuture;
  bool _isLocalLoading = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<OrderModel>> fetchOrders() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return OrderModel.fromJson(data);
    }).toList();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _isLocalLoading = true;
      _ordersFuture = fetchOrders();
    });
    await _ordersFuture;
    if (mounted) {
      setState(() {
        _isLocalLoading = false;
      });
    }
  }

  void _searchOrders(String query) {
    setState(() {
      _searchQuery = query;
      _ordersFuture = fetchOrders().then((orders) {
        if (query.isEmpty) return orders;

        return orders.where((order) {
          return order.user.email.toLowerCase().contains(query.toLowerCase()) ||
              order.id.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    });
  }

  int getTotalOrders(List<OrderModel> orders) => orders.length;

  int getCompletedOrders(List<OrderModel> orders) {
    return orders
        .where(
          (order) =>
              order.statusHistory.isNotEmpty &&
              order.statusHistory.last.status == 'Delivered',
        )
        .length;
  }

  int getPendingOrders(List<OrderModel> orders) {
    return orders
        .where(
          (order) =>
              order.statusHistory.isEmpty ||
              order.statusHistory.last.status != 'Delivered',
        )
        .length;
  }

  double getTotalRevenue(List<OrderModel> orders) {
    return orders.fold(0, (sum, order) => sum + order.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLocalLoading ? null : _refreshOrders,
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search orders...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchOrders('');
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: _searchOrders,
                textInputAction: TextInputAction.search,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<OrderModel>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      _isLocalLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No orders found'
                                : 'No orders matching "$_searchQuery"',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final orders = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildStatCard(
                              total: getTotalOrders(orders),
                              title: 'Total Orders',
                              value: getTotalOrders(orders),
                              icon: Icons.shopping_bag,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              total: getTotalOrders(orders),
                              title: 'Completed',
                              value: getCompletedOrders(orders),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              total: getTotalOrders(orders),
                              title: 'Pending',
                              value: getPendingOrders(orders),
                              icon: Icons.pending_actions,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Orders',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Total Revenue: ${FormatHelper.formatCurrency(getTotalRevenue(orders))}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildOrderTable(orders),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTable(List<OrderModel> orders) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              dividerThickness: 1,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 80,
              columnSpacing: 24,
              headingRowHeight: 50,
              headingRowColor: MaterialStateProperty.resolveWith(
                (states) => Colors.grey[50],
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Order ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Customer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: List.generate(orders.length, (index) {
                final order = orders[index];
                final latestStatus =
                    order.statusHistory.isNotEmpty
                        ? order.statusHistory.last.status
                        : 'Pending';

                final orderDate =
                    order.statusHistory.isNotEmpty
                        ? order.statusHistory.first.time
                        : DateTime.now();

                final formattedDate = DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(orderDate);

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        order.id.substring(0, 8),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          order.user.email,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(Text(formattedDate)),
                    DataCell(Text(FormatHelper.formatCurrency(order.total))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(latestStatus),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          latestStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => OrderDetailScreen(order: order),
                                ),
                              );

                              if (result == true) {
                                _refreshOrders();
                              }
                            },
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
