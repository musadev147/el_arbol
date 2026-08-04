import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../networks/dio/dio.dart';
import '../../../../networks/exception_handler/data_source.dart';
import '../../../../networks/endpoints.dart';
import '../model/staff_dashboard_model.dart';
import '../model/get_staff_history_model.dart';
import '../model/staff_chat_model.dart';

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

  Future<dynamic> getStaffProfile() async {
    try {
      final response = await getHttp(Endpoints.updateStaffProfile());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
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

  Future<dynamic> getDayOffRequests() async {
    try {
      final response = await getHttp(Endpoints.staffDayOffRequests());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> createDayOffRequest(String date, String reason) async {
    try {
      final response = await postHttp(Endpoints.staffDayOffRequests(), {
        'date': date,
        'reason': reason,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getDayOffRequestDetails(String id) async {
    try {
      final response = await getHttp(Endpoints.staffDayOffRequest(id));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> updateDayOffRequest(String id, String date, String reason) async {
    try {
      final response = await patchHttp(Endpoints.staffDayOffRequest(id), {
        'date': date,
        'reason': reason,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> deleteDayOffRequest(String id) async {
    try {
      final response = await deleteHttp(Endpoints.staffDayOffRequest(id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getStaffNotifications() async {
    try {
      final response = await getHttp(Endpoints.staffNotifications());
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['results'] != null) {
          return response.data['results'];
        }
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getStaffNotificationDetails(String id) async {
    try {
      final response = await getHttp(Endpoints.staffNotification(id));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> deleteStaffNotification(String id) async {
    try {
      final response = await deleteHttp(Endpoints.staffNotification(id));
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getStoreStaff(String storeId) async {
    try {
      final response = await getHttp(Endpoints.viewStoreStaff(storeId));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<StaffChatMessage>> getStaffChat() async {
    try {
      final response = await getHttp(Endpoints.staffChat());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic rawData = response.data;
        List<dynamic> list = [];
        if (rawData is Map && rawData['results'] is List) {
          list = rawData['results'];
        } else if (rawData is List) {
          list = rawData;
        }
        return list.map((json) => StaffChatMessage.fromJson(json)).toList();
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<StaffChatMessage> sendStaffChatMessage(String message) async {
    try {
      final response = await postHttp(Endpoints.staffChat(), {
        "message": message,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StaffChatMessage.fromJson(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}

