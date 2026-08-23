import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../networks/rx_base.dart';
import '../../../../../common_wigdets/app_toast.dart';
import 'customer_tickets_api.dart';
import 'dart:developer';

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
      } else if (data is Map && data.containsKey('results')) {
        list = data['results'];
      }
      await handleSuccessWithReturn(list);
    } catch (e) {
      log('CustomerTicketsRx fetchTickets error: $e');
      await handleErrorWithReturn(e);
    }
  }

  Future<bool> createTicket(String subject, String description, {String category = 'GENERAL', String priority = 'LOW'}) async {
    try {
      await EasyLoading.show(status: 'Creating Ticket...');
      await api.createTicket({
        "subject": subject, 
        "description": description,
        "category": category,
        "priority": priority,
      });
      AppToast.success("Ticket Created Successfully!");
      fetchTickets();
      return true;
    } catch (e) {
      log('CustomerTicketsRx createTicket error: $e');
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
