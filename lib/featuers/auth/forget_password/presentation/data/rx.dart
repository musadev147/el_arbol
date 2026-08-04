import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import '../model/forget_model.dart';
import 'api.dart';
import '../../../../../../route/app_pages.dart';

/// Reactive response handler for Password Reset OTP flow.
class ForgetPasswordRx extends RxResponseInt<ForgetEmailModel> {
  final api = ForgetPasswordApi.instance;

  ForgetPasswordRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream get valueStreamData => dataFetcher.stream;

  bool _isResend = false;
  String? _role;

  /// Calls the API to send OTP to the user's email.
  Future<void> sendOtpFunc({required String email, String? role, bool isResend = false}) async {
    _isResend = isResend;
    _role = role;
    try {
      await EasyLoading.show(status: isResend ? "Resending OTP..." : "Sending OTP...");

      final data = await api.sendOtp(email: email, role: role);

      await handleSuccessWithReturn(data);
    } catch (error) {
      log("Send OTP error: $error");
      await handleErrorWithReturn(error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  handleSuccessWithReturn(ForgetEmailModel data) async {
    AppToast.success(data.detail ?? "OTP sent successfully!");
    if (!_isResend) {
      Get.toNamed(Routes.OTP, arguments: _role);
    }
  }

  @override
  handleErrorWithReturn(error) async {
    String message = "Failed to send OTP";

    if (error is DioException) {
      message = error.response?.data["message"] ?? error.response?.data["detail"] ?? message;

      if (error.type == DioExceptionType.connectionError) {
        message = "Check Your Network Connection";
      }
    }

    AppToast.error(message);
  }
  Future<bool> verifyOtpAndReset({
    required String email,
    required String otp,
    required String password,
    String? role,
  }) async {
    try {
      await EasyLoading.show(status: 'Resetting password...');
      await api.verifyOtpAndReset(
        email: email,
        otp: otp,
        password: password,
        role: role,
      );
      AppToast.success("Password reset successful!");
      return true;
    } catch (error) {
      log("Reset password error: $error");
      handleErrorWithReturn(error);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
