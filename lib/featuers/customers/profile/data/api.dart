import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/endpoints.dart';
import '../../../../../networks/exception_handler/data_source.dart';

class CustomerProfileApi {
  static final CustomerProfileApi _singleton = CustomerProfileApi._internal();
  CustomerProfileApi._internal();
  static CustomerProfileApi get instance => _singleton;

  Future<dynamic> getProfile() async {
    try {
      final response = await getHttp(Endpoints.customerProfile());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await patchHttp(Endpoints.customerProfile(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateAvatar(File image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(image.path, filename: fileName),
        "avatar": await MultipartFile.fromFile(image.path, filename: fileName),
      });

      try {
        final response = await postHttp(Endpoints.customerAvatar(), formData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.data;
        }
      } catch (e) {
        // Fallback endpoint if primary fails
        FormData fallbackData = FormData.fromMap({
          "image": await MultipartFile.fromFile(image.path, filename: fileName),
          "avatar": await MultipartFile.fromFile(image.path, filename: fileName),
        });
        final response = await postHttp(Endpoints.updateAvater(), fallbackData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.data;
        }
      }
      throw DataSource.DEFAULT.getFailure();
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> changePassword(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.customerChangePassword(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }
}
