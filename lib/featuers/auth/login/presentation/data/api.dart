import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../../../networks/dio/dio.dart';
import '../../../../../../networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';
import '../model/post_sign_in_model.dart';

class PostSignInApi {
  static final PostSignInApi _singleton = PostSignInApi._internal();
  PostSignInApi._internal();
  static PostSignInApi get instance => _singleton;

  Future<PostSignInModel> loginData({
    required String email,
    required String password,
    required String role,
  }) async {
    log("login: $email");
    log("Role: $role");

    try {
      final userType = role.toUpperCase(); // e.g. CUSTOMER

      final data = {
        "email": email,
        "username": email,
        "password": password,
      };

      final response = await postHttp(Endpoints.signIn(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostSignInModel.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      if (error is DioException) {
        log("LOGIN API RESPONSE ERROR DATA: ${error.response?.data}");
      }
      log("LOGIN API ERROR: $error");
      rethrow;
    }
  }
}
