import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isObscure = true; // Ẩn mật khẩu ban đầu
  bool _isLoading = false; // Loading khi đăng nhập

  Future<void> _handleLogin() async {
    if (!mounted) return; // Ensure the widget is still mounted
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    bool success = await authProvider.signIn(email, password);
    if (!mounted) return; // Check again after async operation
    setState(() => _isLoading = false);

    if (success) {
      final user = authProvider.user;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed. Please try again.")),
          );
        }
        return;
      }

      String uid = user.uid;
      await userProvider.fetchUser(uid);
      String? role = userProvider.getUserRole();

      if (role == "admin") {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(adminEntryPointRoute, (route) => false);
        }
      } else {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(entryPointScreenRoute, (route) => false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                                        "assets/images/vector-1.png",
                                        fit: BoxFit.contain,
                                        height: constraints.maxHeight * 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      "Welcome to Naturify",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      "Your one-stop shop for natural products",
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

                          // Form Section with card style for visual separation
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
                          SizedBox(height: size.height * 0.08),
                          Image.asset(
                            "assets/images/vector-1.png",
                            width: constraints.maxWidth * 0.7,
                            height: constraints.maxHeight * 0.3,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 40),
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

  // Xây dựng form đăng nhập
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Log in to Naturify',
          style: TextStyle(
            color: primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter your details to sign in',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        const SizedBox(height: 32),

        // Email Input
        TextField(
          controller: _emailController,
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

        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, forgotPasswordRoute);
            },
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Sign In Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
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
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 24),

        // Sign Up Option
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account?',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationScreen(),
                  ),
                );
              },
              child: const Text(
                'Sign Up',
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
