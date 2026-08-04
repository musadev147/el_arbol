import '../../../../../../networks/dio/dio.dart';
import '../../../../../../networks/exception_handler/data_source.dart';
import '../../../../../../networks/endpoints.dart';
import '../model/forget_model.dart';

/// API remote data source for Forget Password features.
class ForgetPasswordApi {
  static final ForgetPasswordApi _singleton = ForgetPasswordApi._internal();
  ForgetPasswordApi._internal();
  static ForgetPasswordApi get instance => _singleton;

  /// Calls backend send-otp endpoint for password resets.
  Future<ForgetEmailModel> sendOtp({required String email, String? role}) async {
    try {
      final data = {
        "email": email,
        if (role != null) "type": role.toUpperCase(),
      };

      final response = await postHttp(Endpoints.forgetPasswordSendOtp(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ForgetEmailModel.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> verifyOtpAndReset({
    required String email,
    required String otp,
    required String password,
    String? role,
  }) async {
    try {
      final data = {
        "email": email,
        "otp": otp,
        "password": password,
        if (role != null) "type": role.toUpperCase(),
      };

      final response = await postHttp(Endpoints.passwordResetVerify(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
