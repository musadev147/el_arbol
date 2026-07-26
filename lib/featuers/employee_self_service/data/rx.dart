import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import '../../../../networks/rx_base.dart';
import '../model/staff_dashboard_model.dart';
import '../model/get_staff_history_model.dart';
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
      log("Dashboard fetch error: $error");
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

  Future<bool> checkIn(int storeId) async {
    try {
      final data = await api.checkIn(storeId);
      handleSuccessWithReturn(data);
      return true;
    } catch (error) {
      log("Check-in error: $error");
      handleErrorWithReturn(error);
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
