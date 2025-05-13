import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> handleCancelOrder(BuildContext context, OrderModel order) async {
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
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
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

    // Create and insert the new status at the beginning of the array
    final newStatus = StatusHistory(status: 'Canceled', time: DateTime.now());
    order.statusHistory.insert(0, newStatus);
    await orderProvider.updateOrderStatusLocally(order.id, newStatus);

    Fluttertoast.showToast(
      msg: 'Order canceled successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}

Future<void> handleCompleteOrder(BuildContext context, OrderModel order) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Complete Order'),
          content: const Text('Mark this order as completed?'),
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
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Award loyalty points when user marks order as completed
    if (order.loyaltyPointsEarned > 0) {
      await userProvider.updateLoyaltyPoints(
        pointsChange: order.loyaltyPointsEarned,
      );

      Fluttertoast.showToast(
        msg:
            'Earned ${NumberFormat.decimalPattern().format(order.loyaltyPointsEarned / 10000)} loyalty points!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }

    // Create and insert the new status at the beginning of the array
    final newStatus = StatusHistory(status: 'Completed', time: DateTime.now());
    order.statusHistory.insert(0, newStatus);
    await orderProvider.updateOrderStatusLocally(order.id, newStatus);

    Fluttertoast.showToast(
      msg: 'Order marked as completed',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}

List<String> getActionsForStatus(String status) {
  switch (status) {
    case 'Pending':
      return ['Cancel', 'Track'];
    case 'Confirmed':
    case 'Shipping':
      return ['Track'];
    case 'Delivered':
      return ['Track', 'Complete'];
    case 'Completed':
    case 'Cancelled':
    default:
      return ['Track'];
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'Pending':
      return Colors.orange;
    case 'Confirmed':
      return Colors.blue;
    case 'Shipping':
      return Colors.purple;
    case 'Delivered':
      return Colors.green.shade600;
    case 'Completed':
      return Colors.green.shade900;
    case 'Cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class TrackOrderBottomSheet extends StatelessWidget {
  final List<StatusHistory> statusHistory;

  const TrackOrderBottomSheet({super.key, required this.statusHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track Order',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...statusHistory.map((status) {
            return ListTile(
              leading: Icon(
                Icons.circle,
                color: getStatusColor(status.status),
                size: 12,
              ),
              title: Text(status.status),
              subtitle: Text(formatDateTime(status.time)),
            );
          }),
        ],
      ),
    );
  }
}
