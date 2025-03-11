import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethod();
}

class _PaymentMethod extends State<PaymentMethod> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Payment Method", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            'images/paypal.png',
                            width: 100,
                            height: 100,
                          ),
                          Image.asset(
                            'images/visa_payment.png',
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildTextField(
                        "Card Holder Name",
                        "Enter your card holder name",
                      ),
                      _buildTextField("Card Number", "Enter your card number"),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField("Expiry Date", "MM/YY"),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField("CVV", "Enter your CVV"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(
                  double.infinity,
                  25,
                ), // Set the width to double.infinity and height to 25
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Save",
                style: TextStyle(fontSize: 23, color: Colors.white),
              ),
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
}
