import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/common_button.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../common_wigdets/user_role.dart';
import '../../../../provider/forget_password_provider.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import '../../../../route/app_pages.dart';
import 'data/rx.dart';
import 'model/forget_model.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late final ForgetPasswordRx _forgetPasswordRx;
  late final WholesalePasswordResetSendOtpRx _wholesaleRx;
  String? _role;

  @override
  void initState() {
    super.initState();
    _forgetPasswordRx = ForgetPasswordRx(
      empty: ForgetEmailModel(),
      dataFetcher: BehaviorSubject<ForgetEmailModel>(),
    );
    _wholesaleRx = WholesalePasswordResetSendOtpRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    // Read role from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null && Get.arguments is String) {
        setState(() {
          _role = Get.arguments;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _forgetPasswordRx.dispose();
    _wholesaleRx.dispose();
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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "No worries, we'll send you reset instructions.",
                  style: TextFontStyle.textStyle12Poppins400494953.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF6D7A73),
                  ),
                ),
                SizedBox(height: 32.h),

                // Email Input
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
                SizedBox(height: 32.h),

                // Reset Button
                CommonButton(
                  text: 'Reset Password',
                  backgroundColor: primaryBrandColor,
                  borderRadius: 8.r,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final provider = Provider.of<ForgetPasswordProvider>(context, listen: false);
                      provider.setForgetEmail(_emailController.text);
                      
                      if (_role == UserRole.wholesale.value || _role == 'wholesale') {
                        _wholesaleRx.sendOtp(_emailController.text).then((success) {
                          if (success) {
                            Get.toNamed(Routes.OTP, arguments: _role);
                          }
                        });
                      } else {
                        // Request reset OTP from the backend API for normal customers
                        _forgetPasswordRx.sendOtpFunc(email: _emailController.text, role: _role);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
