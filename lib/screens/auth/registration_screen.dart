import 'package:final_ecommerce/providers/auth_provider.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/widgets/address_picker_registration.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => AddressPickerRegistration(
            onAddressSelected: (city, district, ward, detailedAddress) {
              setState(() {
                selectedCity = city;
                selectedDistrict = district;
                selectedWard = ward;
                _addressController.text =
                    '$detailedAddress, $ward, $district, $city';
              });
            },
          ),
    );
  }

  Future<void> handleSignUp() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();

    String email = _emailController.text.trim();
    String password = _passController.text.trim();
    String fullName = _fullNameController.text.trim();
    String shippingAddress = _addressController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        shippingAddress.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      setState(() => _isLoading = false);

      return;
    }

    bool isSuccess = await authProvider.signUp(
      email,
      password,
      fullName,
      shippingAddress,
      selectedWard ?? '',
      selectedDistrict ?? '',
      selectedCity ?? '',
    );
    setState(() => _isLoading = false);

    if (isSuccess) {
      Fluttertoast.showToast(msg: "Sign up successful!");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EntryPoint()),
        );
      }
    } else {
      Fluttertoast.showToast(msg: "Sign up failed. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;

          return Center(
            child:
                isWideScreen
                    ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          // Image Section (Only on large screens)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(32.0),
                              color: Colors.white,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Image.asset(
                                        "assets/images/vector-2.png",
                                        fit: BoxFit.contain,
                                        height: constraints.maxHeight * 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      "Join Naturify Today",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      "Create your account to start shopping",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Form Section with visual separation
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(-5, 0),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 450,
                                  ),
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: _buildForm(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Image.asset(
                            "assets/images/vector-2.png",
                            width: constraints.maxWidth * 0.7,
                            height: constraints.maxHeight * 0.25,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 30),
                          _buildForm(),
                          SizedBox(height: size.height * 0.05),
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }

  // Widget xây dựng form đăng ký
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Account',
          style: TextStyle(
            color: primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please fill in your information to get started',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        const SizedBox(height: 28),

        // Full Name Input
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.person, color: primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Email Input
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email, color: primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Password Input
        TextField(
          controller: _passController,
          obscureText: _isObscure,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock, color: primaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility_off : Icons.visibility,
                color: primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Address Input
        TextField(
          controller: _addressController,
          readOnly: true,
          onTap: _showAddressPicker,
          decoration: InputDecoration(
            labelText: 'Shipping Address',
            prefixIcon: const Icon(Icons.home, color: primaryColor),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Sign Up Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 24),

        // Sign In Option
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
