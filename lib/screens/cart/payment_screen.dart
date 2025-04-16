import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/coupon_provider.dart';
import 'package:final_ecommerce/screens/cart/components/delivery_info.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _discountController = TextEditingController();
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

    final selectedItems = cartProvider.cartItems.toList();
    final totalPrice = cartProvider.totalAmount;
    final discountValue = couponProvider.appliedCoupon?.value ?? 0.0;
    final discount = totalPrice * discountValue;
    final finalTotalPrice = totalPrice - discount + _shippingFee;

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
            finalTotalPrice,
            couponProvider.appliedCoupon,
          ),
        ],
      ),
      bottomNavigationBar: _buildPaymentButton(selectedItems, finalTotalPrice),
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
            color: Colors.grey.withOpacity(0.1),
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
    double finalTotal,
    Coupon? appliedCoupon,
  ) {
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

  Widget _buildPaymentButton(
    List<CartItem> selectedItems,
    double finalTotalPrice,
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
                ? () {
                  // Payment logic here
                  final address =
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addressInfo;

                  if (address == null ||
                      address.receiverName.trim().isEmpty ||
                      address.city.trim().isEmpty ||
                      address.district.trim().isEmpty ||
                      address.ward.trim().isEmpty ||
                      address.detailedAddress.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill in all delivery information',
                        ),
                      ),
                    );
                  } else {
                    showSuccessDialog(context);

                    // TODO: Gửi đơn hàng về server hoặc Firebase tại đây
                  }
                }
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
