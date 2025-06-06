import 'package:final_ecommerce/models/orders_model.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/utils/order_actions.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isProcessing = false;
  late String _currentStatus;
  final List<String> _availableStatuses = [
    'Pending',
    'Confirmed',
    'Shipping',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus =
        widget.order.statusHistory.isNotEmpty
            ? widget.order.statusHistory.first.status
            : 'Pending';
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    if (_currentStatus == newStatus) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create new status update
      final statusUpdate = StatusHistory(
        status: newStatus,
        time: DateTime.now(),
      );

      // Use OrderProvider to update the status
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.updateOrderStatus(widget.order.id, statusUpdate);

      // Special handling for Cancelled status
      if (newStatus == 'Cancelled') {
        await _handleCancelOrder();
      }

      // Special handling for Delivered status
      if (newStatus == 'Delivered') {
        await _handleDeliverOrder();
      }

      // Update the local state
      setState(() {
        _currentStatus = newStatus;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );

      // Return true when navigating back to trigger a refresh
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleCancelOrder() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final variantProvider = Provider.of<VariantProvider>(
      context,
      listen: false,
    );

    // Revert loyalty points if used
    if (widget.order.loyaltyPointsUsed > 0) {
      await userProvider.updateLoyaltyPoints(
        pointsChange: widget.order.loyaltyPointsUsed,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Returned ${widget.order.loyaltyPointsUsed} loyalty points to user account',
          ),
        ),
      );
    }

    // Revert coupon usage if applied
    if (widget.order.coupon != null) {
      await couponProvider.updateCouponUsage(
        widget.order.coupon!.code,
        widget.order.id,
        revert: true,
      );
    }

    // Return inventory for product variants
    for (final detail in widget.order.orderDetails) {
      await variantProvider.updateVariantInventory(
        productId: detail.productId,
        variantId: detail.variantId,
        quantityChange: detail.quantity,
      );
    }
  }

  Future<void> _handleDeliverOrder() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Update sellCount for each product in the order
    for (final detail in widget.order.orderDetails) {
      await productProvider.incrementSellCount(
        productId: detail.productId,
        quantity: detail.quantity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.order.id.substring(0, min(widget.order.id.length, 8))}',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 20),
              _buildOrderDetailsCard(),
              const SizedBox(height: 20),
              _buildCustomerInfoCard(),
              const SizedBox(height: 20),
              _buildItemsCard(),
              const SizedBox(height: 20),
              _buildStatusHistoryCard(),
              if (widget.order.loyaltyPointsEarned > 0 ||
                  widget.order.loyaltyPointsUsed > 0) ...[
                const SizedBox(height: 20),
                _buildLoyaltyPointsCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.update, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Current Status:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(_currentStatus),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _currentStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableStatuses.map((status) {
                    final isCurrentStatus = status == _currentStatus;
                    return InkWell(
                      onTap:
                          _isProcessing || isCurrentStatus
                              ? null
                              : () => _updateOrderStatus(status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isCurrentStatus
                                  ? getStatusColor(status)
                                  : getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: getStatusColor(status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color:
                                isCurrentStatus
                                    ? Colors.white
                                    : getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    // Get the creation date from the order
    final dateFormatted = formatDateTime(widget.order.createdAt);

    // Calculate subtotal from orderDetails
    final subtotal = widget.order.orderDetails.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // Calculate discount
    final discount = widget.order.orderDetails.fold<double>(
      0,
      (sum, item) => sum + item.discount,
    );

    // Calculate shipping (assumed to be the difference)
    final shipping = widget.order.total - subtotal + discount;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildDetailRow('Order ID', widget.order.id),
            _buildDetailRow('Date', dateFormatted),
            _buildDetailRow(
              'Total Items',
              widget.order.orderDetails
                  .fold<int>(0, (sum, item) => sum + item.quantity)
                  .toString(),
            ),
            _buildDetailRow('Subtotal', _formatCurrency(subtotal)),

            if (shipping > 0)
              _buildDetailRow('Shipping', _formatCurrency(shipping)),

            if (discount > 0)
              _buildDetailRow('Discount', _formatCurrency(discount)),

            if (widget.order.coupon != null)
              _buildDetailRow(
                'Coupon (${widget.order.coupon!.code})',
                _formatCurrency(widget.order.coupon!.value),
              ),

            if (widget.order.loyaltyPointsUsed > 0)
              _buildDetailRow(
                'Loyalty Points Used',
                '${widget.order.loyaltyPointsUsed / 10000} points',
              ),

            const Divider(),
            _buildDetailRow(
              'Total',
              _formatCurrency(widget.order.total),
              valueBold: true,
              valueColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildDetailRow('Name', widget.order.user.name),
            _buildDetailRow('Email', widget.order.user.email),
            const SizedBox(height: 8),
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.order.user.shippingAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.orderDetails.length,
              itemBuilder: (context, index) {
                final item = widget.order.orderDetails[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          item.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, size: 20),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.colorName.isNotEmpty)
                              Text(
                                'Color: ${item.colorName}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatCurrency(item.price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text('x${item.quantity}'),
                              ],
                            ),
                            if (item.discount > 0)
                              Text(
                                'Discount: ${_formatCurrency(item.discount)}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatCurrency(
                          item.price * item.quantity - item.discount,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyPointsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.stars, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Loyalty Points',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            if (widget.order.loyaltyPointsEarned > 0)
              _buildDetailRow(
                'Points Earned',
                '${(widget.order.loyaltyPointsEarned / 10000).toInt()} points',
                valueColor: Colors.green,
              ),
            if (widget.order.loyaltyPointsUsed > 0)
              _buildDetailRow(
                'Points Used',
                '${widget.order.loyaltyPointsUsed / 10000} points',
                valueColor: Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistoryCard() {
    if (widget.order.statusHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.statusHistory.length,
              itemBuilder: (context, index) {
                // Show status history in reverse chronological order
                final statusUpdate =
                    widget.order.statusHistory[widget
                            .order
                            .statusHistory
                            .length -
                        1 -
                        index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: getStatusColor(statusUpdate.status),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusUpdate.status,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatDateTime(statusUpdate.time),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool valueBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(value);
  }
}

// Helper function to get minimum value
int min(int a, int b) => a < b ? a : b;
