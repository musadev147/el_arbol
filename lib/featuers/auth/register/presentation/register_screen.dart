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

class RegisterScreen extends StatefulWidget {
  final String? role;
  const RegisterScreen({super.key, this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrandColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Create an account to order fresh produce.',
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
                    // Handle social sign up
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

                // Full Name
                Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _nameController,
                  hintText: 'Jane Doe',
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Email Address
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

                // Phone Number
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _phoneController,
                  hintText: '+34 600 000 000',
                  keyboardType: TextInputType.phone,
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password Field
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
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
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Confirm Password Field
                Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  hintText: '••••••••',
                  isPassword: true,
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Sign Up Button
                CommonButton(
                  text: 'Sign Up',
                  backgroundColor: primaryBrandColor,
                  borderRadius: 8.r,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final provider = Provider.of<SignupProvider>(context, listen: false);
                      provider.setFullName(_nameController.text);
                      provider.setEmail(_emailController.text);
                      provider.setPhone(_phoneController.text);
                      provider.setPassword(_passwordController.text);
                      provider.setPasswordConfirm(_confirmPasswordController.text);
                      
                      // Go to Nav/Home
                      Get.offAllNamed(Routes.NAV, arguments: widget.role);
                    }
                  },
                ),
                SizedBox(height: 24.h),

                // Log In Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.offNamed(Routes.LOGIN, arguments: widget.role);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: const Color(0xFF6D7A73),
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: 'Log In',
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
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
