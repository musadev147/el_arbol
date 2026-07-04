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
import '../model/post_sign_in_model.dart';
import 'api.dart';

class PostSignInRx extends RxResponseInt<PostSignInModel> {
  final api = PostSignInApi.instance;

  late String _selectedRole;

  PostSignInRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> loginFunc({
    required String email,
    required String password,
    required String role,
  }) async {
    _selectedRole = role;

    try {
      await EasyLoading.show(status: "Logging in...");

      final data = await api.loginData(
        email: email,
        password: password,
        role: role,
      );

      await handleSuccessWithReturn(data);
    } catch (error) {
      log("Login error: $error");
      await handleErrorWithReturn(error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  handleSuccessWithReturn(PostSignInModel data) async {
    final apiRoleString = data.user?.userType ?? _selectedRole;
    final role = UserRole.fromString(apiRoleString);

    if (apiRoleString.toLowerCase() != _selectedRole.toLowerCase()) {
      AppToast.error(
        "This account is registered as ${apiRoleString.toUpperCase()}.\n"
        "Please login using the correct role.",
      );
      return;
    }

    AppToast.success("Login Successful!");

    final accessToken = data.access ?? "";
    final id = data.user?.id ?? 0;

    await appData.write(kKeyAccessToken, accessToken);
    await appData.write(kKeyUserID, id.toString());
    
    if (accessToken.isNotEmpty) {
      DioSingleton.instance.update(accessToken);
    }
    await appData.write('user_role', role.value);

    Get.offAll(() => CustomNavigation(role: role));
  }

  @override
  handleErrorWithReturn(error) async {
    String message = "Login failed";

    if (error is DioException) {
      message = error.response?.data["message"] ?? message;

      if (error.type == DioExceptionType.connectionError) {
        message = "Check Your Network Connection";
      }
    }

    AppToast.error(message);
  }
}
