import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/address_picker.dart';

Widget buildDeliveryInfo(CartProvider cartProvider, BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  AddressInfo? addressInfo = cartProvider.addressInfo;
  String addressText = addressInfo?.fullShippingAddress ?? 'Select Address';

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        const Text('Delivery to', style: TextStyle(fontSize: 16)),
        Flexible(
          child: TextButton.icon(
            onPressed:
                () => _showAddressDialog(context, cartProvider, userProvider),
            icon: const Icon(Icons.keyboard_arrow_down),
            label: Text(
              addressText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    ),
  );
}

void _showAddressDialog(
  BuildContext context,
  CartProvider cartProvider,
  UserProvider userProvider,
) {
  if (userProvider.user == null) {
    // Show login prompt if user is not logged in
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Address Selection'),
            content: const Text(
              'You need to provide delivery information to continue. This will be used for your order.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder:
                        (context) => AddressPicker(
                          cartProvider: cartProvider,
                          isGuest: true,
                        ),
                  );
                },
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
    );
  } else {
    // If logged in, show normal address picker
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddressPicker(cartProvider: cartProvider),
    );
  }
}
