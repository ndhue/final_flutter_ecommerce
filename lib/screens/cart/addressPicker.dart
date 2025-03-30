import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';

class AddressPicker extends StatefulWidget {
  final CartProvider cartProvider;

  const AddressPicker({super.key, required this.cartProvider});

  @override
  _AddressPickerState createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  String selectedCity = "Hồ Chí Minh";
  String selectedDistrict = "Quận 1";
  String selectedWard = "Phường Bến Nghé";

  final TextEditingController addressController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<String> cities = ["Hồ Chí Minh", "Hà Nội", "Đà Nẵng"];
  final Map<String, List<String>> districts = {
    "Hồ Chí Minh": ["Quận 1", "Quận 2", "Quận 3"],
    "Hà Nội": ["Ba Đình", "Hoàn Kiếm", "Hai Bà Trưng"],
    "Đà Nẵng": ["Hải Châu", "Thanh Khê", "Ngũ Hành Sơn"],
  };

  final Map<String, List<String>> wards = {
    "Quận 1": ["Phường Bến Nghé", "Phường Đa Kao", "Phường Nguyễn Cư Trinh"],
    "Quận 2": ["Phường An Phú", "Phường Thảo Điền", "Phường Bình Khánh"],
    "Ba Đình": ["Phường Điện Biên", "Phường Ngọc Hà", "Phường Thành Công"],
    "Hải Châu": ["Phường Bình Thuận", "Phường Hải Châu 1", "Phường Hải Châu 2"],
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            /// **Chọn thành phố**
            DropdownButton<String>(
              value: selectedCity,
              onChanged: (newValue) {
                setState(() {
                  selectedCity = newValue!;
                  selectedDistrict = districts[selectedCity]!.first;
                  selectedWard = wards[selectedDistrict]!.first;
                });
              },
              items:
                  cities
                      .map(
                        (city) =>
                            DropdownMenuItem(value: city, child: Text(city)),
                      )
                      .toList(),
            ),

            /// **Chọn quận/huyện**
            DropdownButton<String>(
              value: selectedDistrict,
              onChanged: (newValue) {
                setState(() {
                  selectedDistrict = newValue!;
                  selectedWard = wards[selectedDistrict]!.first;
                });
              },
              items:
                  districts[selectedCity]!
                      .map(
                        (district) => DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        ),
                      )
                      .toList(),
            ),

            /// **Chọn phường/xã**
            DropdownButton<String>(
              value: selectedWard,
              onChanged: (newValue) {
                setState(() {
                  selectedWard = newValue!;
                });
              },
              items:
                  wards[selectedDistrict]!
                      .map(
                        (ward) =>
                            DropdownMenuItem(value: ward, child: Text(ward)),
                      )
                      .toList(),
            ),

            /// **Nhập địa chỉ cụ thể**
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Detailed Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            /// **Nhập tên người nhận**
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Receiver Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            /// **Nhập số điện thoại**
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// **Nút lưu địa chỉ**
            ElevatedButton(
              onPressed: () {
                widget.cartProvider.updateAddress(
                  selectedCity,
                  selectedDistrict,
                  selectedWard,
                  addressController.text,
                  nameController.text,
                  phoneController.text,
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
