import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import '../../../../networks/rx_base.dart';
import '../model/staff_dashboard_model.dart';
import '../model/get_staff_history_model.dart';
import '../model/staff_chat_model.dart';
import 'api.dart';

class GetStaffDashboardRx extends RxResponseInt<StaffDashboardModel> {
  final api = StaffDashboardApi.instance;

  GetStaffDashboardRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<StaffDashboardModel> get valueStreamData => dataFetcher.stream;

  Future<void> fetchDashboardData() async {
    try {
      final data = await api.fetchDashboard();
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch dashboard error: $error");
      handleErrorWithReturn(error);
    }
  }
}

class GetStaffHistoryRx extends RxResponseInt<GetStaffHistoryModel> {
  final api = StaffDashboardApi.instance;

  GetStaffHistoryRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<GetStaffHistoryModel> get valueStreamData => dataFetcher.stream;

  Future<void> fetchHistoryData() async {
    try {
      final data = await api.fetchShiftHistory();
      handleSuccessWithReturn(data);
    } catch (error) {
      log("History fetch error: $error");
      handleErrorWithReturn(error);
    }
  }
}

class UpdateStaffProfileRx extends RxResponseInt<dynamic> {
  final api = StaffDashboardApi.instance;

  UpdateStaffProfileRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<dynamic> get valueStreamData => dataFetcher.stream;

  Future<void> fetchStaffProfile() async {
    try {
      final data = await api.getStaffProfile();
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch staff profile error: $error");
      handleErrorWithReturn(error);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? password,
    String? photoPath,
  }) async {
    try {
      final data = await api.updateStaffProfile(
        name: name,
        phone: phone,
        password: password,
        photoPath: photoPath,
      );
      handleSuccessWithReturn(data);
      return true;
    } catch (error) {
      log("Update Profile fetch error: $error");
      handleErrorWithReturn(error);
      return false;
    }
  }
}

class StaffCheckInOutRx extends RxResponseInt<dynamic> {
  final api = StaffDashboardApi.instance;
  StaffCheckInOutRx({required super.empty, required super.dataFetcher});

  Future<bool> checkIn(int storeId, String storeCode) async {
    try {
      final data = await api.checkIn(storeId, storeCode);
      handleSuccessWithReturn(data);
      return true;
    } catch (error) {
      log("Check-in error: $error");
      EasyLoading.dismiss();
      String customError = "Store is already closed.";
      if (error is DioException) {
        final res = error.response?.data;
        if (res is Map) {
          final msg = res['message'] ??
              res['detail'] ??
              res['error'] ??
              res['msg'] ??
              (res['non_field_errors'] is List && (res['non_field_errors'] as List).isNotEmpty
                  ? res['non_field_errors'][0].toString()
                  : null);
          if (msg != null && msg.toString().isNotEmpty && !msg.toString().toLowerCase().contains("bad request")) {
            customError = msg.toString();
          } else {
            customError = "Store is already closed.";
          }
        } else if (res is String && res.isNotEmpty && !res.toLowerCase().contains("bad request")) {
          customError = res;
        }
      }
      AppToast.error(customError);
      return false;
    }
  }

  Future<bool> checkOut(Map<String, dynamic> shiftData) async {
    try {
      final data = await api.checkOut(shiftData);
      handleSuccessWithReturn(data);
      return true;
    } catch (error) {
      log("Check-out error: $error");
      handleErrorWithReturn(error);
      return false;
    }
  }
}

class StaffTasksRx extends RxResponseInt<dynamic> {
  final api = StaffDashboardApi.instance;
  StaffTasksRx({required super.empty, required super.dataFetcher});

  ValueStream<dynamic> get valueStreamData => dataFetcher.stream;

  Future<void> fetchTasks({String? date}) async {
    try {
      final data = await api.getTasks(date: date);
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch tasks error: $error");
      handleErrorWithReturn(error);
    }
  }

  Future<bool> markTaskCompleted(String taskId) async {
    try {
      await api.updateTask(taskId, "COMPLETED");
      return true;
    } catch (error) {
      log("Complete task error: $error");
      handleErrorWithReturn(error);
      return false;
    }
  }
}

class StaffColleaguesRx extends RxResponseInt<dynamic> {
  final api = StaffDashboardApi.instance;
  StaffColleaguesRx({required super.empty, required super.dataFetcher});

  ValueStream<dynamic> get valueStreamData => dataFetcher.stream;

  Future<void> fetchColleagues() async {
    try {
      final data = await api.getColleagues();
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch colleagues error: $error");
      handleErrorWithReturn(error);
    }
  }
}

class StaffOrderHistoryRx extends RxResponseInt<dynamic> {
  final api = StaffDashboardApi.instance;
  StaffOrderHistoryRx({required super.empty, required super.dataFetcher});

  ValueStream<dynamic> get valueStreamData => dataFetcher.stream;

  Future<void> fetchOrderHistory() async {
    try {
      final data = await api.getOrderHistory();
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch orders error: $error");
      handleErrorWithReturn(error);
    }
  }
}

