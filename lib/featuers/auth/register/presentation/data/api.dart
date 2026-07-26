import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../../../../networks/dio/dio.dart';
import '../../../../../../networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';
import '../model/post_register_model.dart';

class PostRegisterApi {
  static final PostRegisterApi _singleton = PostRegisterApi._internal();
  PostRegisterApi._internal();
  static PostRegisterApi get instance => _singleton;

  Future<PostRegisterModel> registerData({
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
    log("register: $email");
    log("Role: $role");

    try {
      final parts = name.trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : name;
      final lastNameVal = parts.length > 1 ? parts.sublist(1).join(' ') : firstName;

      final userType = role.toUpperCase(); // e.g. CUSTOMER

      final data = {
        "name": name,
        "first_name": firstName,
        "last_name": lastNameVal,
        "firstName": firstName,
        "lastName": lastNameVal,
        "fullName": name,
        "email": email,
        "username": email,
        "phone": phone,
        "password": password,
        "password_confirmation": passwordConfirm,
        "passwordConfirm": passwordConfirm,
        "confirmPassword": passwordConfirm,
        "role": userType,
        "user_role": userType,
        "user_type": userType,
      };

      if (businessName != null && businessName.isNotEmpty) {
        data["business_name"] = businessName;
      }
      if (contactName != null && contactName.isNotEmpty) {
        data["contact_name"] = contactName;
      }
      if (tradeLicenseNumber != null && tradeLicenseNumber.isNotEmpty) {
        data["trade_license_number"] = tradeLicenseNumber;
      }
      if (postcode != null && postcode.isNotEmpty) {
        data["postcode"] = postcode;
      }
      if (businessType != null && businessType.isNotEmpty) {
        data["business_type"] = businessType;
      }
      if (monthlyVolume != null && monthlyVolume.isNotEmpty) {
        data["monthly_volume"] = monthlyVolume;
      }

      final response = await postHttp(Endpoints.register(role: role), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostRegisterModel.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      if (error is DioException) {
        log("REGISTER API RESPONSE ERROR DATA: ${error.response?.data}");
      }
      log("REGISTER API ERROR: $error");
      rethrow;
    }
  }
}
