import 'dart:developer';
import 'dart:convert';
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

  Future<bool> deleteOrder(String id) async {
    final cleanId = id.replaceAll('#', '').trim();
    if (cleanId.isEmpty) return false;

    try {
      final response = await deleteHttp(Endpoints.customerOrderDetails(cleanId));
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        return true;
      }
    } catch (_) {
      try {
        final res2 = await deleteHttp("staff/me/orders/$cleanId/");
        if (res2.statusCode == 200 || res2.statusCode == 204 || res2.statusCode == 201) {
          return true;
        }
      } catch (_) {
        try {
          final res3 = await deleteHttp("auth/orders/$cleanId/");
          if (res3.statusCode == 200 || res3.statusCode == 204 || res3.statusCode == 201) {
            return true;
          }
        } catch (_) {}
      }
    }
    return true;
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

  Future<bool> bulkDeleteStaffNotifications(List<String> ids) async {
    bool allSuccess = true;
    for (final id in ids) {
      try {
        await deleteStaffNotification(id);
      } catch (e) {
        allSuccess = false;
      }
    }
    return allSuccess;
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

  Future<List<StaffChatMessage>> getStaffChat({bool fetchAll = true, bool lastPageOnly = false}) async {
    try {
      final endpoint = lastPageOnly 
          ? '${Endpoints.staffChat()}?page=last' 
          : Endpoints.staffChat();
      
      final response = await getHttp(endpoint);
      log("GET STAFF CHAT RESPONSE: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic rawData = response.data;
        if (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }
        List<dynamic> list = [];
        int count = 0;
        if (rawData is Map) {
          count = rawData['count'] is int
              ? rawData['count']
              : int.tryParse(rawData['count']?.toString() ?? '0') ?? 0;
          if (rawData['results'] is List) {
            list = List.from(rawData['results']);
          } else if (rawData['data'] is List) {
            list = List.from(rawData['data']);
          } else if (rawData['messages'] is List) {
            list = List.from(rawData['messages']);
          } else if (rawData['chats'] is List) {
            list = List.from(rawData['chats']);
          } else if (rawData['result'] is List) {
            list = List.from(rawData['result']);
          }
        } else if (rawData is List) {
          list = List.from(rawData);
          count = list.length;
        }

        // If fetchAll is true and there are multiple pages (DRF page size = 20), fetch remaining pages in parallel
        if (fetchAll && !lastPageOnly && count > 20) {
          final totalPages = (count + 19) ~/ 20;
          final futurePages = <Future<Response<dynamic>?>>[];
          for (int p = 2; p <= totalPages; p++) {
            futurePages.add(() async {
              try {
                return await getHttp('${Endpoints.staffChat()}?page=$p');
              } catch (e) {
                log("Error fetching staff chat page $p: $e");
                return null;
              }
            }());
          }
          final pageResponses = await Future.wait(futurePages);
          for (var pageRes in pageResponses) {
            if (pageRes != null && (pageRes.statusCode == 200 || pageRes.statusCode == 201)) {
              dynamic pData = pageRes.data;
              if (pData is String) {
                try {
                  pData = jsonDecode(pData);
                } catch (_) {}
              }
              if (pData is Map && pData['results'] is List) {
                list.addAll(pData['results']);
              }
            }
          }
        }

        final parsed = <StaffChatMessage>[];
        final seenIds = <int>{};
        for (var item in list) {
          try {
            if (item is Map) {
              final msg = StaffChatMessage.fromJson(Map<String, dynamic>.from(item));
              if (msg.id != null) {
                if (seenIds.contains(msg.id)) continue;
                seenIds.add(msg.id!);
              }
              parsed.add(msg);
            }
          } catch (e) {
            log("Error parsing chat item: $e");
          }
        }
        parsed.sort((a, b) {
          if (a.createdAt != null && b.createdAt != null) {
            return a.createdAt!.compareTo(b.createdAt!);
          }
          return (a.id ?? 0).compareTo(b.id ?? 0);
        });
        return parsed;
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
        dynamic resData = response.data;
        if (resData is String) {
          try {
            resData = jsonDecode(resData);
          } catch (_) {}
        }
        if (resData is Map) {
          final map = Map<String, dynamic>.from(resData);
          if (map['data'] is Map) {
            return StaffChatMessage.fromJson(Map<String, dynamic>.from(map['data']));
          } else if (map['result'] is Map) {
            return StaffChatMessage.fromJson(Map<String, dynamic>.from(map['result']));
          } else if (map['message_object'] is Map) {
            return StaffChatMessage.fromJson(Map<String, dynamic>.from(map['message_object']));
          }
          return StaffChatMessage.fromJson(map);
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

