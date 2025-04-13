import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartButton extends StatefulWidget {
  const CartButton({super.key});

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  @override
  void initState() {
    super.initState();

    final currentUser = context.read<UserProvider>().user;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      if (currentUser != null) {
        cartProvider.setUser(currentUser.id);
        cartProvider.loadUserAddress(currentUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          child: IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black87,
              size: 28,
            ),
            onPressed: () {
              Navigator.pushNamed(context, cartScreenRoute);
            },
          ),
        ),
        Positioned(
          right: 6,
          top: 4,
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final uniqueItemCount =
                  cartProvider
                      .cartItems
                      .length; // Đếm số loại sản phẩm duy nhất

              return uniqueItemCount > 0
                  ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      uniqueItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : const SizedBox(); // Ẩn nếu giỏ hàng rỗng
            },
          ),
        ),
      ],
    );
  }
}
