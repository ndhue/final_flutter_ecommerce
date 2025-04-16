import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

class AddressPickerRegistration extends StatefulWidget {
  final void Function(
    String city,
    String district,
    String ward,
    String detailedAddress,
  )
  onAddressSelected;

  final AddressInfo? defaultAddress;

  const AddressPickerRegistration({
    super.key,
    required this.onAddressSelected,
    this.defaultAddress,
  });

  @override
  State<AddressPickerRegistration> createState() =>
      _AddressPickerRegistrationState();
}

class _AddressPickerRegistrationState extends State<AddressPickerRegistration> {
  late String selectedCity;
  late String selectedDistrict;
  late String selectedWard;
  late TextEditingController detailedAddressController;

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
    selectedCity = widget.defaultAddress?.city ?? "";
    selectedDistrict = widget.defaultAddress?.district ?? "";
    selectedWard = widget.defaultAddress?.ward ?? "";
    detailedAddressController = TextEditingController(
      text: widget.defaultAddress?.detailedAddress ?? "",
    );
  }

  @override
  void dispose() {
    detailedAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              DropdownButton<String>(
                value: selectedCity.isNotEmpty ? selectedCity : null,
                hint: const Text("Select City"),
                onChanged: (newValue) {
                  setState(() {
                    selectedCity = newValue!;
                    selectedDistrict = "";
                    selectedWard = "";
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

              DropdownButton<String>(
                value: selectedDistrict.isNotEmpty ? selectedDistrict : null,
                hint: const Text("Select District"),
                onChanged: (newValue) {
                  setState(() {
                    selectedDistrict = newValue!;
                    selectedWard = "";
                  });
                },
                items:
                    selectedCity.isNotEmpty
                        ? districts[selectedCity]!
                            .map(
                              (district) => DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              ),
                            )
                            .toList()
                        : [],
              ),

              DropdownButton<String>(
                value: selectedWard.isNotEmpty ? selectedWard : null,
                hint: const Text("Select Ward"),
                onChanged: (newValue) {
                  setState(() {
                    selectedWard = newValue!;
                  });
                },
                items:
                    selectedDistrict.isNotEmpty
                        ? wards[selectedDistrict]!
                            .map(
                              (ward) => DropdownMenuItem(
                                value: ward,
                                child: Text(ward),
                              ),
                            )
                            .toList()
                        : [],
              ),

              const SizedBox(height: 12),

              TextField(
                controller: detailedAddressController,
                decoration: const InputDecoration(
                  labelText: "Detailed Address",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAddressSelected(
                      selectedCity,
                      selectedDistrict,
                      selectedWard,
                      detailedAddressController.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Save Address"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
