import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:flutter/material.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

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
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Text(
              "2",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
