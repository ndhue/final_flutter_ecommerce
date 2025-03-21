import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpsSupport extends StatefulWidget {
  const HelpsSupport({super.key});

  @override
  State<HelpsSupport> createState() => _HelpsSupport();
}

class _HelpsSupport extends State<HelpsSupport> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> navigateToChat(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid != null && context.mounted) {
      Navigator.pushNamed(
        context,
        chatScreenRoute,
        arguments: {"userId": uid, "isAdmin": false},
      );
    } else {
      _showSnackBar("Please log in to chat");
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    try {
      debugPrint(url.toString());
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        _showSnackBar("Could not launch phone call");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Customer Support Request',
        'body': 'Hello, I need help with...',
      }),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showSnackBar("An error occurred");
    }
  }

  // Helper function for query parameters
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Helps & Support", style: TextStyle(color: Colors.black)),
          leading: BackButton(
            style: ButtonStyle(iconSize: WidgetStateProperty.all(20)),
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: ListView(
            padding: EdgeInsets.all(defaultPadding),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width > 600
                            ? 600
                            : double.infinity,
                    height: 240,
                    child: Image.asset(
                      'assets/images/helps-support.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  ListTile(
                    title: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Hey👋 We’re here to help!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    subtitle: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Got any questions about our services or your orders? We are here to help you. We will get back to you as soon as possible.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  _buildText(
                    "Call us",
                    "+84 - 921212939",
                    icon: Icons.phone,
                    iconColor: Colors.orange,
                    onTap: () => _makePhoneCall("+1-555-010-999"),
                  ),
                  _buildText(
                    "Mail us",
                    "support@help.com",
                    icon: Icons.mail,
                    iconColor: Colors.blueAccent,
                    onTap: () => _sendEmail("support@help.com"),
                  ),
                  _buildText(
                    "Live Chat",
                    "Start Live Chat with us",
                    icon: Icons.chat_bubble,
                    iconColor: Colors.greenAccent,
                    onTap: () => navigateToChat(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(
    String label,
    String subtitle, {
    IconData? icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Card(
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(subtitle),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor?.withOpacity(0.2),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
