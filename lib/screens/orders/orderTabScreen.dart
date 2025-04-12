import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../orders/order_history.dart';

class OrderTabsScreen extends StatefulWidget {
  const OrderTabsScreen({super.key});

  @override
  State<OrderTabsScreen> createState() => _OrderTabsScreenState();
}

class _OrderTabsScreenState extends State<OrderTabsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lịch sử đơn hàng",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.green,
          isScrollable: true,
          tabs: const [
            Tab(text: "Chờ xác nhận"),
            Tab(text: "Đang vận chuyển"),
            Tab(text: "Đã giao"),
            Tab(text: "Đã hủy"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(
            orderProvider.getByStatus("pending"),
            "Chưa có đơn hàng chờ xác nhận",
          ),
          _buildOrderList(
            orderProvider.getByStatus("shipping"),
            "Đơn hàng đang vận chuyển",
          ),
          _buildOrderList(
            orderProvider.getByStatus("delivered"),
            "Không có đơn đã giao",
          ),
          _buildOrderList(
            orderProvider.getByStatus("cancelled"),
            "Không có đơn hàng đã hủy",
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String emptyText) {
    if (orders.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text(order.productName),
          subtitle: Text(
            "Số lượng: ${order.quantity} | Tổng tiền: ${order.price.toStringAsFixed(2)}₫",
          ),
          trailing: Text(
            order.status,
            style: const TextStyle(color: Colors.green),
          ),
        );
      },
    );
  }
}
