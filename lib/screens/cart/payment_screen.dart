import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/screens/cart/components/delivery_info.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _loyaltyPointsController =
      TextEditingController();
  final double _shippingFee = 15000;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CouponProvider>(context, listen: false).loadCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final selectedItems = cartProvider.cartItems.toList();
    final totalPrice = cartProvider.totalAmount;
    final discount =
        couponProvider.appliedCoupon != null
            ? (couponProvider.appliedCoupon!.type == CouponType.percent
                ? totalPrice * couponProvider.appliedCoupon!.value
                : couponProvider.appliedCoupon!.value)
            : 0.0;

    final availableLoyaltyPoints = userProvider.user?.loyaltyPoints ?? 0;
    final loyaltyPointsUsed = int.tryParse(_loyaltyPointsController.text) ?? 0;

    final adjustedLoyaltyPointsUsed =
        loyaltyPointsUsed > availableLoyaltyPoints
            ? availableLoyaltyPoints
            : loyaltyPointsUsed;

    final loyaltyPointsDiscount = adjustedLoyaltyPointsUsed.toDouble();
    final finalTotalPrice =
        totalPrice - discount - loyaltyPointsDiscount + _shippingFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Column(
        children: [
          buildDeliveryInfo(cartProvider, context),
          _buildCouponInput(context),
          Expanded(child: _buildCartList(context, selectedItems)),
          _buildOrderSummary(
            totalPrice,
            discount,
            loyaltyPointsDiscount,
            finalTotalPrice,
            couponProvider.appliedCoupon,
          ),
        ],
      ),
      bottomNavigationBar: _buildPaymentButton(
        selectedItems,
        finalTotalPrice,
        adjustedLoyaltyPointsUsed,
      ),
    );
  }

  Widget _buildCouponInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _discountController,
              decoration: const InputDecoration(
                labelText: 'Enter coupon code',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              try {
                Provider.of<CouponProvider>(
                  context,
                  listen: false,
                ).applyCouponByCode(_discountController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coupon applied!')),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid or expired coupon')),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, List<CartItem> selectedItems) {
    if (selectedItems.isEmpty) {
      return const Center(child: Text('Your cart is empty'));
    }

    return ListView.builder(
      itemCount: selectedItems.length,
      itemBuilder: (context, index) {
        final item = selectedItems[index];
        return _buildCartItem(context, item);
      },
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Quantity: ${item.quantity}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  FormatHelper.formatCurrency(
                    item.quantity *
                        item.product.price *
                        (1 - item.product.discount),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    double totalPrice,
    double discount,
    double loyaltyPointsDiscount,
    double finalTotal,
    Coupon? appliedCoupon,
  ) {
    final availableLoyaltyPoints =
        Provider.of<UserProvider>(context).user?.loyaltyPoints ?? 0;
    bool useLoyaltyPoints = loyaltyPointsDiscount > 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text(FormatHelper.formatCurrency(totalPrice)),
            ],
          ),
          const SizedBox(height: 8),
          if (appliedCoupon != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Coupon (${appliedCoupon.code})'),
                Text('-${FormatHelper.formatCurrency(discount)}'),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'Use ${FormatHelper.formatCurrency(availableLoyaltyPoints.toDouble())} loyalty points',
              ),
              const SizedBox(width: 8),
              Switch(
                value: useLoyaltyPoints,
                onChanged: (value) {
                  setState(() {
                    useLoyaltyPoints = value;
                    _loyaltyPointsController.text =
                        useLoyaltyPoints
                            ? availableLoyaltyPoints.toString()
                            : '0';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping Fee'),
              Text('+${FormatHelper.formatCurrency(_shippingFee)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                FormatHelper.formatCurrency(finalTotal),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleProceedToPayment(
    BuildContext context,
    List<CartItem> selectedItems,
    double finalTotalPrice,
    int loyaltyPointsUsed,
  ) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final address = cartProvider.addressInfo;

    if (address == null ||
        address.receiverName.trim().isEmpty ||
        address.city.trim().isEmpty ||
        address.district.trim().isEmpty ||
        address.ward.trim().isEmpty ||
        address.detailedAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all delivery information'),
        ),
      );
      return;
    }

    // Show pending dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Prepare data before async operations
      final loyaltyPointsEarned = (finalTotalPrice * 0.1).toInt();
      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        orderDetails:
            selectedItems
                .map(
                  (item) => OrderDetail(
                    productId: item.product.id,
                    productName: item.product.name,
                    imageUrl: item.product.imageUrl,
                    variantId: item.variant.variantId,
                    colorName: item.variant.colorName,
                    quantity: item.quantity,
                    price: item.product.price,
                    discount: item.product.discount,
                  ),
                )
                .toList(),
        loyaltyPointsEarned: loyaltyPointsEarned,
        loyaltyPointsUsed: loyaltyPointsUsed,
        statusHistory: [StatusHistory(status: 'Pending', time: DateTime.now())],
        total: finalTotalPrice,
        user: OrderUserDetails(
          userId: userProvider.user?.id ?? 'guest',
          name: address.receiverName,
          email: userProvider.user?.email ?? '',
          shippingAddress:
              '${address.detailedAddress}, ${address.ward}, ${address.district}, ${address.city}',
        ),
        coupon:
            couponProvider.appliedCoupon != null
                ? OrderCouponDetails(
                  code: couponProvider.appliedCoupon!.code,
                  value: couponProvider.appliedCoupon!.value,
                )
                : null,
      );

      // Perform async operations
      await orderProvider.addOrder(order);

      if (loyaltyPointsUsed > 0) {
        await userProvider.updateLoyaltyPoints(
          pointsChange: -loyaltyPointsUsed,
          pointsUsed: loyaltyPointsUsed,
        );
      }
      if (loyaltyPointsEarned > 0) {
        await userProvider.updateLoyaltyPoints(
          pointsChange: loyaltyPointsEarned,
        );
      }

      await cartProvider.updateProductVariantInventory();
      await cartProvider.removePurchasedItems(selectedItems);

      if (couponProvider.appliedCoupon != null) {
        await couponProvider.updateCouponUsage(
          couponProvider.appliedCoupon!.id,
          order.id,
        );
      }

      // Close pending dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show success dialog
      showSuccessDialog(context);
    } catch (e) {
      // Close pending dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred during payment. Please try again.'),
        ),
      );
    }
  }

  Widget _buildPaymentButton(
    List<CartItem> selectedItems,
    double finalTotalPrice,
    int loyaltyPointsUsed,
  ) {
    final hasSelectedItems = selectedItems.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: ElevatedButton(
        onPressed:
            hasSelectedItems
                ? () => _handleProceedToPayment(
                  context,
                  selectedItems,
                  finalTotalPrice,
                  loyaltyPointsUsed,
                )
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasSelectedItems ? primaryColor : Colors.grey.shade300,
          foregroundColor: hasSelectedItems ? Colors.white : Colors.black54,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          hasSelectedItems ? 'Proceed to Payment' : 'Select items to continue',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Congrats! your payment is successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your order or just chat directly to the seller. '
                  'Download order summary in document below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.insert_drive_file_outlined),
                    SizedBox(width: 6),
                    Text('order_invoice.pdf'),
                    Spacer(),
                    Icon(Icons.download_for_offline_outlined),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // đóng dialog
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
