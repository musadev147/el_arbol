import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  List<dynamic> _messages = [];
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _rx = CustomerTicketsRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _loadMessages();
  }

  void _loadMessages() {
    // The main ticket object has a 'message' or 'description' and might have 'replies' or 'messages' array
    _messages = [];
    _messages.add({
      'id': null,
      'isOriginal': true,
      'message': widget.ticket['description'] ?? widget.ticket['message'] ?? '',
      'sender': 'You',
      'created_at': widget.ticket['created_at'] ?? '',
      'isMe': true,
    });
    
    final replies = widget.ticket['messages'] ?? widget.ticket['replies'] ?? [];
    for (var r in replies) {
      bool isMe = r['sender_role'] == 'customer' || r['user_role'] == 'customer' || r['is_customer'] == true;
      _messages.add({
        'id': r['id']?.toString(),
        'isOriginal': false,
        'message': r['message'] ?? '',
        'sender': isMe ? 'You' : 'Support',
        'created_at': r['created_at'] ?? '',
        'isMe': isMe,
      });
    }
  }

  @override
  void dispose() {
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
            bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
            bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              date,
              style: TextStyle(
                fontSize: 9.sp,
                color: isMe ? Colors.white54 : Colors.grey.shade500,
              ),
            ),
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
