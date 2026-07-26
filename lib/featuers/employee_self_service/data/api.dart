import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../networks/dio/dio.dart';
import '../../../../networks/exception_handler/data_source.dart';
import '../../../../networks/endpoints.dart';
import '../model/staff_dashboard_model.dart';
import '../model/get_staff_history_model.dart';

class StaffDashboardApi {
  static final StaffDashboardApi _singleton = StaffDashboardApi._internal();
  StaffDashboardApi._internal();
  static StaffDashboardApi get instance => _singleton;

  Future<StaffDashboardModel> fetchDashboard() async {
    try {
      final response = await getHttp(Endpoints.staffDashboard());

      if (response.statusCode == 200) {
        return StaffDashboardModel.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      if (error is DioException) {
        log("DASHBOARD API ERROR DATA: ${error.response?.data}");
      }
      log("DASHBOARD API ERROR: $error");
      rethrow;
    }
  }

  Future<GetStaffHistoryModel> fetchShiftHistory() async {
    try {
      final response = await getHttp(Endpoints.staffShiftHistory());

      if (response.statusCode == 200) {
        return GetStaffHistoryModel.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      if (error is DioException) {
        log("HISTORY API ERROR DATA: ${error.response?.data}");
      }
      log("HISTORY API ERROR: $error");
      rethrow;
    }
  }

  Future<dynamic> updateStaffProfile({
    required String name,
    required String phone,
    String? password,
    String? photoPath,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        'name': name,
        'phone': phone,
      };

      if (password != null && password.isNotEmpty) {
        formDataMap['password'] = password;
      }

      if (photoPath != null && photoPath.isNotEmpty) {
        formDataMap['photo'] = await MultipartFile.fromFile(photoPath);
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await DioSingleton.instance.dio.patch(
        Endpoints.updateStaffProfile(),
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      if (error is DioException) {
        log("UPDATE PROFILE API ERROR DATA: ${error.response?.data}");
      }
      log("UPDATE PROFILE API ERROR: $error");
      rethrow;
    }
  }

  Future<dynamic> checkIn(int storeId) async {
    try {
      final response = await postHttp(Endpoints.staffCheckIn(), {'store_id': storeId});
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> checkOut(Map<String, dynamic> shiftData) async {
    try {
      final response = await postHttp(Endpoints.staffCheckOut(), shiftData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getColleagues() async {
    try {
      final response = await getHttp(Endpoints.staffColleagues());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getTasks({String? date}) async {
    try {
      final url = date != null ? "${Endpoints.staffTasks()}?date=$date" : Endpoints.staffTasks();
      final response = await getHttp(url);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> updateTask(String taskId, String status) async {
    try {
      final response = await DioSingleton.instance.dio.patch(
        Endpoints.staffUpdateTask(taskId),
        data: {'status': status},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getOrderHistory() async {
    try {
      final response = await getHttp(Endpoints.staffOrderHistory());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}

