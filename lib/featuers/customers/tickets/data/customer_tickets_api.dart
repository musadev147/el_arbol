import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/endpoints.dart';
import '../../../../../networks/exception_handler/data_source.dart';

class CustomerTicketsApi {
  static final CustomerTicketsApi _singleton = CustomerTicketsApi._internal();
  CustomerTicketsApi._internal();
  static CustomerTicketsApi get instance => _singleton;

  Future<dynamic> getTickets() async {
    try {
      final response = await getHttp(Endpoints.customerTickets());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createTicket(Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.customerTickets(), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> replyTicket(String ticketId, Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.customerTicketReply(ticketId), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateMessage(String ticketId, String messageId, Map<String, dynamic> data) async {
    try {
      final response = await patchHttp(Endpoints.customerTicketMessage(ticketId, messageId), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteMessage(String ticketId, String messageId) async {
    try {
      final response = await deleteHttp(Endpoints.customerTicketMessage(ticketId, messageId));
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> sendTypingIndicator(String ticketId, Map<String, dynamic> data) async {
    try {
      final response = await postHttp(Endpoints.customerTicketTyping(ticketId), data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (e) {
      rethrow;
    }
  }
}
