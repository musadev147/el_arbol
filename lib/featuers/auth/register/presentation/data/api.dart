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
      final isWholesale = role.toLowerCase() == 'wholesale' || role.toLowerCase() == 'wholesales';
      final Map<String, dynamic> data;

      if (isWholesale) {
        data = {
          "email": email.trim(),
          "password": password,
          "business_name": (businessName ?? '').trim(),
          "contact_name": (contactName ?? name).trim(),
          "trade_license_number": (tradeLicenseNumber ?? '').trim(),
          "phone": phone.trim(),
          "postcode": (postcode ?? '').trim(),
          "business_type": (businessType ?? 'restaurant').trim(),
          "monthly_volume": (monthlyVolume ?? '1000_3000').trim(),
        };
      } else {
        final parts = name.trim().split(' ');
        final firstName = parts.isNotEmpty ? parts.first : name;
        final lastNameVal = parts.length > 1 ? parts.sublist(1).join(' ') : firstName;
        final userType = role.toUpperCase();

        data = {
          "name": name.trim(),
          "first_name": firstName,
          "last_name": lastNameVal,
          "firstName": firstName,
          "lastName": lastNameVal,
          "fullName": name.trim(),
          "email": email.trim(),
          "username": email.trim(),
          "phone": phone.trim(),
          "password": password,
          "password_confirmation": passwordConfirm,
          "passwordConfirm": passwordConfirm,
          "confirmPassword": passwordConfirm,
          "role": userType,
          "user_role": userType,
          "user_type": userType,
        };
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
