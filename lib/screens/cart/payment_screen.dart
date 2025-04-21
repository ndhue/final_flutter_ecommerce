import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/screens/cart/components/auth_dialogs.dart';
import 'package:final_ecommerce/screens/cart/components/delivery_info.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:final_ecommerce/utils/utils.dart';
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

  // Controllers for guest account creation
  final TextEditingController _passwordController = TextEditingController();
  bool _isCreatingAccount = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final availablePoints = convertVndToPoints(availableLoyaltyPoints);
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
              Text('Use ${formatNumber(availablePoints)} loyalty points'),
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
          if (useLoyaltyPoints)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Points discount'),
                  Text(
                    '-${FormatHelper.formatCurrency(loyaltyPointsDiscount)}',
                  ),
                ],
              ),
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
    final cartProvider = context.read<CartProvider>();
    final couponProvider = context.read<CouponProvider>();
    final userProvider = context.read<UserProvider>();
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();
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

    // Handle guest checkout - check if we have guest info
    if (authProvider.user == null && cartProvider.isGuestUser) {
      final guestInfo = cartProvider.guestCheckoutInfo;

      if (guestInfo == null || !guestInfo.containsKey('email')) {
        // If no guest info, prompt user to provide email
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide delivery information first'),
          ),
        );
        return;
      }

      // If we have guest info but no password, prompt for account creation
      if (!guestInfo.containsKey('password') || guestInfo['password'].isEmpty) {
        _showGuestAccountPrompt(context);
        return;
      }

      // Try to create account for guest with provided info
      final email = guestInfo['email'];
      final password = guestInfo['password'];
      final name = guestInfo['fullName'] ?? address.receiverName;
      final shippingAddress =
          '${address.detailedAddress}, ${address.ward}, ${address.district}, ${address.city}';

      // Show pending dialog
      setState(() => _isCreatingAccount = true);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Create account for guest
        final success = await authProvider.createGuestAccount(
          email,
          password,
          name,
          shippingAddress,
          address.ward,
          address.district,
          address.city,
        );

        if (!context.mounted) return;

        if (!success) {
          // Close dialog
          Navigator.of(context).pop();

          // Show login prompt if account already exists
          _showLoginPrompt(context, email);
          return;
        }

        // Convert guest cart to user cart
        await cartProvider.convertGuestCartToUser(authProvider.user!.uid);
      } catch (e) {
        if (!context.mounted) return;

        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account. Please try again.'),
          ),
        );
        return;
      } finally {
        setState(() => _isCreatingAccount = false);
      }
    }

    // Show pending dialog if not already showing
    if (!_isCreatingAccount && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // Calculate loyalty points earned (10% of final total in VND)
      final loyaltyPointsEarned = (finalTotalPrice * 0.1).toInt();

      // Determine user ID - either from logged in user or newly created account
      String userId;
      if (userProvider.user != null) {
        userId = userProvider.user!.id;
      } else if (authProvider.user != null) {
        userId = authProvider.user!.uid;
      } else {
        userId = 'guest';
      }

      // Get user email
      final email =
          userProvider.user?.email ??
          (cartProvider.guestCheckoutInfo?['email'] ??
              authProvider.user?.email ??
              '');

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
          userId: userId, // Now using the correctly determined userId
          name: address.receiverName,
          email: email,
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

      // Handle guest order with guest checkout info if needed
      if (cartProvider.isGuestUser && cartProvider.guestCheckoutInfo != null) {
        await orderProvider.createGuestOrder(
          order,
          cartProvider.guestCheckoutInfo!,
        );
      } else {
        // Normal order flow
        await orderProvider.addOrder(order);
      }

      if (loyaltyPointsUsed > 0) {
        if (userProvider.user?.id != null && userProvider.user?.id != 'guest') {
          await userProvider.updateLoyaltyPoints(
            pointsChange: -loyaltyPointsUsed,
            pointsUsed: loyaltyPointsUsed,
          );
        }
      }

      // Add earned points (directly in VND value - consistent with profile screen)
      if (loyaltyPointsEarned > 0) {
        // Only update loyalty points if this is not a guest (has a user ID)
        if (userProvider.user?.id != null && userProvider.user?.id != 'guest') {
          await userProvider.updateLoyaltyPoints(
            pointsChange: loyaltyPointsEarned,
          );
        }
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

  // Show prompt for guest to create an account
  void _showGuestAccountPrompt(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final guestInfo = cartProvider.guestCheckoutInfo;
    final email = guestInfo?['email'] ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create an Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Continue as $email'),
                const SizedBox(height: 16),
                const Text(
                  'Create a password to access your orders in the future.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_passwordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password must be at least 6 characters'),
                      ),
                    );
                    return;
                  }

                  // Save password to guest info
                  Map<String, dynamic> updatedInfo = Map.from(guestInfo!);
                  updatedInfo['password'] = _passwordController.text;
                  cartProvider.saveGuestCheckoutInfo(updatedInfo);

                  Navigator.of(context).pop();

                  // Re-trigger payment process
                  _handleProceedToPayment(
                    context,
                    cartProvider.cartItems.toList(),
                    cartProvider.totalAmount + _shippingFee,
                    0, // No loyalty points for new accounts
                  );
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
    );
  }

  // Show login prompt for existing accounts
  void _showLoginPrompt(BuildContext context, String email) async {
    // Import the AuthDialogs utility
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Use the external dialog utility for login
    bool success = await AuthDialogs.showLoginPrompt(context, email);

    // If login was successful, handle cart conversion and order processing
    if (success && context.mounted && authProvider.user != null) {
      // Associate guest orders with the user and convert guest cart
      await orderProvider.associateGuestOrdersWithUser(
        email,
        authProvider.user!.uid,
      );
      await cartProvider.convertGuestCartToUser(authProvider.user!.uid);

      // Re-trigger payment process
      if (context.mounted) {
        _handleProceedToPayment(
          context,
          cartProvider.cartItems.toList(),
          cartProvider.totalAmount + _shippingFee,
          0,
        );
      }
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
                  'Congrats! your payment is successful',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your order or just chat directly to the seller.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
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
