import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../../constants/app_constants.dart';
import '../../../../../../helpers/di.dart';
import '../../../../../../networks/dio/dio.dart';
import '../../../../../../networks/rx_base.dart';

import '../../../../../common_wigdets/app_toast.dart';
import '../../../../../common_wigdets/user_role.dart';
import '../../../../../common_wigdets/custom_navigation.dart';
import '../model/post_register_model.dart';
import 'api.dart';

class PostRegisterRx extends RxResponseInt<PostRegisterModel> {
  final api = PostRegisterApi.instance;

  late String _selectedRole;

  PostRegisterRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> registerFunc({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required String role,
    String? businessName,
    String? contactName,
    String? tradeLicenseNumber,
    String? postcode,
    String? businessType,
    String? monthlyVolume,
  }) async {
    _selectedRole = role;

    try {
      await EasyLoading.show(status: "Registering...");

      final data = await api.registerData(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirm: passwordConfirm,
        role: role,
        businessName: businessName,
        contactName: contactName,
        tradeLicenseNumber: tradeLicenseNumber,
        postcode: postcode,
        businessType: businessType,
        monthlyVolume: monthlyVolume,
      );

      await handleSuccessWithReturn(data);
    } catch (error) {
      log("Register error: $error");
      await handleErrorWithReturn(error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  handleSuccessWithReturn(PostRegisterModel data) async {
    AppToast.success("Registration Successful!");

    final accessToken = data.access ?? "";
    final id = data.user?.id ?? "";

    await appData.write(kKeyAccessToken, accessToken);
    await appData.write(kKeyUserID, id.toString());
    
    if (accessToken.isNotEmpty) {
      DioSingleton.instance.update(accessToken);
    }
    
    final role = UserRole.fromString(_selectedRole);
    await appData.write('user_role', role.value);

    Get.offAll(() => CustomNavigation(role: role));
  }

  @override
  handleErrorWithReturn(error) async {
    String message = "Registration failed";

    if (error is DioException) {
      message = error.response?.data["message"] ?? message;

      if (error.type == DioExceptionType.connectionError) {
        message = "Check Your Network Connection";
      }
    }

    AppToast.error(message);
  }
}