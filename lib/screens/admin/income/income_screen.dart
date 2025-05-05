import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:final_ecommerce/models/orders_model.dart';
import 'order_details_screen.dart';

class OrderManagerScreen extends StatefulWidget {
  @override
  State<OrderManagerScreen> createState() => _OrderManagerScreenState();
}

class _OrderManagerScreenState extends State<OrderManagerScreen> {
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đơn hàng')),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có đơn hàng nào.'));
          }

          final orders = snapshot.data!;
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final order = orders[index];
              final latestStatus =
                  order.statusHistory.isNotEmpty
                      ? order.statusHistory.last.status
                      : 'Không rõ';

              return ListTile(
                leading: Icon(Icons.person),
                title: Text(order.user.email),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng: ${_formatCurrency(order.total)}'),
                    Text('Trạng thái: $latestStatus'),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  );

                  if (result == true) {
                    setState(() {
                      _ordersFuture = fetchOrders();
                    });
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(value);
  }
}
