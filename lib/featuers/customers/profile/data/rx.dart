import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import 'api.dart';
import 'dart:developer';

class CustomerProfileRx extends RxResponseInt<Map<String, dynamic>> {
  final api = CustomerProfileApi.instance;

  CustomerProfileRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchProfile() async {
    try {
      final data = await api.getProfile();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('CustomerProfileRx fetchProfile error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    try {
      await EasyLoading.show(status: 'Updating Profile...');
      final data = await api.updateProfile(payload);
      AppToast.success("Profile Updated Successfully!");
      fetchProfile();
      return true;
    } catch (e) {
      log('CustomerProfileRx updateProfile error: $e');
      String message = "Failed to update profile";
      if (e is DioException) {
        if (e.response?.data is Map) {
          message = e.response?.data["message"] ?? message;
        }
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> updateAvatar(File image) async {
    try {
      await EasyLoading.show(status: 'Uploading Image...');
      final data = await api.updateAvatar(image);
      AppToast.success("Avatar Updated Successfully!");
      fetchProfile();
      return true;
    } catch (e) {
      log('CustomerProfileRx updateAvatar error: $e');
      String message = "Failed to upload image";
      if (e is DioException) {
        if (e.response?.data is Map) {
          message = e.response?.data["message"] ?? message;
        }
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(dynamic data) async {
    dataFetcher.sink.add(data is Map<String, dynamic> ? data : (data is Map ? Map<String, dynamic>.from(data) : {}));
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}


class CustomerChangePasswordRx extends RxResponseInt<void> {
  final api = CustomerProfileApi.instance;

  CustomerChangePasswordRx({required super.empty, required super.dataFetcher});

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await EasyLoading.show(status: 'Updating Password...');
      await api.changePassword({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      });
      AppToast.success("Password Changed Successfully!");
      return true;
    } catch (e) {
      log('CustomerChangePasswordRx error: $e');
      String message = "Failed to change password";
      if (e is DioException) {
        if (e.response?.data is Map) {
          message = e.response?.data["message"] ?? message;
        }
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(void data) async {}

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {}
}
