import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:el_arbol/helpers/di.dart';
import 'package:el_arbol/constants/app_constants.dart';
import '../data/customer_tickets_rx.dart';

class CustomerTicketChatScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const CustomerTicketChatScreen({
    super.key,
    required this.ticket,
  });

  @override
  State<CustomerTicketChatScreen> createState() => _CustomerTicketChatScreenState();
}

class _CustomerTicketChatScreenState extends State<CustomerTicketChatScreen> {
  late CustomerTicketsRx _rx;
  final TextEditingController _replyController = TextEditingController();
  final Set<String> _mySentMessages = {};
  List<dynamic> _messages = [];
  Timer? _typingTimer;
  Timer? _pollingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _rx = CustomerTicketsRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _loadMessages(widget.ticket);

    // Poll every 4 seconds for new incoming responses from Admin
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _pollTicketUpdates();
    });
  }

  Future<void> _pollTicketUpdates() async {
    try {
      final ticketId = widget.ticket['id']?.toString() ?? '';
      if (ticketId.isEmpty) return;
      final tickets = await _rx.api.getTickets();
      List<dynamic> list = [];
      if (tickets is List) {
        list = tickets;
      } else if (tickets is Map) {
        if (tickets['results'] is List) {
          list = tickets['results'];
        } else if (tickets['data'] is List) {
          list = tickets['data'];
        }
      }
      final updated = list.firstWhere(
        (t) => t is Map && t['id']?.toString() == ticketId,
        orElse: () => null,
      );
      if (updated != null && mounted) {
        setState(() {
          _loadMessages(Map<String, dynamic>.from(updated));
        });
      }
    } catch (_) {}
  }

  void _loadMessages(Map<String, dynamic> ticketData) {
    _messages = [];
    final currentUserId = appData.read(kKeyUserID)?.toString().trim() ?? '';
    final currentUserEmail = appData.read(kKeyEmail)?.toString().trim().toLowerCase() ?? '';

    // The main ticket object has a 'message' or 'description' (sent by user -> RIGHT side)
    final origMsg = ticketData['description'] ?? ticketData['message'] ?? '';
    if (origMsg.toString().trim().isNotEmpty) {
      _messages.add({
        'id': null,
        'isOriginal': true,
        'message': origMsg.toString(),
        'sender': 'You',
        'created_at': ticketData['created_at'] ?? '',
        'isMe': true,
      });
    }
    
    final replies = ticketData['messages'] ?? ticketData['replies'] ?? [];
    for (var r in replies) {
      if (r is! Map) continue;
      final text = (r['message'] ?? r['text'] ?? r['content'] ?? '').toString().trim();
      if (text.isEmpty) continue;

      final role = (r['sender_role'] ?? r['user_role'] ?? r['role'] ?? r['user_type'] ?? r['sender_type'] ?? '')
          .toString()
          .toLowerCase();
      final senderStr = (r['sender'] ?? r['user_name'] ?? r['author'] ?? r['name'] ?? '')
          .toString()
          .toLowerCase();

      final bool isExplicitAdminOrStaff = role.contains('admin') ||
          role.contains('support') ||
          role.contains('agent') ||
          role.contains('helpdesk') ||
          senderStr.contains('admin') ||
          senderStr.contains('support') ||
          senderStr.contains('agent') ||
          senderStr.contains('helpdesk') ||
          r['is_admin'] == true ||
          r['is_support'] == true;

      final senderId = (r['user_id'] ?? r['user'] ?? r['sender_id'] ?? r['author_id'])?.toString().trim() ?? '';
      final senderEmail = (r['email'] ?? r['user_email'] ?? r['sender_email'])?.toString().trim().toLowerCase() ?? '';

      final bool isExplicitMe = r['isMe'] == true ||
          r['is_me'] == true ||
          r['sender'] == 'You' ||
          (currentUserId.isNotEmpty && senderId.isNotEmpty && senderId == currentUserId) ||
          (currentUserEmail.isNotEmpty && senderEmail.isNotEmpty && senderEmail == currentUserEmail) ||
          _mySentMessages.contains(text) ||
          role.contains('customer') ||
          role.contains('wholesale') ||
          role.contains('buyer');

      bool isMe = false;
      if (isExplicitMe) {
        isMe = true;
      } else if (isExplicitAdminOrStaff) {
        isMe = false;
      } else if (currentUserId.isNotEmpty && senderId.isNotEmpty && senderId != currentUserId) {
        isMe = false;
      } else {
        isMe = false;
      }

      _messages.add({
        'id': r['id']?.toString(),
        'isOriginal': false,
        'message': text,
        'sender': isMe ? 'You' : 'Support',
        'created_at': r['created_at'] ?? '',
        'isMe': isMe,
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _rx.dispose();
    _replyController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTyping(String text) {
    if (!_isTyping) {
      _isTyping = true;
      final ticketId = widget.ticket['id']?.toString() ?? '';
      _rx.sendTypingIndicator(ticketId, true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      final ticketId = widget.ticket['id']?.toString() ?? '';
      _rx.sendTypingIndicator(ticketId, false);
    });
  }

  void _editMessage(int index, String messageId) {
    final msg = _messages[index];
    final controller = TextEditingController(text: msg['message']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Edit Message'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Enter new message'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newText = controller.text.trim();
                if (newText.isEmpty) return;
                final ticketId = widget.ticket['id']?.toString() ?? '';
                final success = await _rx.updateMessage(ticketId, messageId, newText);
                if (success) {
                  setState(() {
                    _messages[index]['message'] = newText;
                  });
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: 'Message updated');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(int index, String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final ticketId = widget.ticket['id']?.toString() ?? '';
                final success = await _rx.deleteMessage(ticketId, messageId);
                if (success) {
                  setState(() {
                    _messages.removeAt(index);
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _submitReply() async {
    final message = _replyController.text.trim();
    if (message.isEmpty) {
      Fluttertoast.showToast(msg: 'Reply cannot be empty');
      return;
    }

    final ticketId = widget.ticket['id']?.toString() ?? '';
    _mySentMessages.add(message);
    final newMsgData = await _rx.replyTicket(ticketId, message);
    if (newMsgData != null) {
      setState(() {
        _messages.add({
          'id': newMsgData['id']?.toString(),
          'isOriginal': false,
          'message': newMsgData['message'] ?? message,
          'sender': 'You',
          'created_at': 'Just now',
          'isMe': true,
        });
      });
      _replyController.clear();
      FocusScope.of(context).unfocus();
      _pollTicketUpdates();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    final subject = widget.ticket['subject'] ?? 'Support Ticket';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(subject, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isEditable = msg['isMe'] == true && msg['id'] != null;
                
                final bubble = _buildMessageBubble(
                  message: msg['message'],
                  sender: msg['sender'],
                  date: msg['created_at'],
                  isMe: msg['isMe'],
                  primaryColor: primaryColor,
                );

                if (isEditable) {
                  return GestureDetector(
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit, color: primaryColor),
                                  title: const Text('Edit Message'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _editMessage(index, msg['id']);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete, color: Colors.red),
                                  title: const Text('Delete Message'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _deleteMessage(index, msg['id']);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: bubble,
                  );
                }
                return bubble;
              },
            ),
          ),
          _buildReplyInput(primaryColor),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required String sender,
    required String date,
    required bool isMe,
    required Color primaryColor,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, left: isMe ? 40.w : 0, right: isMe ? 0 : 40.w),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isMe ? primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(3.r),
            bottomRight: isMe ? Radius.circular(3.r) : Radius.circular(16.r),
          ),
          border: isMe ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe) ...[
                  const Icon(Icons.support_agent_rounded, size: 14, color: Color(0xFF00694C)),
                  SizedBox(width: 4.w),
                ],
                Text(
                  sender,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white70 : const Color(0xFF00694C),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            if (date.isNotEmpty) ...[
              SizedBox(height: 5.h),
              Text(
                date,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: isMe ? Colors.white60 : Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Type a reply...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                ),
                onChanged: _onTyping,
                maxLines: 3,
                minLines: 1,
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: _submitReply,
              child: CircleAvatar(
                backgroundColor: primaryColor,
                radius: 22.r,
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
