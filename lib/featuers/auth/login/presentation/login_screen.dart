import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/common_button.dart';
import '../../../../common_wigdets/social_login_button.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../constants/app_assets/assets_icons.dart';
import '../../../../provider/singnup_provider.dart';
import '../../../../route/app_pages.dart';

class SignInScreen extends StatefulWidget {
  final String? role;
  const SignInScreen({super.key, this.role});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Target brand color from website: #00694C
    const Color primaryBrandColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8), // matching web body bg
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                // Brand Header/Logo
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco,
                            color: primaryBrandColor,
                            size: 32.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'El Árbol',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF151E13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Artisan produce, delivered with care.',
                        style: TextFontStyle.textStyle12Poppins400494953.copyWith(
                          fontSize: 14.sp,
                          color: const Color(0xFF6D7A73),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // Welcome back text
                Text(
                  'Log In',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Welcome back! Please enter your details.',
                  style: TextFontStyle.textStyle12Poppins400494953.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF6D7A73),
                  ),
                ),
                SizedBox(height: 24.h),

                // Social Log In Button
                SocialLoginButton(
                  title: 'Continue with Google',
                  iconPath: AssetsIcons.googleIcon,
                  onPressed: () {
                    // Handle social login
                  },
                ),
                SizedBox(height: 24.h),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: const Color(0xFF6D7A73),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Email Field
                Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _emailController,
                  hintText: 'jane@example.com',
                  keyboardType: TextInputType.emailAddress,
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF151E13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.FORGET_PASSWORD);
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryBrandColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  isPassword: true,
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Log In Button
                CommonButton(
                  text: 'Log In',
                  backgroundColor: primaryBrandColor,
                  borderRadius: 8.r,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save login email to signup provider/session if needed
                      final provider = Provider.of<SignupProvider>(context, listen: false);
                      provider.setLoginEmail(_emailController.text);
                      
                      // Go to Nav/Home
                      Get.offAllNamed(Routes.NAV, arguments: widget.role);
                    }
                  },
                ),
                SizedBox(height: 24.h),

                // Sign Up Toggle Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.ONBOARDING, arguments: widget.role);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: const Color(0xFF6D7A73),
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: primaryBrandColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
