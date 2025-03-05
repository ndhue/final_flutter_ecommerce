import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isObscure = true; // 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
        padding: const EdgeInsets.only(left: 15, top: 15),
        child: Image.asset(
          "assets/images/vector-1.png",
          width: MediaQuery.of(context).size.width * 0.9, // 90% chiều rộng
          height: MediaQuery.of(context).size.height * 0.4, // 40% chiều cao
          fit: BoxFit.fill,
        ),
      ),
      SizedBox(
        height: 30,
      ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Log In',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30,
                  width: 250,),
                    

                  // 📌 Email TextField
                  TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(width: 1, color: Color(0xFF837E93)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(width: 1, color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📌 Password TextField
                  TextField(
                    controller: _passController,
                    obscureText: _isObscure, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(width: 1, color: Color(0xFF837E93)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(width: 1, color: primaryColor),
                      ),
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
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 📌 Sign In Button (Căn giữa)
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 329,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
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
                  const SizedBox(height: 15),

                  // 📌 Sign Up Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don’t have an account?',
                        style: TextStyle(
                          color: Color(0xFF837E93),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2.5),
                      InkWell(
                        onTap: () {
                          // Điều hướng sang trang đăng ký
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 📌 Forget Password (Căn giữa)
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        // Xử lý quên mật khẩu
                      },
                      child: const Text(
                        'Forget Password?',
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
            ),
          ],
        ),
      ),
    );
  }
}
