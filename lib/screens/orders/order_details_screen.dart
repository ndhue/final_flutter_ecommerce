import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/screens/orders/components/rate_order_widget.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:final_ecommerce/utils/order_actions.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  List<Widget> getActions(BuildContext context, String status) {
    final actions = <Widget>[
      buildAction(Icons.local_shipping, 'Track Order', () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return TrackOrderBottomSheet(statusHistory: order.statusHistory);
          },
        );
      }),
    ];

    if (status == 'Pending') {
      actions.addAll([
        buildAction(Icons.cancel, 'Cancel Order', () {
          handleCancelOrder(context, order);
        }),
      ]);
    }

    return actions;
  }

  Widget buildAction(IconData icon, String label, GestureTapCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final updatedOrder = orderProvider.orders.firstWhere(
          (o) => o.id == order.id,
          orElse: () => order,
        );

        final status = updatedOrder.statusHistory.first.status;
        final updatedDate = updatedOrder.statusHistory.first.time;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Details'),
            actions: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.help_outline),
                label: const Text('Help'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 46,
            ),
            children: [
              // Order ID + Copy
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ORDER ID: ${updatedOrder.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: darkTextColor,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: updatedOrder.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order ID copied to clipboard'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Order Status box wrapped in a shadowed container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        formatDateTime(updatedDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: darkTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Total Price box wrapped in a shadowed container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      FormatHelper.formatCurrency(updatedOrder.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Product details wrapped in a shadowed container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OrderDetailsList(
                    orderDetails: updatedOrder.orderDetails,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              RateOrderWidget(),
              const SizedBox(height: 16),

              // Action buttons
              ...getActions(context, status),
            ],
          ),
        );
      },
    );
  }
}

class OrderDetailsList extends StatelessWidget {
  final List<OrderDetail> orderDetails;

  const OrderDetailsList({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          orderDetails.map((product) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      product.imageUrl,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 70,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              FormatHelper.formatCurrency(product.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (product.discount! > 0)
                              Text(
                                FormatHelper.formatCurrency(
                                  product.price * (1 - product.discount!),
                                ),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Variant: ${product.colorName}',
                          style: TextStyle(color: darkTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
