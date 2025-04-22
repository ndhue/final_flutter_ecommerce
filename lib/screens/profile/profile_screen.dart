import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/services/auth_service.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/dialog.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:final_ecommerce/utils/utils.dart';
import 'package:final_ecommerce/widgets/address_picker_registration.dart';
import 'package:final_ecommerce/widgets/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'components/change_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditingName = false;
  late TextEditingController _nameController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      _nameController = TextEditingController(
        text: userProvider.user?.fullName ?? '',
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder:
            (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Take a photo'),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Choose from gallery'),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                ],
              ),
            ),
      );

      if (source == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (pickedFile != null) {
        final userProvider = context.read<UserProvider>();
        final success = await userProvider.updateAvatar(pickedFile);

        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to update avatar. Please try again."),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    }
  }

  Widget _buildAvatarSection(UserModel user, bool isAvatarLoading) {
    return GestureDetector(
      onTap: isAvatarLoading ? null : _pickAndUploadImage,
      child: Stack(
        children: [
          isAvatarLoading
              ? AvatarSkeletonLoader(radius: 30)
              : CircleAvatar(
                backgroundImage:
                    user.avatar != null
                        ? NetworkImage(user.avatar!)
                        : AssetImage('assets/images/avatar-1.jpg')
                            as ImageProvider,
                radius: 30,
              ),
          if (!isAvatarLoading) // Only show camera icon when not loading
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, size: 14, color: primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final isAvatarLoading = userProvider.isAvatarLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body:
          userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("User data not found. Please log in again."),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => handleLogout(context),
                      icon: Icon(Icons.refresh),
                      label: Text("Back to Login"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Card(
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: ListTile(
                      leading: _buildAvatarSection(user, isAvatarLoading),
                      title:
                          _isEditingName
                              ? TextField(
                                controller: _nameController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: "Enter your name",
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : Text(
                                user.fullName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      subtitle: Text(user.email),
                      trailing: IconButton(
                        icon: Icon(
                          _isEditingName ? Icons.check : Icons.edit,
                          color: iconColor,
                        ),
                        onPressed: () {
                          if (_isEditingName) {
                            userProvider.updateFullName(_nameController.text);
                          }
                          setState(() {
                            _isEditingName = !_isEditingName;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSectionTitle("Loyalty Points"),
                  _buildLoyaltyPointItem(user.loyaltyPoints),
                  _buildSectionTitle("Personal Information"),
                  _buildMenuItemCustom(
                    Icons.local_shipping,
                    "Shipping Address",
                    () {
                      _showAddressPicker(context);
                    },
                  ),
                  _buildMenuItem(
                    Icons.payment,
                    "Payment Method",
                    context,
                    null,
                  ),
                  SizedBox(height: 20),
                  _buildSectionTitle("Support & Information"),
                  _buildMenuItem(
                    Icons.security,
                    "Privacy Policy ",
                    context,
                    pravicyAndPolicyScreenRoute,
                  ),
                  _buildMenuItem(
                    Icons.help,
                    "Helps and support",
                    context,
                    helpsAndSupportScreenRoute,
                  ),
                  _buildMenuItem(
                    Icons.question_answer,
                    "FAQs",
                    context,
                    faqsScreenRoute,
                  ),
                  SizedBox(height: 20),
                  _buildSectionTitle("Account Management"),
                  _buildMenuItemCustom(Icons.lock, "Change Password", () {
                    _showChangePasswordDialog(context);
                  }),
                  _buildMenuItemCustom(Icons.logout, "Logout", () {
                    AppDialogs.showCustomDialog(
                      context: context,
                      title: "Log out",
                      content: "Are you sure you want to logout?",
                      confirmText: "Log out",
                      onConfirm: () => handleLogout(context),
                      cancelText: "Cancel",
                      icon: Icons.exit_to_app,
                      confirmColor: Colors.red,
                    );
                  }),
                ],
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    BuildContext context,
    String? destination,
  ) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
        onTap: () {
          destination != null
              ? Navigator.pushNamed(context, destination)
              : null;
        },
      ),
    );
  }

  Widget _buildMenuItemCustom(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLoyaltyPointItem(int vndAmount) {
    final points = convertVndToPoints(vndAmount);

    return Card(
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.stars, color: Colors.amber),
            title: Text('Loyalty Points'),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${convertNum(points)} points',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => _buildLoyaltyInfoDialog(vndAmount, points),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Value: ${FormatHelper.formatCurrency(vndAmount)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                Text(
                  'Earn 10% on purchases',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyInfoDialog(int vndAmount, int points) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.stars, color: Colors.amber),
          SizedBox(width: 10),
          Text('Loyalty Program'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            '• You earn 1 point for every 10,000 VND spent',
            style: const TextStyle(),
          ),
          SizedBox(height: 4),
          Text('• Example: 1,000,000 VND spent = 100 points'),
          SizedBox(height: 4),
          Text('• Points can be redeemed for discounts on future purchases'),
          SizedBox(height: 16),
          Text(
            'Your current balance:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '${FormatHelper.formatCurrency(vndAmount)} spent = ${formatNumber(points)} points',
            style: TextStyle(color: Colors.amber[800]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ChangePasswordDialog(),
    );
  }

  void _showAddressPicker(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => AddressPickerRegistration(
            onAddressSelected: (city, district, ward, detailedAddress) {
              userProvider.updateAddress(
                city: city,
                district: district,
                ward: ward,
                shippingAddress: detailedAddress,
              );
            },
            defaultAddress:
                userProvider.user?.fullShippingAddress != null
                    ? AddressInfo(
                      city: userProvider.user!.city,
                      district: userProvider.user!.district,
                      ward: userProvider.user!.ward,
                      detailedAddress: userProvider.user!.shippingAddress,
                      receiverName: userProvider.user!.fullName,
                    )
                    : null,
          ),
    );
  }
}
