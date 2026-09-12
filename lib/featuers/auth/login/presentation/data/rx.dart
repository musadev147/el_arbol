import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../../constants/app_constants.dart';
import '../../../../../../helpers/di.dart';
import '../../../../../../networks/dio/dio.dart';
import '../../../../../../networks/dio/token_storage.dart';
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

  Future<void> _clearSession() async {
    try {
      await appData.remove(kKeyAccessToken);
      await appData.remove(kKeyRefreshToken);
      await appData.remove(kKeyUserID);
      await appData.remove('user_role');
      await TokenStorage().clearTokens();
      DioSingleton.instance.update('');
    } catch (e) {
      log("Error clearing session: $e");
    }
  }

  Future<void> loginFunc({
    required String email,
    required String password,
    required String role,
  }) async {
    _selectedRole = role;
    final selectedRoleEnum = UserRole.fromString(role);

    try {
      // Clear any previous session before attempting new login
      await _clearSession();
      await EasyLoading.show(status: selectedRoleEnum == UserRole.staff ? "Accessing Staff Portal..." : "Logging in...");

      final data = await api.loginData(
        email: email,
        password: password,
        role: role,
      );

      await handleSuccessWithReturn(data);
    } catch (error) {
      log("Login error: $error");
      await _clearSession();
      await handleErrorWithReturn(error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  handleSuccessWithReturn(PostSignInModel data) async {
    final accessToken = data.access ?? "";
    final refreshToken = data.refresh ?? "";
    final userId = (data.user?.id ?? data.jwtClaims['user_id'] ?? "").toString();

    if (accessToken.trim().isEmpty) {
      await _clearSession();
      AppToast.error("Login failed: Authentication token was not returned.");
      return;
    }

    final selectedRoleEnum = UserRole.fromString(_selectedRole);
    final isWholesale = data.isWholesaleAccount;
    final isStaff = data.isStaffAccount;

    log("User Login Resolved: isWholesale=$isWholesale, isStaff=$isStaff, selectedRole=$selectedRoleEnum, claims=${data.jwtClaims}");

    // Strict Role Validation Check
    if (selectedRoleEnum == UserRole.wholesale) {
      if (!isWholesale) {
        await _clearSession();
        AppToast.error(
          "Access Denied: This account is not a Wholesale account.\n"
          "Please log in through the Customer or Staff portal.",
        );
        return;
      }

      if (!data.isApprovedWholesale) {
        await _clearSession();
        if (data.wholesaleStatus == 'rejected') {
          AppToast.error("Your Wholesale account application has been rejected.");
        } else {
          AppToast.error("Your Wholesale account is currently pending administrator approval.");
        }
        return;
      }
    } else if (selectedRoleEnum == UserRole.staff || selectedRoleEnum == UserRole.employeeSelfService) {
      if (isWholesale) {
        await _clearSession();
        AppToast.error(
          "Access Denied: This is a Wholesale B2B account.\n"
          "Please log in through the Wholesales portal.",
        );
        return;
      }
    } else if (selectedRoleEnum == UserRole.customer) {
      if (isWholesale) {
        await _clearSession();
        AppToast.error(
          "Access Denied: This is a Wholesale B2B account.\n"
          "Please log in through the Wholesales portal.",
        );
        return;
      }
    }

    // Save tokens and session upon verified role match
    await appData.write(kKeyAccessToken, accessToken);
    if (refreshToken.isNotEmpty) {
      await appData.write(kKeyRefreshToken, refreshToken);
    }
    if (userId.isNotEmpty) {
      await appData.write(kKeyUserID, userId);
    }
    await appData.write('user_role', selectedRoleEnum.value);

    // Save into TokenStorage for AuthInterceptor and secure storage
    final tokenStorage = TokenStorage();
    await tokenStorage.saveAccessToken(accessToken);
    if (refreshToken.isNotEmpty) {
      await tokenStorage.saveRefreshToken(refreshToken);
    }

    DioSingleton.instance.update(accessToken);

    AppToast.success("Login Successful!");

    Get.offAll(() => CustomNavigation(role: selectedRoleEnum));
  }

  @override
  handleErrorWithReturn(error) async {
    String message = "Login failed. Please check your credentials.";

    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map) {
        String? detailedErrors;
        if (responseData['errors'] is List && (responseData['errors'] as List).isNotEmpty) {
          detailedErrors = (responseData['errors'] as List).map((e) => e.toString()).join('\n');
        } else if (responseData['errors'] is Map) {
          detailedErrors = (responseData['errors'] as Map).values.map((v) => v is List ? v.join(', ') : v.toString()).join('\n');
        } else if (responseData['non_field_errors'] is List && (responseData['non_field_errors'] as List).isNotEmpty) {
          detailedErrors = (responseData['non_field_errors'] as List).join('\n');
        } else if (responseData['detail'] != null) {
          detailedErrors = responseData['detail'].toString();
        } else if (responseData['error'] != null) {
          detailedErrors = responseData['error'].toString();
        } else if (responseData['message'] != null) {
          detailedErrors = responseData['message'].toString();
        } else if (responseData['email'] is List && (responseData['email'] as List).isNotEmpty) {
          detailedErrors = "Email: ${(responseData['email'] as List).join(', ')}";
        } else if (responseData['password'] is List && (responseData['password'] as List).isNotEmpty) {
          detailedErrors = "Password: ${(responseData['password'] as List).join(', ')}";
        }

        message = detailedErrors ?? message;
      } else if (responseData is String) {
        if (responseData.contains("<!DOCTYPE html>") || responseData.contains("<html")) {
          message = "Server error: ${error.response?.statusCode ?? 500} ${error.response?.statusMessage ?? 'Internal Server Error'}";
        } else if (responseData.trim().isNotEmpty) {
          message = responseData.trim();
        }
      }

      if (error.type == DioExceptionType.connectionError || error.type == DioExceptionType.connectionTimeout) {
        message = "Check Your Network Connection";
      }
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    AppToast.error(message);
    if (!dataFetcher.isClosed) {
      dataFetcher.sink.addError(error);
    }
  }
}
