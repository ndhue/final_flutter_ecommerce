import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:flutter/material.dart';

import '../../../widgets/address_picker.dart';

Widget buildDeliveryInfo(CartProvider cartProvider, BuildContext context) {
  AddressInfo? addressInfo = cartProvider.addressInfo;
  String addressText = addressInfo?.fullShippingAddress ?? 'Select Address';

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        const Text('Delivery to', style: TextStyle(fontSize: 16)),
        Flexible(
          child: TextButton.icon(
            onPressed: () => _showAddressDialog(context, cartProvider),
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

void _showAddressDialog(BuildContext context, CartProvider cartProvider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddressPicker(cartProvider: cartProvider),
  );
}
