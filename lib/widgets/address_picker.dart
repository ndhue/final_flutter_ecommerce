import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:flutter/material.dart';

class AddressPicker extends StatefulWidget {
  final CartProvider cartProvider;
  final bool isGuest;

  const AddressPicker({
    super.key,
    required this.cartProvider,
    this.isGuest = false,
  });

  @override
  State<AddressPicker> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  late String selectedCity;
  late String selectedDistrict;
  late String selectedWard;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPasswordField = false;

  final List<String> cities = ["Hồ Chí Minh", "Hà Nội", "Đà Nẵng"];
  final Map<String, List<String>> districts = {
    "Hồ Chí Minh": ["Quận 1", "Quận 2", "Quận 3"],
    "Hà Nội": ["Ba Đình", "Hoàn Kiếm", "Hai Bà Trưng"],
    "Đà Nẵng": ["Hải Châu", "Thanh Khê", "Ngũ Hành Sơn"],
  };
  final Map<String, List<String>> wards = {
    "Quận 1": ["Phường Bến Nghé", "Phường Đa Kao", "Phường Nguyễn Cư Trinh"],
    "Quận 2": ["Phường An Phú", "Phường Thảo Điền", "Phường Bình Khánh"],
    "Quận 3": ["Phường 1", "Phường 2", "Phường 3"],
    "Ba Đình": ["Phường Điện Biên", "Phường Ngọc Hà", "Phường Thành Công"],
    "Hoàn Kiếm": ["Phường Hàng Bạc", "Phường Hàng Đào"],
    "Hai Bà Trưng": ["Phường Bạch Mai", "Phường Thanh Nhàn"],
    "Hải Châu": ["Phường Bình Thuận", "Phường Hải Châu 1", "Phường Hải Châu 2"],
    "Thanh Khê": ["Phường An Khê", "Phường Thạc Gián"],
    "Ngũ Hành Sơn": ["Phường Mỹ An", "Phường Khuê Mỹ"],
  };

  @override
  void initState() {
    super.initState();

    // Nếu đã có address, load lên
    final currentAddress = widget.cartProvider.addressInfo;
    if (currentAddress != null) {
      selectedCity = currentAddress.city;
      selectedDistrict = currentAddress.district;
      selectedWard = currentAddress.ward;
      addressController.text = currentAddress.detailedAddress;
      nameController.text = currentAddress.receiverName;
    } else {
      // Nếu chưa có, dùng mặc định
      selectedCity = "Hồ Chí Minh";
      selectedDistrict = districts[selectedCity]!.first;
      selectedWard = wards[selectedDistrict]!.first;
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isGuest
                      ? "Enter Delivery Information"
                      : "Select Delivery Address",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (widget.isGuest) ...[
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email Address *",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  if (_showPasswordField)
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Create Password *",
                        border: OutlineInputBorder(),
                        helperText:
                            "You'll need this to access your orders later",
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please create a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 8),
                ],

                /// Chọn thành phố
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
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                ),

                /// Chọn quận/huyện
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

                /// Chọn phường/xã
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
                            (ward) => DropdownMenuItem(
                              value: ward,
                              child: Text(ward),
                            ),
                          )
                          .toList(),
                ),

                const SizedBox(height: 8),

                /// Nhập địa chỉ cụ thể
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: "Detailed Address",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 8),

                /// Nhập tên người nhận
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Receiver Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 8),

                /// Nút lưu địa chỉ
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.isGuest) {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (!_showPasswordField) {
                            // First step: Collect email and show password field
                            setState(() {
                              _showPasswordField = true;
                            });
                            return;
                          }
                        } else {
                          return; // Don't proceed if validation fails
                        }
                      }

                      final newAddress = AddressInfo(
                        city: selectedCity,
                        district: selectedDistrict,
                        ward: selectedWard,
                        detailedAddress: addressController.text,
                        receiverName: nameController.text,
                      );

                      widget.cartProvider.updateAddress(newAddress);

                      // If user is a guest, save additional information
                      if (widget.isGuest && emailController.text.isNotEmpty) {
                        widget.cartProvider.saveGuestCheckoutInfo({
                          'email': emailController.text,
                          'fullName': nameController.text,
                          'password':
                              passwordController
                                  .text, // Store temporarily for account creation
                          'address': {
                            'city': selectedCity,
                            'district': selectedDistrict,
                            'ward': selectedWard,
                            'detailedAddress': addressController.text,
                          },
                        });
                      }

                      Navigator.pop(context);
                    },
                    child: Text(
                      widget.isGuest
                          ? (_showPasswordField
                              ? "Save Information"
                              : "Continue")
                          : "Save Address",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
