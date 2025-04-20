import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/screens/orders/components/rate_order_widget.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'components/track_order_widget.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  String formatDate(DateTime date) {
    return DateFormat("d'th' MMM yyyy").format(date);
  }

  Future<void> handleCancelOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Order'),
            content: const Text('Are you sure you want to cancel this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final couponProvider = Provider.of<CouponProvider>(
        context,
        listen: false,
      );
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final variantProvider = Provider.of<VariantProvider>(
        context,
        listen: false,
      );

      // Revert loyalty points if used
      if (order.loyaltyPointsUsed > 0) {
        await userProvider.updateLoyaltyPoints(
          pointsChange: order.loyaltyPointsUsed,
        );
      }

      // Revert coupon usage if applied
      if (order.coupon != null) {
        await couponProvider.updateCouponUsage(
          order.coupon!.code,
          order.id,
          revert: true,
        );
      }

      // Return inventory for product variants
      for (final detail in order.orderDetails) {
        await variantProvider.updateVariantInventory(
          productId: detail.productId,
          variantId: detail.variantId,
          quantityChange: detail.quantity,
        );
      }

      // Update order status to canceled
      await orderProvider.updateOrderStatus(
        order.id,
        StatusHistory(status: 'Canceled', time: DateTime.now()),
      );

      Fluttertoast.showToast(
        msg: 'Order canceled successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

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
          handleCancelOrder(context);
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
            color: Colors.black.withValues(alpha: 0.1),
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
    final status = order.statusHistory.first.status;
    final updatedDate = order.statusHistory.first.time;

    debugPrint(status);
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ORDER ID: ${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: darkTextColor,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.id));
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getStatusColor(status).withValues(alpha: 0.2),
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
                    formatDate(updatedDate),
                    style: const TextStyle(fontSize: 12, color: darkTextColor),
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
                  color: Colors.black.withValues(alpha: 0.1),
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
                  FormatHelper.formatCurrency(order.total),
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: OrderDetailsList(orderDetails: order.orderDetails),
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
