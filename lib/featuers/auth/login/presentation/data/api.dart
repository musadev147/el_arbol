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
      final trimmedEmail = email.trim();
      final Map<String, dynamic> data = {
        "email": trimmedEmail,
      };

      if (password.trim().isNotEmpty) {
        data["password"] = password;
        data["username"] = trimmedEmail;
      }

      final endpoint = Endpoints.signIn(role: role);
      log("Login calling endpoint: $endpoint");

      final response = await postHttp(endpoint, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return PostSignInModel.fromJson(response.data);
        } else if (response.data is Map) {
          return PostSignInModel.fromJson(Map<String, dynamic>.from(response.data));
        } else {
          return PostSignInModel();
        }
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
