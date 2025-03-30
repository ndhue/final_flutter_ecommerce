import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../cart/addressPicker.dart';

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
  String _selectedDeliveryOption = "Express"; // Default delivery method
  String _selectedPaymentMethod = "Credit Card"; // Default payment method

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final selectedItems = cartProvider.selectedItems.toList();
    final totalPrice = cartProvider.selectedTotalPrice;
    final discountedPrice = totalPrice * (1 - _discountValue);
    final totalItems = selectedItems.length;

    // Nếu có nhiều hơn 3 sản phẩm, chỉ hiển thị 3 sản phẩm đầu tiên
    final displayedItems =
        showAllItems ? selectedItems : selectedItems.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(context, cartProvider),
            const SizedBox(height: 16),
            _buildCartItems(displayedItems), // Hiển thị các mặt hàng
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
            _buildOrderSummary(totalItems, discountedPrice),
            _buildPaymentButton(selectedItems),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(List selectedItems) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.price}₫',
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                    Text(
                      'Số lượng: ${item.quantity}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Tổng: ${item.price * item.quantity}₫',
                      style: TextStyle(
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
          // Chọn phương thức giao hàng
          ExpansionTile(
            title: Text(
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
                  });
                },
                title: Text('Express: 1-3 days delivery - \$14.99'),
              ),
              RadioListTile<String>(
                value: "Regular",
                groupValue: _selectedDeliveryOption,
                onChanged: (value) {
                  setState(() {
                    _selectedDeliveryOption = value!;
                  });
                },
                title: Text('Regular: 2-4 days delivery - \$7.99'),
              ),
              RadioListTile<String>(
                value: "Cargo",
                groupValue: _selectedDeliveryOption,
                onChanged: (value) {
                  setState(() {
                    _selectedDeliveryOption = value!;
                  });
                },
                title: Text('Cargo: 7-14 days delivery - \$2.99'),
              ),
            ],
          ),

          // Hiển thị kết quả đã chọn cho phương thức giao hàng
          _buildSelectedOption('Delivery Option', _selectedDeliveryOption),

          // Nhập mã giảm giá
          ExpansionTile(
            title: Text(
              'Apply a discount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              TextField(
                controller: _discountController,
                decoration: InputDecoration(
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
                      if (_appliedDiscountCode == "SALE10") {
                        _discountValue = 0.1; // Apply 10% discount
                      } else {
                        _discountValue = 0.0;
                      }
                    });
                  },
                  child: Text('Apply'),
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

          // Hiển thị kết quả đã chọn cho mã giảm giá
          _buildSelectedOption('Discount Code', _appliedDiscountCode),

          // Chọn phương thức thanh toán
          ExpansionTile(
            title: Text(
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
                title: Text('Credit Card'),
              ),
              RadioListTile<int>(
                value: 2,
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value!;
                  });
                },
                title: Text('Cash on Delivery'),
              ),
            ],
          ),

          // Hiển thị kết quả đã chọn cho phương thức thanh toán
          _buildSelectedOption(
            'Payment Method',
            _selectedPayment == 1 ? 'Credit Card' : 'Cash on Delivery',
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị kết quả đã chọn
  Widget _buildSelectedOption(String title, String selectedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            selectedValue.isNotEmpty ? selectedValue : 'None',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(int totalItems, double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discount'),
              Text(
                '-\$${(totalPrice * _discountValue).toStringAsFixed(2)}',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '\$${(totalPrice * (1 - _discountValue)).toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(List selectedItems) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed:
            selectedItems.isNotEmpty
                ? () {
                  print("🚚 Delivery option: $_selectedDeliveryOption");
                  print("💳 Payment method: $_selectedPayment");
                  print(
                    "🏷️ Discount applied: $_appliedDiscountCode (${_discountValue * 100}%)",
                  );
                  // Proceed to payment
                }
                : null,
        child: Text('Proceed to Payment'),
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
