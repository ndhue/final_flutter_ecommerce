import 'package:flutter/material.dart';
import 'package:final_ecommerce/utils/constants.dart';

class ShippingAddress extends StatefulWidget {
  ShippingAddress({super.key});

  @override
  _ShippingAddressState createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  String? selectedCity;
  String? selectedProvince;
  final String phone = '+ 84';

  List<String> cities = ['TP. Hồ Chí Minh', 'Đà Nẵng'];
  List<String> provinces = [
    'Quận 1',
    'Quận 2',
    'Quận 3',
    'Quận 4',
    'Quận 5',
    'Quận 6',
    'Quận 7',
    'Quận 8',
    'Quận 9',
    'Quận 10',
    'Quận 11',
    'Quận 12',
    'Quận Bình Tân',
    'Quận Bình Thạnh',
    'Quận Gò Vấp',
    'Quận Phú Nhuận',
    'Quận Tân Bình',
    'Quận Tân Phú',
    'Quận Thủ Đức',
    'Huyện Bình Chánh',
    'Huyện Cần Giờ',
    'Huyện Củ Chi',
    'Huyện Hóc Môn',
    'Huyện Nhà Bè',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Shipping Address", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                _buildTextField("Full name", "Enter your full name"),
                _buildTextField("Phone number", phone, icon: Icons.phone),
                _buildDropdownField("City", selectedCity, cities, (newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                }),
                _buildDropdownField("Province", selectedProvince, provinces, (
                  newValue,
                ) {
                  setState(() {
                    selectedProvince = newValue;
                  });
                }),
                _buildTextField(
                  "Address",
                  "Enter your address",
                  icon: Icons.location_on,
                ),
                _buildTextField("Postal code", "Enter your postal code"),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 23, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryColor, // Set the width to double.infinity and height to 50
                      minimumSize: Size(
                        double.infinity,
                        25,
                      ), // Set the width to double.infinity and height to 25
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedValue,
          hint: Text("Select $label"),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
