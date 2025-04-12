import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../cart/addressPicker.dart';
import '../orders/orderTabScreen.dart';
import '../orders/order_history.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool showAllItems = false;
  int _selectedDelivery = 1;
  int _selectedPayment = 1;
  TextEditingController _discountController = TextEditingController();
  String _appliedDiscountCode = "";
  double _discountValue = 0.0;
  double _shippingFee = 14.99;
  String _selectedDeliveryOption = "Express";
  String _selectedPaymentMethod = "Credit Card";

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final selectedItems = cartProvider.selectedItems.toList();
    final totalPrice = cartProvider.selectedTotalPrice;
    final discount = totalPrice * _discountValue;
    final finalTotalPrice = totalPrice - discount + _shippingFee;
    final totalItems = selectedItems.length;

    final displayedItems =
        showAllItems ? selectedItems : selectedItems.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(context, cartProvider),
            const SizedBox(height: 16),
            _buildCartItems(displayedItems),
            if (selectedItems.length > 3)
              TextButton(
                onPressed: () {
                  setState(() {
                    showAllItems = !showAllItems;
                  });
                },
                child: Text(showAllItems ? 'Hide list' : 'Show all items'),
              ),
            _buildExpandableSections(),
            _buildOrderSummary(
              totalItems,
              totalPrice,
              discount,
              finalTotalPrice,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildPaymentButton(selectedItems, finalTotalPrice),
    );
  }

  Widget _buildCartItems(List selectedItems) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: selectedItems.length,
          itemBuilder: (context, index) {
            final item = selectedItems[index];
            return Card(
              child: ListTile(
                leading: Image.network(
                  item.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.price}₫',
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                    Text(
                      'Số lượng: ${item.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Tổng: ${item.price * item.quantity}₫',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpandableSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          ExpansionTile(
            title: const Text(
              'Select the delivery option',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              RadioListTile<String>(
                value: "Express",
                groupValue: _selectedDeliveryOption,
                onChanged: (value) {
                  setState(() {
                    _selectedDeliveryOption = value!;
                    _shippingFee = 14.99;
                  });
                },
                title: const Text('Express: 1-3 days delivery - \$14.99'),
              ),
              RadioListTile<String>(
                value: "Regular",
                groupValue: _selectedDeliveryOption,
                onChanged: (value) {
                  setState(() {
                    _selectedDeliveryOption = value!;
                    _shippingFee = 7.99;
                  });
                },
                title: const Text('Regular: 2-4 days delivery - \$7.99'),
              ),
              RadioListTile<String>(
                value: "Cargo",
                groupValue: _selectedDeliveryOption,
                onChanged: (value) {
                  setState(() {
                    _selectedDeliveryOption = value!;
                    _shippingFee = 2.99;
                  });
                },
                title: const Text('Cargo: 7-14 days delivery - \$2.99'),
              ),
            ],
          ),
          _buildSelectedOption('Delivery Option', _selectedDeliveryOption),
          ExpansionTile(
            title: const Text(
              'Apply a discount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              TextField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'Enter discount code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _appliedDiscountCode =
                          _discountController.text.trim().toUpperCase();
                      if (_appliedDiscountCode == "SALE10" ||
                          _appliedDiscountCode == "HAG") {
                        _discountValue = 0.1;
                      } else {
                        _discountValue = 0.0;
                      }
                    });
                  },
                  child: const Text('Apply'),
                ),
              ),
              if (_appliedDiscountCode.isNotEmpty)
                Text(
                  _discountValue > 0
                      ? '✅ Discount applied: $_appliedDiscountCode (-${(_discountValue * 100).round()}%)'
                      : '❌ Invalid discount code',
                  style: TextStyle(
                    color: _discountValue > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          _buildSelectedOption('Discount Code', _appliedDiscountCode),
          ExpansionTile(
            title: const Text(
              'Select Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              RadioListTile<int>(
                value: 1,
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value!;
                  });
                },
                title: const Text('Credit Card'),
              ),
              RadioListTile<int>(
                value: 2,
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value!;
                  });
                },
                title: const Text('Cash on Delivery'),
              ),
            ],
          ),
          _buildSelectedOption(
            'Payment Method',
            _selectedPayment == 1 ? 'Credit Card' : 'Cash on Delivery',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedOption(String title, String selectedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14, // nhỏ hơn 16
              fontWeight: FontWeight.w500,
              color: Colors.grey, // màu nhạt
            ),
          ),
          Text(
            selectedValue.isNotEmpty ? selectedValue : 'None',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black, // bạn có thể để grey nếu muốn cả 2 nhạt
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    int totalItems,
    double totalPrice,
    double discount,
    double finalTotal,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total items: $totalItems'),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount'),
              Text(
                '-\$${discount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping Fee'),
              Text(
                '+\$${_shippingFee.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${finalTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(List selectedItems, double finalTotalPrice) {
    final hasSelectedItems = selectedItems.isNotEmpty;
    final buttonText =
        hasSelectedItems
            ? 'Select payment method'
            : 'Please select product(s) to continue';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: ElevatedButton(
        onPressed:
            hasSelectedItems
                ? () async {
                  final orderProvider = Provider.of<OrderProvider>(
                    context,
                    listen: false,
                  );

                  orderProvider.addOrder(
                    Order(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      productName: selectedItems
                          .map((e) => e.product.name)
                          .join(", "),
                      price: finalTotalPrice,
                      quantity: selectedItems
                          .map((item) => item.quantity)
                          .cast<int>()
                          .fold<int>(0, (sum, qty) => (sum + qty).toInt()),
                      status: "pending",
                    ),
                  );

                  if (!mounted) return;

                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (dialogContext) => AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Đặt hàng thành công!'),
                          actions: [
                            TextButton(
                              onPressed:
                                  () => Navigator.of(dialogContext).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );

                  if (!mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderTabsScreen(),
                    ),
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasSelectedItems ? Colors.green : Colors.grey.shade300,
          foregroundColor: hasSelectedItems ? Colors.white : Colors.black54,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(buttonText, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () => _showAddressDialog(context, cartProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Delivery to',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (cartProvider.receiverName.isNotEmpty)
                    Text(
                      '📦 ${cartProvider.receiverName} - ${cartProvider.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Text(
                      'Chưa nhập thông tin người nhận',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  if (cartProvider.city.isNotEmpty)
                    Text(
                      '${cartProvider.city}, ${cartProvider.district}, ${cartProvider.ward}',
                      style: const TextStyle(fontSize: 16),
                    )
                  else
                    const Text(
                      'Chưa chọn địa chỉ giao hàng',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  if (cartProvider.address.isNotEmpty)
                    Text(
                      cartProvider.address,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  void _showAddressDialog(BuildContext context, CartProvider cartProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddressPicker(cartProvider: cartProvider),
    );
  }
}
