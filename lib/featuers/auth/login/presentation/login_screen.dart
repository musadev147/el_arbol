import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/common_button.dart';
import '../../../../common_wigdets/social_login_button.dart';
import '../../../../common_wigdets/user_role.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../constants/app_assets/assets_icons.dart';
import '../../../../provider/singnup_provider.dart';
import '../../../../route/app_pages.dart';
import '../../../wholesale_b2b/presentation/wholesale_registration_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'data/rx.dart';
import 'model/post_sign_in_model.dart';

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

  late final PostSignInRx _postSignInRx;

  @override
  void initState() {
    super.initState();
    _postSignInRx = PostSignInRx(
      empty: PostSignInModel(),
      dataFetcher: BehaviorSubject<PostSignInModel>(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _postSignInRx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Target brand color from website: #00694C
    const Color primaryBrandColor = Color(0xFF00694C);
    final isEmployee = widget.role == 'employeeSelfService' || widget.role == 'employee Self-service' || widget.role == 'employee' || widget.role == 'staff' || widget.role == UserRole.staff.value;
    final isSpecialPortal = isEmployee;

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
                          Image.asset(
                            AssetsIcons.logoIcons,
                            width: 60.w,
                            height: 60.w,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 10.w),
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
                        isEmployee
                            ? 'Employee Self-Service Portal'
                            : 'Artisan produce, delivered with care.',
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
                  isSpecialPortal ? 'Staff Log In' : 'Log In',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isEmployee
                      ? 'Please enter your Member ID.'
                      : 'Welcome back! Please enter your details.',
                  style: TextFontStyle.textStyle12Poppins400494953.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF6D7A73),
                  ),
                ),
                SizedBox(height: 24.h),



                // Email / Employee ID / Member ID Field
                Text(
                  isEmployee
                      ? 'Member ID'
                      : 'Email Address',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _emailController,
                  hintText: isEmployee
                      ? 'MEM-8902'
                      : 'jane@example.com',
                  keyboardType: isSpecialPortal ? TextInputType.text : TextInputType.emailAddress,
                  borderRadius: 8.r,
                  fillColor: const Color(0xFFECF7E4),
                  borderColor: const Color(0xFF00694C).withOpacity(0.2),
                  focusBorderColor: const Color(0xFF00694C),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEmployee
                          ? 'Please enter your Member ID'
                          : 'Please enter your email';
                    }
                    if (!isSpecialPortal && !GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password Field
                if (!isEmployee) ...[
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
                    fillColor: const Color(0xFFECF7E4),
                    borderColor: const Color(0xFF00694C).withOpacity(0.2),
                    focusBorderColor: const Color(0xFF00694C),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.FORGET_PASSWORD, arguments: widget.role);
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
                  ),
                  SizedBox(height: 24.h),
                ],

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
                      
                      _postSignInRx.loginFunc(
                        email: _emailController.text,
                        password: _passwordController.text,
                        role: widget.role ?? 'customer',
                      );
                    }
                  },
                ),
                SizedBox(height: 24.h),

                // Sign Up Toggle Link
                if (!isEmployee)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.REGISTER, arguments: widget.role);
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
