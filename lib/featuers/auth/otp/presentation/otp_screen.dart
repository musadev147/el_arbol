import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../../common_wigdets/common_button.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../common_wigdets/user_role.dart';
import '../../../../provider/forget_password_provider.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import '../../../../route/app_pages.dart';
import 'package:rxdart/rxdart.dart';

import '../../forget_password/presentation/data/rx.dart';
import '../../forget_password/presentation/model/forget_model.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late final WholesalePasswordResetVerifyRx _wholesaleRx;
  late final WholesalePasswordResetSendOtpRx _wholesaleSendOtpRx;
  late final ForgetPasswordRx _forgetPasswordRx;
  String? _role;
  Timer? _timer;
  int _secondsRemaining = 59;

  void _startTimer() {
    setState(() {
      _secondsRemaining = 59;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _wholesaleRx = WholesalePasswordResetVerifyRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _wholesaleSendOtpRx = WholesalePasswordResetSendOtpRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _forgetPasswordRx = ForgetPasswordRx(
      empty: ForgetEmailModel(),
      dataFetcher: BehaviorSubject<ForgetEmailModel>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null && Get.arguments is String) {
        setState(() {
          _role = Get.arguments;
        });
      }
    });
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _wholesaleRx.dispose();
    _wholesaleSendOtpRx.dispose();
    _forgetPasswordRx.dispose();
    _timer?.cancel();
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
                SizedBox(height: 24.h),
                Text('New Password', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter new password' : null,
                ),
                SizedBox(height: 16.h),
                Text('Confirm Password', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Confirm password';
                    if (val != _newPasswordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: 32.h),

                // Verify Button
                CommonButton(
                  text: 'Verify & Reset',
                  backgroundColor: primaryBrandColor,
                  borderRadius: 8.r,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_role == UserRole.wholesale.value || _role == 'wholesale') {
                        _wholesaleRx.verifyOtpAndReset(email, _otpController.text, _newPasswordController.text).then((success) {
                          if (success) {
                            Get.offAllNamed(Routes.LOGIN, arguments: _role);
                          }
                        });
                      } else {
                        // existing logic for other roles
                        Get.offAllNamed(Routes.NAV);
                      }
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
                        onTap: _secondsRemaining > 0 ? null : () {
                          if (_role == UserRole.wholesale.value || _role == 'wholesale') {
                            _wholesaleSendOtpRx.sendOtp(email);
                          } else {
                            _forgetPasswordRx.sendOtpFunc(email: email, isResend: true);
                          }
                          _startTimer();
                        },
                        child: Text(
                          _secondsRemaining > 0 ? 'Resend in ${_secondsRemaining}s' : 'Resend',
                          style: TextStyle(
                            color: _secondsRemaining > 0 ? Colors.grey : primaryBrandColor,
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
