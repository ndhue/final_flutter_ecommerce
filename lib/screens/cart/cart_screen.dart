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
  // Map to store inventory availability status using composite key (productId:variantId)
  Map<String, bool> _inventoryStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Schedule inventory check for after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInventory();
    });
  }

  // Generate a composite key from product ID and variant ID
  String _getInventoryKey(String productId, String variantId) {
    return "$productId:$variantId";
  }

  // Check inventory for all items in the cart
  Future<void> _checkInventory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final variantProvider = Provider.of<VariantProvider>(
      context,
      listen: false,
    );

    // Create a temporary map to store results
    Map<String, bool> tempStatus = {};

    for (final item in cartProvider.cartItems) {
      try {
        // Generate composite key for this item
        final inventoryKey = _getInventoryKey(
          item.product.id,
          item.variant.variantId,
        );

        // Fetch variant inventory information
        await variantProvider.fetchVariantByColor(
          productId: item.product.id,
          colorCode: item.variant.colorCode,
        );

        // Check if the variant exists and has enough inventory
        final variant = variantProvider.selectedVariant;
        final hasStock = variant != null && variant.inventory >= item.quantity;

        tempStatus[inventoryKey] = hasStock;

        // If the item is currently selected but out of stock, unselect it
        if (!hasStock &&
            cartProvider.isSelected(item.product.id, item.variant.variantId)) {
          cartProvider.toggleItemSelection(
            item.product.id,
            item.variant.variantId,
          );
        }
      } catch (e) {
        // If there's an error, assume item is out of stock
        final inventoryKey = _getInventoryKey(
          item.product.id,
          item.variant.variantId,
        );
        tempStatus[inventoryKey] = false;
        if (cartProvider.isSelected(item.product.id, item.variant.variantId)) {
          cartProvider.toggleItemSelection(
            item.product.id,
            item.variant.variantId,
          );
        }
      }

      // Clear selected variant to prepare for next one
      variantProvider.clearSelectedVariant();
    }

    // Only update state if the widget is still mounted
    if (mounted) {
      setState(() {
        _inventoryStatus = tempStatus;
        _isLoading = false;
      });
    }
  }

  // Check if an item has sufficient inventory
  bool _hasStock(CartItem item) {
    final inventoryKey = _getInventoryKey(
      item.product.id,
      item.variant.variantId,
    );
    return _inventoryStatus[inventoryKey] ?? false;
  }

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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      buildDeliveryInfo(cartProvider, context),
                      Expanded(
                        child: _buildCartList(context, cartItems, constraints),
                      ),
                      _buildBottomBar(context, cartProvider.totalAmount),
                    ],
                  );
                },
              ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    List<CartItem> items,
    BoxConstraints constraints,
  ) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isWeb = constraints.maxWidth > 768;

    // Count in-stock items (using the composite keys)
    final inStockCount = items.where((item) => _hasStock(item)).length;
    final selectedCount =
        items
            .where(
              (item) => cartProvider.isSelected(
                item.product.id,
                item.variant.variantId,
              ),
            )
            .length;

    if (items.isEmpty) {
      return const Center(child: Text('Your cart is empty'));
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 32.0 : 16.0),
          child: Row(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selectedCount == inStockCount && inStockCount > 0,
                    onChanged: (value) {
                      if (value == true) {
                        // Select only in-stock items
                        for (var item in items) {
                          if (_hasStock(item) &&
                              !cartProvider.isSelected(
                                item.product.id,
                                item.variant.variantId,
                              )) {
                            cartProvider.toggleItemSelection(
                              item.product.id,
                              item.variant.variantId,
                            );
                          }
                        }
                      } else {
                        cartProvider.toggleSelectAll(false);
                      }
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
          child:
              isWeb
                  ? _buildWebCartList(context, items)
                  : ListView.builder(
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

  Widget _buildWebCartList(BuildContext context, List<CartItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Product',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Unit Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Quantity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            ...items.map((item) => _buildWebCartItem(context, item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebCartItem(BuildContext context, CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context);
    final hasStock = _hasStock(item);
    final itemTotal =
        item.product.price * (1 - item.product.discount) * item.quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: hasStock ? Colors.white : Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: cartProvider.isSelected(
              item.product.id,
              item.variant.variantId,
            ),
            onChanged:
                hasStock
                    ? (_) {
                      cartProvider.toggleItemSelection(
                        item.product.id,
                        item.variant.variantId,
                      );
                    }
                    : null, // Disable checkbox if out of stock
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProductDetails(productId: item.product.id),
                    ),
                  ).then((_) {
                    // Refresh inventory status after returning from product details
                    if (mounted) {
                      _checkInventory();
                    }
                  }),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (!hasStock)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: const Center(
                            child: Text(
                              'OUT OF STOCK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: hasStock ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                            if (!hasStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Variant: ${item.variant.colorName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: hasStock ? darkTextColor : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                FormatHelper.formatCurrency(
                  item.product.price * (1 - item.product.discount),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: hasStock ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed:
                      hasStock && item.quantity > 1
                          ? () {
                            cartProvider.updateItemQuantity(
                              item.product.id,
                              item.variant.variantId,
                              item.quantity - 1,
                            );
                            _checkInventory(); // Recheck inventory after quantity change
                          }
                          : null,
                  icon: Icon(
                    Icons.remove_circle_outline,
                    size: 24,
                    color: hasStock ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontSize: 16,
                    color: hasStock ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed:
                      hasStock
                          ? () {
                            cartProvider.updateItemQuantity(
                              item.product.id,
                              item.variant.variantId,
                              item.quantity + 1,
                            );
                            _checkInventory(); // Recheck inventory after quantity change
                          }
                          : null,
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 24,
                    color: hasStock ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                FormatHelper.formatCurrency(itemTotal),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasStock ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              cartProvider.removeItem(item.product.id, item.variant.variantId);
              // Delay the inventory check slightly to ensure the cart updates first
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _checkInventory();
                }
              });
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context);
    final hasStock = _hasStock(item);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: hasStock ? Colors.white : Colors.grey.shade100,
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
          Checkbox(
            value: cartProvider.isSelected(
              item.product.id,
              item.variant.variantId,
            ),
            onChanged:
                hasStock
                    ? (_) {
                      cartProvider.toggleItemSelection(
                        item.product.id,
                        item.variant.variantId,
                      );
                    }
                    : null, // Disable checkbox if out of stock
            activeColor: hasStock ? primaryColor : Colors.grey,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProductDetails(productId: item.product.id),
                ),
              ).then((_) {
                // Refresh inventory status after returning from product details
                if (mounted) {
                  _checkInventory();
                }
              });
            },
            child: Stack(
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
                if (!hasStock)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withAlpha(5),
                    ),
                    child: const Center(
                      child: Text(
                        'OUT OF\nSTOCK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
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
                ).then((_) {
                  // Refresh inventory status after returning from product details
                  if (mounted) {
                    _checkInventory();
                  }
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: hasStock ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      if (!hasStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    'Variant: ${item.variant.colorName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasStock ? darkTextColor : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatHelper.formatCurrency(
                      item.product.price * (1 - item.product.discount),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: hasStock ? Colors.black : Colors.grey,
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
                onPressed:
                    hasStock && item.quantity > 1
                        ? () {
                          cartProvider.updateItemQuantity(
                            item.product.id,
                            item.variant.variantId,
                            item.quantity - 1,
                          );
                          _checkInventory(); // Recheck inventory after changing quantity
                        }
                        : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: hasStock ? iconColor : Colors.grey,
                  size: 20,
                ),
              ),
              Text(
                '${item.quantity}',
                style: TextStyle(color: hasStock ? darkTextColor : Colors.grey),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed:
                    hasStock
                        ? () {
                          cartProvider.updateItemQuantity(
                            item.product.id,
                            item.variant.variantId,
                            item.quantity + 1,
                          );
                          _checkInventory(); // Recheck inventory after changing quantity
                        }
                        : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: hasStock ? iconColor : Colors.grey,
                  size: 20,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  cartProvider.removeItem(
                    item.product.id,
                    item.variant.variantId,
                  );
                  // Delay the inventory check slightly to ensure the cart updates first
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      _checkInventory();
                    }
                  });
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
    final couponProvider = Provider.of<CouponProvider>(context);

    // Only allow checkout with items that have sufficient inventory
    final selectedItems =
        cartProvider.cartItems
            .where(
              (item) => cartProvider.isSelected(
                item.product.id,
                item.variant.variantId,
              ),
            )
            .toList();

    final hasSelectedItems =
        selectedItems.isNotEmpty &&
        selectedItems.every((item) => _hasStock(item));

    // Kiểm tra nếu có mã giảm giá đã áp dụng
    double discount = 0.0;
    if (couponProvider.appliedCoupon != null) {
      final appliedCoupon = couponProvider.appliedCoupon!;
      if (appliedCoupon.type == CouponType.percent) {
        // Nếu là mã giảm giá theo phần trăm
        discount =
            totalPrice *
            (appliedCoupon.value / 100); // Tính giảm giá theo phần trăm
      } else {
        // Nếu là mã giảm giá theo giá trị cố định
        discount = appliedCoupon.value;
      }
    }

    // Tính tổng giá trị sau giảm giá
    double totalWithDiscount = totalPrice - discount;

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
                FormatHelper.formatCurrency(
                  totalWithDiscount,
                ), // Hiển thị tổng sau khi giảm giá
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nếu có mã giảm giá, hiển thị thông tin giảm giá
          if (discount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discount',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '-${FormatHelper.formatCurrency(discount)}', // Hiển thị giá trị giảm giá
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red, // Màu đỏ cho giá trị giảm giá
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
                        // Save cart before navigating to ensure changes persist
                        cartProvider.saveCart();
                        Navigator.pushNamed(context, paymentScreenRoute);
                      }
                      : null,
              child: Text(
                hasSelectedItems
                    ? 'Continue to payment'
                    : 'Select items to continue',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
