import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/orders_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus =
        widget.order.statusHistory.isNotEmpty
            ? widget.order.statusHistory.last.status
            : 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(title: Text('Order DetailsDetails')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adress', style: TextStyle(fontWeight: FontWeight.bold)),

            Text(order.user.shippingAddress),
            SizedBox(height: 20),

            Text(
              '🧾 Ordered Products',

              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order.orderDetails.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.productName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ${item.quantity}'),
                      Text('Colour: ${item.colorName}'),
                      Text('Price: ${_formatCurrency(item.price)}'),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Text(
              '🛠 Order Status',

              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(border: OutlineInputBorder()),
              items:
                  ['Pending', 'Completed', 'Canceled'].map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedStatus = value;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _saveStatus,

                child: Text('Status Updates'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveStatus() async {
    final now = DateTime.now();
    final newStatus = StatusHistory(status: selectedStatus, time: now);

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({
            'statusHistory': FieldValue.arrayUnion([
              {
                'status': newStatus.status,
                'time': Timestamp.fromDate(newStatus.time),
              },
            ]),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Status Update Successful')));

      Navigator.pop(context, true); // 👈 báo về màn hình trước là đã cập nhật
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌Update failure: $e')));
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(value);
  }
}
