import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class HelpsSupport extends StatefulWidget {
  HelpsSupport({super.key});

  @override
  _HelpsSupport createState() => _HelpsSupport();
}

class _HelpsSupport extends State<HelpsSupport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Helps & Support", style: TextStyle(color: Colors.black)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'images/helps-support.png',
               width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text("Contact Us. We are here to help you.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Align(
                  alignment: Alignment.center,
                  child: Text(
                  "Got any questions about our services or your orders? We are here to help you.  We will get back to you as soon as possible.",
                    style: TextStyle(fontSize: 14, color: Colors.grey, )),
                ),
              ),
              SizedBox(height: 20),
              _buildText("Call us", "+84 132456598", icon: Icons.phone),
              _buildText("Mail us", "abcxy@gmail.com", icon: Icons.mail),
              _buildText("Visit us", "123 Street, City, Country", icon: Icons.location_on),
             // _buildText("Live chat", 'Start live chat with us', icon: Icons.chat_bubble),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildText(String label, String subtitle, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Card(
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            trailing: Icon(icon, color: iconColor),
            subtitle: Text(subtitle),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
