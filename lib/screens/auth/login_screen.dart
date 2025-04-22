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
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Center(
            child:
                isWideScreen
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Section (Only on Web / Large Screen)
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset(
                              "assets/images/vector-1.png",
                              height: constraints.maxHeight * 0.5,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // Form Section
                        Expanded(
                          flex: 1,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: _buildForm(),
                          ),
                        ),
                      ],
                    )
                    : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/vector-1.png",
                            width: constraints.maxWidth * 0.8,
                            height: constraints.maxHeight * 0.4,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 30),
                          _buildForm(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log in to Naturify',
            style: TextStyle(
              color: primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Email Input
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),

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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Sign In Button
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ),
          ),

          // Sign Up Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Don’t have an account?',
                style: TextStyle(fontSize: 13),
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
                  ),
                ),
              ),
            ],
          ),

          // Forget Password
          Align(
            alignment: Alignment.topCenter,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, forgotPasswordRoute);
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
