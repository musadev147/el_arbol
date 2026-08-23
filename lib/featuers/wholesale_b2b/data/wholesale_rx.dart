import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_api.dart';
import 'package:el_arbol/networks/rx_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dio/dio.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import 'dart:developer';
import 'dart:io';

class WholesaleProfileRx extends RxResponseInt<Map<String, dynamic>> {
  final api = WholesaleApi.instance;

  WholesaleProfileRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchProfile() async {
    try {
      final data = await api.getProfile();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('WholesaleProfileRx fetchProfile error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    try {
      await EasyLoading.show(status: 'Updating Profile...');
      final data = await api.updateProfile(payload);
      dataFetcher.sink.add(data); // update the stream with new data
      AppToast.success("Profile Updated Successfully!");
      return true;
    } catch (e) {
      log('WholesaleProfileRx updateProfile error: $e');
      String message = "Failed to update profile";
      if (e is DioException) {
        message = e.response?.data["message"] ?? message;
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> updateAvatar(File image) async {
    try {
      await EasyLoading.show(status: 'Uploading Image...');
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(image.path, filename: fileName),
      });
      await api.updateProfileImage(formData);
      AppToast.success("Avatar Updated Successfully!");
      fetchProfile();
      return true;
    } catch (e) {
      log('WholesaleProfileRx updateAvatar error: $e');
      String message = "Failed to upload image";
      if (e is DioException) {
        if (e.response?.data is Map) {
          message = e.response?.data["message"] ?? message;
        }
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(Map<String, dynamic> data) async {
    dataFetcher.sink.add(data);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}

class WholesaleChangePasswordRx extends RxResponseInt<void> {
  final api = WholesaleApi.instance;

  WholesaleChangePasswordRx({required super.empty, required super.dataFetcher});

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await EasyLoading.show(status: 'Updating Password...');
      await api.changePassword(oldPassword, newPassword);
      await handleSuccessWithReturn(null);
    } catch (e) {
      log('WholesaleChangePasswordRx error: $e');
      await handleErrorWithReturn(e);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(void data) async {
    AppToast.success("Password Changed Successfully!");
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    String message = "Failed to change password";
    if (error is DioException) {
      if (error.response?.data is Map) {
        message = error.response?.data["message"] ?? message;
      }
    }
    AppToast.error(message);
  }
}

class WholesalePasswordResetSendOtpRx extends RxResponseInt<void> {
  final api = WholesaleApi.instance;

  WholesalePasswordResetSendOtpRx({required super.empty, required super.dataFetcher});

  Future<bool> sendOtp(String email) async {
    try {
      await EasyLoading.show(status: 'Sending OTP...');
      await api.passwordResetSendOtp(email);
      await handleSuccessWithReturn(null);
      return true;
    } catch (e) {
      log('WholesalePasswordResetSendOtpRx error: $e');
      await handleErrorWithReturn(e);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(void data) async {
    AppToast.success("OTP Sent to Email Successfully!");
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    String message = "Failed to send OTP";
    if (error is DioException) {
      if (error.response?.data is Map) {
        message = error.response?.data["message"] ?? message;
      }
    }
    AppToast.error(message);
  }
}

class WholesalePasswordResetVerifyRx extends RxResponseInt<void> {
  final api = WholesaleApi.instance;

  WholesalePasswordResetVerifyRx({required super.empty, required super.dataFetcher});

  Future<bool> verifyOtpAndReset(String email, String otp, String newPassword) async {
    try {
      await EasyLoading.show(status: 'Resetting Password...');
      await api.passwordResetVerify(email, otp, newPassword);
      await handleSuccessWithReturn(null);
      return true;
    } catch (e) {
      log('WholesalePasswordResetVerifyRx error: $e');
      await handleErrorWithReturn(e);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(void data) async {
    AppToast.success("Password Reset Successfully!");
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    String message = "Failed to reset password";
    if (error is DioException) {
      if (error.response?.data is Map) {
        message = error.response?.data["message"] ?? message;
      }
    }
    AppToast.error(message);
  }
}

class WholesaleTicketsRx extends RxResponseInt<Map<String, dynamic>> {
  final api = WholesaleApi.instance;

  WholesaleTicketsRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchTickets() async {
    try {
      final data = await api.getTickets();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('WholesaleTicketsRx fetchTickets error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> createTicket(Map<String, dynamic> payload) async {
    try {
      await EasyLoading.show(status: 'Creating Ticket...');
      final data = await api.createTicket(payload);
      // Optional: you can fetch again or append to stream, but for now we just return true.
      AppToast.success("Ticket Created Successfully!");
      fetchTickets();
      return true;
    } catch (e) {
      log('WholesaleTicketsRx createTicket error: $e');
      String message = "Failed to create ticket";
      if (e is DioException) {
        if (e.response?.data is Map) {
          message = e.response?.data["message"] ?? message;
        }
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(Map<String, dynamic> data) async {
    dataFetcher.sink.add(data);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}

class WholesaleSingleTicketRx extends RxResponseInt<Map<String, dynamic>> {
  final api = WholesaleApi.instance;

  WholesaleSingleTicketRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchSingleTicket(String id) async {
    try {
      final data = await api.getSingleTicket(id);
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('WholesaleSingleTicketRx fetchSingleTicket error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> replyToTicket(String id, String message) async {
    try {
      await EasyLoading.show(status: 'Sending Reply...');
      await api.createTicketReply(id, message);
      AppToast.success("Reply Sent Successfully!");
      fetchSingleTicket(id); // refetch
      return true;
    } catch (e) {
      log('WholesaleSingleTicketRx replyToTicket error: $e');
      String errorMsg = "Failed to send reply";
      if (e is DioException) {
        if (e.response?.data is Map) {
          errorMsg = e.response?.data["message"] ?? errorMsg;
        }
      }
      AppToast.error(errorMsg);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(Map<String, dynamic> data) async {
    dataFetcher.sink.add(data);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}

class WholesaleNotificationsRx extends RxResponseInt<Map<String, dynamic>> {
  final api = WholesaleApi.instance;

  WholesaleNotificationsRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchNotifications() async {
    try {
      final data = await api.getNotifications();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('WholesaleNotificationsRx fetchNotifications error: $e');
      await handleErrorWithReturn(e);
    }
  }

  @override
  Future<void> handleSuccessWithReturn(Map<String, dynamic> data) async {
    dataFetcher.sink.add(data);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}

class WholesaleDailyReportsRx extends RxResponseInt<dynamic> {
  final api = WholesaleApi.instance;

  WholesaleDailyReportsRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchDailyReports() async {
    try {
      final data = await api.getDailyReports();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('WholesaleDailyReportsRx fetchDailyReports error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> submitReport(Map<String, dynamic> payload) async {
    try {
      await EasyLoading.show(status: 'Submitting Report...');
      final data = await api.submitDailyReport(payload);
      AppToast.success("Daily Report Submitted Successfully!");
      fetchDailyReports();
      return true;
    } catch (e) {
      log('WholesaleDailyReportsRx submitReport error: $e');
      String message = "Failed to submit report";
      if (e is DioException) {
        if (e.response?.data is Map) {
          message = e.response?.data["message"] ?? message;
        }
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Future<void> handleSuccessWithReturn(dynamic data) async {
    dataFetcher.sink.add(data);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}

class WholesaleCreateProductRx extends RxResponseInt<void> {
  final api = WholesaleApi.instance;
  WholesaleCreateProductRx({required super.empty, required super.dataFetcher});

  @override
  Future<void> handleSuccessWithReturn(dynamic data) async {
    return;
  }

  Future<bool> createProduct(Map<String, dynamic> payload) async {
    try {
      await EasyLoading.show(status: 'Creating Product...');
      await api.createProduct(payload);
      AppToast.success("Product Created Successfully!");
      return true;
    } catch (e) {
      log('WholesaleCreateProductRx createProduct error: $e');
      String message = "Failed to create product";
      if (e is DioException) {
        if (e.response?.data is Map) {
          message = e.response?.data["message"] ?? message;
        }
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}

class WholesaleTicketTypingRx {
  final api = WholesaleApi.instance;

  Future<bool> sendTyping(String id, bool isTyping) async {
    try {
      await api.sendTicketTyping(id, isTyping);
      return true;
    } catch (e) {
      log('WholesaleTicketTypingRx sendTyping error: $e');
      return false;
    }
  }
}

class WholesaleStatusRx extends RxResponseInt<Map<String, dynamic>> {
  final api = WholesaleApi.instance;
  WholesaleStatusRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchStatus() async {
    try {
      final data = await api.getWholesaleStatus();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('WholesaleStatusRx fetchStatus error: $e');
      await handleErrorWithReturn(e);
    }
  }

  @override
  Future<void> handleSuccessWithReturn(Map<String, dynamic> data) async {
    dataFetcher.sink.add(data);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}

class WholesaleContentRx extends RxResponseInt<Map<String, dynamic>> {
  final api = WholesaleApi.instance;
  WholesaleContentRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchContent() async {
    try {
      final data = await api.getWholesaleContent();
      await handleSuccessWithReturn(data);
    } catch (e) {
      log('WholesaleContentRx fetchContent error: $e');
      await handleErrorWithReturn(e);
    }
  }

  @override
  Future<void> handleSuccessWithReturn(Map<String, dynamic> data) async {
    dataFetcher.sink.add(data);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}