class StaffDayOffRequestsRx extends RxResponseInt<dynamic> {
  final api = StaffDashboardApi.instance;
  StaffDayOffRequestsRx({required super.empty, required super.dataFetcher});

  ValueStream<dynamic> get valueStreamData => dataFetcher.stream;

  Future<void> fetchDayOffRequests() async {
    try {
      final data = await api.getDayOffRequests();
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data['results'] is List) {
          list = data['results'];
        } else if (data['data'] is List) {
          list = data['data'];
        }
      }
      handleSuccessWithReturn(list);
    } catch (error) {
      log("Fetch day off requests error: $error");
      handleErrorWithReturn(error);
    }
  }

  Future<bool> createRequest(String date, String reason) async {
    try {
      await EasyLoading.show(status: 'Submitting request...');
      await api.createDayOffRequest(date, reason);
      EasyLoading.showSuccess('Request submitted successfully');
      await fetchDayOffRequests();
      return true;
    } catch (error) {
      log("Create day off request error: $error");
      String msg = 'Failed to submit request';
      if (error is DioException && error.response?.data != null) {
        final d = error.response!.data;
        if (d is Map && d['message'] != null) {
          msg = d['message'].toString();
        } else if (d is Map && d['detail'] != null) {
          msg = d['detail'].toString();
        }
      }
      EasyLoading.showError(msg);
      return false;
    }
  }

  Future<void> fetchRequestDetails(String id) async {
    try {
      final data = await api.getDayOffRequestDetails(id);
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch day off request details error: $error");
      handleErrorWithReturn(error);
    }
  }

  Future<bool> updateRequest(String id, String date, String reason) async {
    try {
      await EasyLoading.show(status: 'Updating request...');
      await api.updateDayOffRequest(id, date, reason);
      EasyLoading.showSuccess('Request updated successfully');
      await fetchDayOffRequests();
      return true;
    } catch (error) {
      log("Update day off request error: $error");
      EasyLoading.showError('Failed to update request');
      return false;
    }
  }

  Future<bool> deleteRequest(String id) async {
    try {
      await EasyLoading.show(status: 'Cancelling request...');
      await api.deleteDayOffRequest(id);
      EasyLoading.showSuccess('Request cancelled');
      await fetchDayOffRequests();
      return true;
    } catch (error) {
      log("Delete day off request error: $error");
      EasyLoading.showError('Failed to cancel request');
      return false;
    }
  }
}

class StaffNotificationsRx extends RxResponseInt<dynamic> {
  final api = StaffDashboardApi.instance;
  StaffNotificationsRx({required super.empty, required super.dataFetcher});

  ValueStream<dynamic> get valueStreamData => dataFetcher.stream;

  Future<void> fetchNotifications() async {
    try {
      final data = await api.getStaffNotifications();
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch staff notifications error: $error");
      handleErrorWithReturn(error);
    }
  }

  Future<void> fetchNotificationDetails(String id) async {
    try {
      final data = await api.getStaffNotificationDetails(id);
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch staff notification details error: $error");
      handleErrorWithReturn(error);
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      await api.deleteStaffNotification(id);
      return true;
    } catch (error) {
      log("Delete staff notification error: $error");
      handleErrorWithReturn(error);
      return false;
    }
  }
}

class StoreStaffRx extends RxResponseInt<dynamic> {
  final api = StaffDashboardApi.instance;
  StoreStaffRx({required super.empty, required super.dataFetcher});

  ValueStream<dynamic> get valueStreamData => dataFetcher.stream;

  Future<void> fetchStoreStaff(String storeId) async {
    try {
      final data = await api.getStoreStaff(storeId);
      handleSuccessWithReturn(data);
    } catch (error) {
      log("Fetch store staff error: $error");
      handleErrorWithReturn(error);
    }
  }
}

class StaffChatRx extends RxResponseInt<List<StaffChatMessage>> {
  final api = StaffDashboardApi.instance;

  StaffChatRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<List<StaffChatMessage>> get valueStreamData => dataFetcher.stream;

  Future<void> fetchChatMessages({bool silent = false}) async {
    try {
      final data = await api.getStaffChat();
      if (!dataFetcher.isClosed) {
        dataFetcher.sink.add(data);
      }
    } catch (error) {
      log("Fetch staff chat messages error: $error");
      if (!silent) {
        handleErrorWithReturn(error);
      }
    }
  }

  Future<bool> sendMessage(String message) async {
    try {
      final sentMessage = await api.sendStaffChatMessage(message);
      
      // Update local stream to show sent message instantly
      final currentList = dataFetcher.hasValue ? (dataFetcher.value ?? []) : <StaffChatMessage>[];
      final newList = List<StaffChatMessage>.from(currentList)..add(sentMessage);
      if (!dataFetcher.isClosed) {
        dataFetcher.sink.add(newList);
      }
      
      return true;
    } catch (error) {
      log("Send staff chat message error: $error");
      return false;
    }
  }
}

