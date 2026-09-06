import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:el_arbol/networks/dio/dio.dart';
import 'package:el_arbol/networks/endpoints.dart';
import 'package:el_arbol/networks/exception_handler/data_source.dart';

class WholesaleApi {
  static final WholesaleApi _singleton = WholesaleApi._internal();
  WholesaleApi._internal();
  static WholesaleApi get instance => _singleton;

  // PROFILE APIs
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await getHttp(Endpoints.wholesaleProfile());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale getProfile error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await DioSingleton.instance.dio.patch(
        Endpoints.wholesaleProfile(),
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale updateProfile error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfileImage(FormData formData) async {
    try {
      final response = await patchHttp(
        Endpoints.wholesaleProfileImage(),
        formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale updateProfileImage error: $e');
      rethrow;
    }
  }

  Future<dynamic> createProduct(dynamic payload) async {
    try {
      final response = await postHttp(Endpoints.getProducts(), payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale createProduct error: $e');
      rethrow;
    }
  }

  Future<dynamic> createOrder(Map<String, dynamic> payload) async {
    try {
      final response = await postHttp(Endpoints.createOrder(), payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale createOrder error: $e');
      rethrow;
    }
  }

  // AUTH APIs
  Future<void> passwordResetSendOtp(String email) async {
    try {
      final response = await postHttp(
        Endpoints.wholesalePasswordResetSendOtp(),
        {
          "email": email,
          "type": "WHOLESALE",
        },
      );
      if (response.statusCode != 200) {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale passwordResetSendOtp error: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await postHttp(
        Endpoints.wholesaleChangePassword(),
        {
          "old_password": oldPassword,
          "new_password": newPassword,
        },
      );
      if (response.statusCode != 200) {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale changePassword error: $e');
      rethrow;
    }
  }

  Future<void> passwordResetVerify(String email, String otp, String newPassword) async {
    try {
      final response = await postHttp(
        Endpoints.wholesalePasswordResetVerify(),
        {
          "email": email,
          "otp": otp,
          "password": newPassword,
        },
      );
      if (response.statusCode != 200) {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale passwordResetVerify error: $e');
      rethrow;
    }
  }

  // TICKETS APIs
  Future<Map<String, dynamic>> getTickets() async {
    try {
      final response = await getHttp(Endpoints.wholesaleTickets());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale getTickets error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTicket(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.wholesaleTickets(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map<String, dynamic> ? response.data : Map<String, dynamic>.from(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale createTicket error: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteTicket(String id) async {
    try {
      final response = await deleteHttp(Endpoints.wholesaleSingleTicket(id));
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale deleteTicket error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSingleTicket(String id) async {
    try {
      final response = await getHttp(Endpoints.wholesaleSingleTicket(id));
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic> ? response.data : Map<String, dynamic>.from(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale getSingleTicket fallback attempt for ticket $id: $e');
      try {
        final fallbackRes = await getHttp("auth/tickets/$id/");
        if (fallbackRes.statusCode == 200) {
          return fallbackRes.data is Map<String, dynamic> ? fallbackRes.data : Map<String, dynamic>.from(fallbackRes.data);
        }
      } catch (_) {}
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTicketReply(String id, String message) async {
    try {
      final response = await postHttp(
        Endpoints.wholesaleTicketReply(id),
        {"message": message},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map<String, dynamic> ? response.data : Map<String, dynamic>.from(response.data);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale createTicketReply error, trying fallback: $e');
      try {
        final fallbackRes = await postHttp(
          Endpoints.customerTicketReply(id),
          {"message": message},
        );
        if (fallbackRes.statusCode == 200 || fallbackRes.statusCode == 201) {
          return fallbackRes.data is Map<String, dynamic> ? fallbackRes.data : Map<String, dynamic>.from(fallbackRes.data);
        }
      } catch (_) {}
      rethrow;
    }
  }

  // NOTIFICATIONS APIs
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await getHttp(Endpoints.wholesaleNotifications());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale getNotifications error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getNotificationUnreadCount() async {
    try {
      final response = await getHttp(Endpoints.wholesaleNotificationUnreadCount());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale getNotificationUnreadCount error: $e');
      rethrow;
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      final response = await postHttp(
        Endpoints.wholesaleNotificationMarkRead(),
        {"notification_id": id},
      );
      if (response.statusCode != 200) {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale markNotificationRead error: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await deleteHttp(Endpoints.wholesaleNotificationDelete(id));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale deleteNotification error: $e');
      rethrow;
    }
  }

  // DAILY REPORTS APIs
  Future<dynamic> getDailyReports() async {
    try {
      final response = await getHttp(Endpoints.wholesaleDailyReports());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale getDailyReports error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitDailyReport(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.wholesaleDailyReports(), data);
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale submitDailyReport error: $e');
      rethrow;
    }
  }

  Future<void> sendTicketTyping(String id, bool isTyping) async {
    try {
      final response = await postHttp(
        Endpoints.wholesaleTicketTyping(id),
        {"is_typing": isTyping},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale sendTicketTyping error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWholesaleStatus() async {
    try {
      final response = await getHttp(Endpoints.wholesaleStatus());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale getWholesaleStatus error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWholesaleContent() async {
    try {
      final response = await getHttp(Endpoints.wholesaleContent());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      log('Wholesale getWholesaleContent error: $e');
      rethrow;
    }
  }
}
