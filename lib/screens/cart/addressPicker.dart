import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class AddressPicker extends StatefulWidget {
  @override
  _AddressPickerState createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  String selectedCity = "Hồ Chí Minh";
  String selectedDistrict = "Quận 1";
  final TextEditingController addressController = TextEditingController();

  final List<String> cities = ["Hồ Chí Minh", "Hà Nội", "Đà Nẵng"];
  final Map<String, List<String>> districts = {
    "Hồ Chí Minh": ["Quận 1", "Quận 2", "Quận 3"],
    "Hà Nội": ["Ba Đình", "Hoàn Kiếm", "Hai Bà Trưng"],
    "Đà Nẵng": ["Hải Châu", "Thanh Khê", "Ngũ Hành Sơn"],
  };

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Chọn tỉnh/thành phố
            DropdownButton<String>(
              value: selectedCity,
              onChanged: (newValue) {
                setState(() {
                  selectedCity = newValue!;
                  selectedDistrict = districts[selectedCity]!.first;
                });
              },
              items:
                  cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
            ),

            // Chọn quận/huyện
            DropdownButton<String>(
              value: selectedDistrict,
              onChanged: (newValue) {
                setState(() {
                  selectedDistrict = newValue!;
                });
              },
              items:
                  districts[selectedCity]!.map((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
            ),

            // Nhập địa chỉ cụ thể
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Detailed Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Nút Lưu
            ElevatedButton(
              onPressed: () {
                cartProvider.updateAddress(
                  selectedCity,
                  selectedDistrict,
                  addressController.text,
                );
                Navigator.pop(context);
              },
              child: const Text("Save Address"),
            ),
          ],
        ),
      ),
    );
  }
}
