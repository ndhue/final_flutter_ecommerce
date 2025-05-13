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
      Navigator.pushNamed(context, chatScreenRoute, arguments: {"userId": uid});
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: isLargeScreen,
          title: Text("Helps & Support", style: TextStyle(color: Colors.black)),
          leading: BackButton(
            style: ButtonStyle(iconSize: WidgetStateProperty.all(20)),
          ),
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? 800 : double.infinity,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor, width: 0.5)),
              ),
              child: ListView(
                padding: EdgeInsets.all(
                  isLargeScreen ? defaultPadding * 1.5 : defaultPadding,
                ),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: isLargeScreen ? 400 : double.infinity,
                        height: isLargeScreen ? 300 : 240,
                        child: Image.asset(
                          'assets/images/helps-support.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 20 : 10),
                      ListTile(
                        title: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Hey👋 We're here to help!",
                            style: TextStyle(
                              fontSize: isLargeScreen ? 32 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        subtitle: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 40 : 10,
                              vertical: 16,
                            ),
                            child: Text(
                              "Got any questions about our services or your orders? We are here to help you. We will get back to you as soon as possible.",
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16 : 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 20 : 10),
                      Container(
                        width: isLargeScreen ? 600 : double.infinity,
                        child: Column(
                          children: [
                            _buildText(
                              "Call us",
                              "+84 - 921212939",
                              icon: Icons.phone,
                              iconColor: Colors.orange,
                              onTap: () => _makePhoneCall("+1-555-010-999"),
                              isLargeScreen: isLargeScreen,
                            ),
                            _buildText(
                              "Mail us",
                              "support@help.com",
                              icon: Icons.mail,
                              iconColor: Colors.blueAccent,
                              onTap: () => _sendEmail("support@help.com"),
                              isLargeScreen: isLargeScreen,
                            ),
                            _buildText(
                              "Live Chat",
                              "Start Live Chat with us",
                              icon: Icons.chat_bubble,
                              iconColor: Colors.greenAccent,
                              onTap: () => navigateToChat(context),
                              isLargeScreen: isLargeScreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
    bool isLargeScreen = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLargeScreen ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Card(
          elevation: isLargeScreen ? 2 : 1,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 16 : 12,
                horizontal: isLargeScreen ? 24 : 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor?.withOpacity(0.2),
                    ),
                    padding: EdgeInsets.all(isLargeScreen ? 10 : 8),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: isLargeScreen ? 24 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: isLargeScreen ? 16 : 10),
      ],
    );
  }
}
