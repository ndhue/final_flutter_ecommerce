import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class PravicyAndPolicy extends StatefulWidget {
  const PravicyAndPolicy({super.key});

  @override
  State<PravicyAndPolicy> createState() => _PravicyAndPolicyState();
}

class _PravicyAndPolicyState extends State<PravicyAndPolicy> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: isLargeScreen,
        title: const Text('Privacy and Policy'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 800 : double.infinity,
          ),
          child: ListView(
            padding: EdgeInsets.all(
              isLargeScreen ? defaultPadding * 1.5 : defaultPadding,
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/pravicy_policy.jpg',
                      width: isLargeScreen ? 400 : double.infinity,
                      height: isLargeScreen ? 250 : 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 32 : 20),
                  _buildText(
                    'Warranty & Return Policy',
                    subtitle:
                        'Returns are accepted within 7 days if the product is defective, damaged, or not as described.\n'
                        'Not applicable to products without a return policy (e.g., opened food or cosmetics).',
                    icon: Icons.assignment_return,
                    isLargeScreen: isLargeScreen,
                  ),
                  _buildText(
                    'Privacy Policy & Data Protection',
                    subtitle:
                        'We are committed to protecting your personal data. We guarantee that your personal information will not be shared with any third party. \n'
                        'Both buyers and sellers must comply with our security regulations to minimize fraud cases.\n'
                        'Users are advised to enable two-factor authentication for optimal security protection.',
                    icon: Icons.privacy_tip,
                    isLargeScreen: isLargeScreen,
                  ),
                  _buildText(
                    'Terms & Services',
                    subtitle:
                        'Please read the terms carefully before using our services. \n'
                        'In case of system errors, we will make every effort to fix them as soon as possible.\n'
                        'If you have any further questions about the system, please contact us directly through Help & Support.',
                    icon: Icons.description,
                    isLargeScreen: isLargeScreen,
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
    String label, {
    String? subtitle,
    IconData? icon,
    bool isLargeScreen = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLargeScreen ? 24 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty)
            SizedBox(height: isLargeScreen ? 12 : 8),
          Card(
            elevation: isLargeScreen ? 2 : 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      subtitle ?? '',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 16 : 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  icon != null
                      ? Icon(
                        icon,
                        color: Colors.blue,
                        size: isLargeScreen ? 28 : 24,
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
