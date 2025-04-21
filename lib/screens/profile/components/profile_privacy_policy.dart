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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Privacy and Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/pravicy_policy.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              _buildText(
                'Warranty & Return Policy',
                subtitle:
                    'Returns are accepted within 7 days if the product is defective, damaged, or not as described.\n'
                    'Not applicable to products without a return policy (e.g., opened food or cosmetics).',
                icon: Icons.assignment_return,
              ),
              _buildText(
                'Privacy Policy & Data Protection',
                subtitle:
                    'We are committed to protecting your personal data. We guarantee that your personal information will not be shared with any third party. \n'
                    'Both buyers and sellers must comply with our security regulations to minimize fraud cases.\n'
                    'Users are advised to enable two-factor authentication for optimal security protection.',
                icon: Icons.privacy_tip,
              ),
              _buildText(
                'Terms & Services',
                subtitle:
                    'Please read the terms carefully before using our services. \n'
                    'In case of system errors, we will make every effort to fix them as soon as possible.\n'
                    'If you have any further questions about the system, please contact us directly through Help & Support.',
                icon: Icons.description,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildText(String label, {String? subtitle, IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10), // Thêm padding cho đẹp
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null && subtitle.isNotEmpty) const SizedBox(height: 8),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            trailing: icon != null ? Icon(icon, color: Colors.blue) : null,
            subtitle: Text(subtitle ?? '', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    ),
  );
}
