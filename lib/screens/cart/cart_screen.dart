import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/format.dart';
import '../../widgets/buttons/cart_button.dart';
import 'payment_screen.dart';
import 'addressPicker.dart';
import '../product/product_details.dart'; // thêm dòng này để điều hướng

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: const [CartButton()],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.cartItems;
          final hasSelectedItems = cartProvider.selectedItems.isNotEmpty;

          return Column(
            children: [
              _buildAddressSection(context, cartProvider),
              Expanded(
                child:
                    cartItems.isEmpty
                        ? const Center(child: Text('Your cart is empty'))
                        : _buildCartList(context, cartProvider),
              ),
              if (hasSelectedItems) _buildOrderSummary(cartProvider),
              _buildBottomBar(context, cartProvider, hasSelectedItems),
            ],
          );
        },
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

  Widget _buildCartList(BuildContext context, CartProvider cartProvider) {
    return ListView.builder(
      itemCount: cartProvider.cartItems.length,
      itemBuilder: (context, index) {
        final item = cartProvider.cartItems[index];
        final product = item.product;
        final variant = item.variant;

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetails(product: product),
              ),
            );
          },
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: cartProvider.selectedItems.contains(item),
                onChanged:
                    (isChecked) =>
                        cartProvider.toggleSelection(product, variant),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  variant.imageUrl?.isNotEmpty == true
                      ? variant.imageUrl!
                      : (product.images.isNotEmpty ? product.images.first : ''),
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 70,
                        color: Colors.grey,
                      ),
                ),
              ),
            ],
          ),
          title: Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Variant: ${variant.name}'),
              if (variant.isColor)
                Row(
                  children: [
                    const Text(
                      'Color: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: variant.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                    ),
                  ],
                ),
              if (variant.isSize)
                Text(
                  'Size: ${variant.size}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              Text(
                'Unit Price: ${FormatHelper.formatCurrency(variant.currentPrice)}',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed:
                    () => cartProvider.decreaseQuantity(product, variant),
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                onPressed:
                    () => cartProvider.increaseQuantity(product, variant),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => cartProvider.removeFromCart(product, variant),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Totals', style: TextStyle(fontSize: 16)),
              Text(
                FormatHelper.formatCurrency(cartProvider.selectedTotalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CartProvider cartProvider,
    bool hasSelectedItems,
  ) {
    final text =
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
                ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentScreen(),
                  ),
                )
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasSelectedItems ? Colors.green : Colors.grey.shade300,
          foregroundColor: hasSelectedItems ? Colors.white : Colors.black54,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
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
