import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:final_ecommerce/widgets/widgets_export.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Your Cart'),
        actions: [CartButton()],
      ),
      body: Column(
        children: [
          buildDeliveryInfo(cartProvider, context),
          Expanded(child: _buildCartList(context, cartItems)),
          _buildBottomBar(context, cartProvider.totalAmount),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, List<CartItem> items) {
    final cartProvider = Provider.of<CartProvider>(context);

    if (items.isEmpty) {
      return const Center(child: Text('Your cart is empty'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: cartProvider.isAllSelected(),
                    onChanged: (value) {
                      cartProvider.toggleSelectAll(value!);
                    },
                  ),
                  const Text('Select All'),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color:
                      cartProvider.selectedItemIds.isNotEmpty
                          ? Colors.red
                          : iconColor,
                ),
                onPressed:
                    cartProvider.selectedItemIds.isNotEmpty
                        ? () {
                          if (cartProvider.isAllSelected()) {
                            cartProvider.clearCart();
                          } else {
                            cartProvider.clearSelection();
                          }
                        }
                        : null,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildCartItem(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: cartProvider.isSelected(item.product.id),
            onChanged: (_) {
              cartProvider.toggleItemSelection(item.product.id);
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProductDetails(productId: item.product.id),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductDetails(productId: item.product.id),
                  ),
                );
              },
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
                    'Variant: ${item.variant.colorName}',
                    style: const TextStyle(fontSize: 12, color: darkTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatHelper.formatCurrency(
                      item.product.price * (1 - item.product.discount),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  if (item.quantity > 1) {
                    cartProvider.updateItemQuantity(
                      item.product.id,
                      item.quantity - 1,
                    );
                  }
                },
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(color: darkTextColor),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  cartProvider.updateItemQuantity(
                    item.product.id,
                    item.quantity + 1,
                  );
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: iconColor,
                  size: 20,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  cartProvider.removeItem(item.product.id);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double totalPrice) {
    final cartProvider = Provider.of<CartProvider>(context);

    final hasSelectedItems =
        cartProvider.selectedItemIds.isNotEmpty &&
        cartProvider.cartItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Totals',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                FormatHelper.formatCurrency(totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSelectedItems ? primaryColor : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed:
                  hasSelectedItems
                      ? () {
                        Navigator.pushNamed(context, paymentScreenRoute);
                      }
                      : null, // Disable khi chưa chọn sp nào
              child: const Text(
                'Continue for payments',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
