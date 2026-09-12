import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import 'customer_tickets_api.dart';
import 'dart:developer';
import '../../../../../helpers/support_ticket_unread_manager.dart';

class CustomerTicketsRx extends RxResponseInt<List<dynamic>> {
  final api = CustomerTicketsApi.instance;

  CustomerTicketsRx({required super.empty, required super.dataFetcher});

  ValueStream get valueStreamData => dataFetcher.stream;

  Future<void> fetchTickets() async {
    try {
      final data = await api.getTickets();
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data['results'] is List) {
          list = data['results'];
        } else if (data['data'] is List) {
          list = data['data'];
        } else if (data['tickets'] is List) {
          list = data['tickets'];
        }
      }
      SupportTicketUnreadManager.instance.updateCustomerTickets(list);
      await handleSuccessWithReturn(list);
    } catch (e) {
      log('CustomerTicketsRx fetchTickets error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> createTicket(String subject, String description, {String category = 'ORDER', String priority = 'HIGH'}) async {
    try {
      await EasyLoading.show(status: 'Creating Ticket...');
      final payload = {
        "subject": subject.trim(),
        "title": subject.trim(),
        "description": description.trim(),
        "message": description.trim(),
        "category": category,
        "priority": priority,
      };
      await api.createTicket(payload);
      AppToast.success("Ticket Created Successfully!");
      await fetchTickets();
      return true;
    } catch (e) {
      log('CustomerTicketsRx createTicket error: $e');
      String message = "Failed to create ticket";
      if (e is DioException && e.response?.data != null) {
        if (e.response?.data is Map) {
          final map = e.response!.data as Map;
          message = map["message"]?.toString() ?? 
                    map["detail"]?.toString() ?? 
                    map["error"]?.toString() ?? 
                    (map.values.isNotEmpty ? map.values.first.toString() : message);
        } else if (e.response?.data is String) {
          message = e.response!.data.toString();
        }
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> deleteTicket(String ticketId) async {
    try {
      await EasyLoading.show(status: 'Deleting Ticket...');
      await api.deleteTicket(ticketId);
      AppToast.success("Ticket deleted successfully!");
      await fetchTickets();
      return true;
    } catch (e) {
      log('CustomerTicketsRx deleteTicket error: $e');
      String message = "Failed to delete ticket";
      if (e is DioException && e.response?.data is Map) {
        final map = e.response!.data as Map;
        message = map["message"]?.toString() ?? map["detail"]?.toString() ?? message;
      }
      AppToast.error(message);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<Map<String, dynamic>?> replyTicket(String ticketId, String messageStr) async {
    try {
      final data = await api.replyTicket(ticketId, {"message": messageStr});
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      log('CustomerTicketsRx replyTicket error: $e');
      AppToast.error("Failed to send message");
      return null;
    }
  }

  Future<bool> updateMessage(String ticketId, String messageId, String newMessage) async {
    try {
      await api.updateMessage(ticketId, messageId, {"message": newMessage});
      return true;
    } catch (e) {
      log('CustomerTicketsRx updateMessage error: $e');
      AppToast.error("Failed to update message");
      return false;
    }
  }

  Future<bool> deleteMessage(String ticketId, String messageId) async {
    try {
      await EasyLoading.show(status: 'Deleting...');
      await api.deleteMessage(ticketId, messageId);
      AppToast.success("Message deleted!");
      fetchTickets();
      return true;
    } catch (e) {
      log('CustomerTicketsRx deleteMessage error: $e');
      AppToast.error("Failed to delete message");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> sendTypingIndicator(String ticketId, bool isTyping) async {
    try {
      await api.sendTypingIndicator(ticketId, {"is_typing": isTyping});
      return true;
    } catch (e) {
      log('CustomerTicketsRx typing indicator error: $e');
      return false;
    }
  }

  @override
  Future<void> handleSuccessWithReturn(dynamic data) async {
    dataFetcher.sink.add(data is List ? data : []);
  }

  @override
  Future<void> handleErrorWithReturn(dynamic error) async {
    dataFetcher.sink.addError(error);
  }
}
