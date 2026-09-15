import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/common_button.dart';
import '../../../../common_wigdets/user_role.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../constants/app_assets/assets_icons.dart';
import '../../../../provider/singnup_provider.dart';
import '../../../../route/app_pages.dart';
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
    const Color primaryBrandColor = Color(0xFF00694C);
    final userRoleEnum = UserRole.fromString(widget.role);
    final isWholesale = userRoleEnum == UserRole.wholesale;
    final isStaff = userRoleEnum == UserRole.staff || userRoleEnum == UserRole.employeeSelfService;

    final String portalTitle = isWholesale
        ? 'Wholesale Log In'
        : isStaff
            ? 'Staff Log In'
            : 'Log In';

    final String portalSubtitle = isWholesale
        ? 'Wholesale B2B & Merchant Portal'
        : isStaff
            ? 'Staff & Operations Portal'
            : 'Artisan produce, delivered with care.';

    final String identifierLabel = isWholesale
        ? 'Business Email'
        : isStaff
            ? "Staff I'd"
            : 'Email Address';

    final String identifierHint = isWholesale
        ? 'e.g. orders@restaurant.com'
        : isStaff
            ? "e.g. staff I'd"
            : 'e.g. jane@example.com';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                // Brand Header/Logo
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetsIcons.logoIcons,
                            width: 54.w,
                            height: 54.w,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'El Árbol',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF151E13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        portalSubtitle,
                        style: TextFontStyle.textStyle12Poppins400494953.copyWith(
                          fontSize: 13.sp,
                          color: const Color(0xFF6D7A73),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 36.h),

                // Welcome header text
                Text(
                  portalTitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Welcome back! Please enter your credentials to log in.',
                  style: TextFontStyle.textStyle12Poppins400494953.copyWith(
                    fontSize: 13.sp,
                    color: const Color(0xFF6D7A73),
                  ),
                ),
                SizedBox(height: 24.h),

                // Email / Member ID Field
                Text(
                  identifierLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _emailController,
                  hintText: identifierHint,
                  keyboardType: isStaff ? TextInputType.text : TextInputType.emailAddress,
                  borderRadius: 8.r,
                  fillColor: const Color(0xFFECF7E4),
                  borderColor: const Color(0xFF00694C).withOpacity(0.2),
                  focusBorderColor: const Color(0xFF00694C),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return isStaff
                          ? "Please enter your Staff I'd"
                          : 'Please enter your $identifierLabel';
                    }
                    if (!isStaff && !GetUtils.isEmail(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password Field (Hidden for Staff login)
                if (!isStaff) ...[
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
                  SizedBox(height: 12.h),
                ],
                SizedBox(height: 16.h),

                // Log In Button
                CommonButton(
                  text: isStaff ? 'Access Portal' : 'Log In',
                  backgroundColor: primaryBrandColor,
                  borderRadius: 8.r,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final provider = Provider.of<SignupProvider>(context, listen: false);
                      provider.setLoginEmail(_emailController.text.trim());
                      
                      _postSignInRx.loginFunc(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        role: widget.role ?? 'customer',
                      );
                    }
                  },
                ),
                SizedBox(height: 24.h),

                // Sign Up Toggle Link / Staff Notice
                if (isWholesale) ...[
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.REGISTER, arguments: widget.role);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have a Wholesale account? ",
                          style: TextStyle(
                            color: const Color(0xFF6D7A73),
                            fontSize: 13.sp,
                            fontFamily: 'Poppins',
                          ),
                          children: [
                            TextSpan(
                              text: 'Apply for Wholesale',
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
                ] else if (isStaff) ...[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 15.r, color: const Color(0xFF6D7A73)),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              'Staff accounts are registered by administrator.',
                              style: TextStyle(
                                color: const Color(0xFF6D7A73),
                                fontSize: 12.sp,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
