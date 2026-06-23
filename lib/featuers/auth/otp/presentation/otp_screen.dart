import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../../common_wigdets/common_button.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../provider/forget_password_provider.dart';
import '../../../../route/app_pages.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrandColor = Color(0xFF00694C);
    final forgetProvider = Provider.of<ForgetPasswordProvider>(context);
    final email = forgetProvider.forgetEmail ?? "your email";

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
                  'Verify Code',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "We've sent a code to $email",
                  style: TextFontStyle.textStyle12Poppins400494953.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF6D7A73),
                  ),
                ),
                SizedBox(height: 40.h),

                // PIN Code Entry
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8.r),
                    fieldHeight: 56.h,
                    fieldWidth: 56.w,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: primaryBrandColor,
                    inactiveColor: Colors.grey.shade300,
                    selectedColor: primaryBrandColor,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  validator: (value) {
                    if (value == null || value.length < 4) {
                      return 'Please enter the 4-digit code';
                    }
                    return null;
                  },
                  onChanged: (value) {},
                ),
                SizedBox(height: 32.h),

                // Verify Button
                CommonButton(
                  text: 'Verify',
                  backgroundColor: primaryBrandColor,
                  borderRadius: 8.r,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Navigate to nav / home on successful validation
                      Get.offAllNamed(Routes.NAV);
                    }
                  },
                ),
                SizedBox(height: 24.h),

                // Resend section
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          color: const Color(0xFF6D7A73),
                          fontSize: 14.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle resend code action
                        },
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            color: primaryBrandColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
