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
      final response = await getHttp(Endpoints.staffDashboard());
      if (response.statusCode == 200) {
        final profileData = response.data['profile'];
        if (profileData != null) {
          final userData = profileData['user'];
          return {
            'name': userData?['name'],
            'email': userData?['email'],
            'phone': profileData['phone'] ?? userData?['phone'],
            'photo': profileData['photo'],
            'staff_id': profileData['staff_id'],
          };
        }
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

  Future<dynamic> checkIn(int storeId, String storeCode) async {
    try {
      final response = await postHttp(Endpoints.staffCheckIn(), {
        'store_id': storeId,
        'store_code': storeCode,
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
      final List<dynamic> allOrders = [];
      try {
        final staffOrdersRes = await getHttp(Endpoints.staffOrderHistory());
        if (staffOrdersRes.statusCode == 200 && staffOrdersRes.data != null) {
          final sData = staffOrdersRes.data;
          if (sData is Map && sData['results'] is List) {
            allOrders.addAll(sData['results']);
          } else if (sData is List) {
            allOrders.addAll(sData);
          }
        }
      } catch (e) {
        log("Staff orders fetch fallback: $e");
      }

      try {
        final custOrdersRes = await getHttp(Endpoints.customerOrders());
        if (custOrdersRes.statusCode == 200 && custOrdersRes.data != null) {
          final cData = custOrdersRes.data;
          if (cData is Map && cData['results'] is List) {
            allOrders.addAll(cData['results']);
          } else if (cData is List) {
            allOrders.addAll(cData);
          }
        }
      } catch (e) {
        log("Customer orders fetch fallback: $e");
      }

      final seenIds = <String>{};
      final uniqueOrders = <dynamic>[];
      for (final order in allOrders) {
        if (order is Map) {
          final id = order['order_number']?.toString() ?? order['id']?.toString() ?? order.hashCode.toString();
          if (!seenIds.contains(id)) {
            seenIds.add(id);
            uniqueOrders.add(order);
          }
        } else {
          uniqueOrders.add(order);
        }
      }

      return uniqueOrders;
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
      log("GET STAFF CHAT RESPONSE: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic rawData = response.data;
        List<dynamic> list = [];
        if (rawData is Map) {
          if (rawData['results'] is List) {
            list = rawData['results'];
          } else if (rawData['data'] is List) {
            list = rawData['data'];
          } else if (rawData['messages'] is List) {
            list = rawData['messages'];
          } else if (rawData['chats'] is List) {
            list = rawData['chats'];
          } else if (rawData['result'] is List) {
            list = rawData['result'];
          }
        } else if (rawData is List) {
          list = rawData;
        }
        return list.map((json) => StaffChatMessage.fromJson(Map<String, dynamic>.from(json))).toList();
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
      log("SEND STAFF CHAT RESPONSE: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map<String, dynamic>) {
          if (resData['data'] is Map<String, dynamic>) {
            return StaffChatMessage.fromJson(resData['data']);
          } else if (resData['result'] is Map<String, dynamic>) {
            return StaffChatMessage.fromJson(resData['result']);
          } else if (resData['message_object'] is Map<String, dynamic>) {
            return StaffChatMessage.fromJson(resData['message_object']);
          }
          return StaffChatMessage.fromJson(resData);
        } else if (resData is Map) {
          return StaffChatMessage.fromJson(Map<String, dynamic>.from(resData));
        }
        return StaffChatMessage(
          message: message,
          sender: 'STAFF',
          createdAt: DateTime.now().toIso8601String(),
        );
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}

