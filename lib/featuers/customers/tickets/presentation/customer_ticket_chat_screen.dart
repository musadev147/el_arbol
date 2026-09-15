import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import '../data/customer_tickets_rx.dart';
import '../../../../helpers/support_ticket_unread_manager.dart';

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
  final ScrollController _scrollController = ScrollController();
  final Set<String> _mySentMessages = {};
  List<dynamic> _messages = [];
  Timer? _typingTimer;
  Timer? _pollingTimer;
  bool _isTyping = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _rx = CustomerTicketsRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _loadMessages(widget.ticket);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SupportTicketUnreadManager.instance.markTicketAsRead(widget.ticket);
      }
    });

    // Poll every 3 seconds for new incoming responses from Admin
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
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
        final updatedMap = Map<String, dynamic>.from(updated);
        setState(() {
          _loadMessages(updatedMap);
        });
        SupportTicketUnreadManager.instance.markTicketAsRead(updatedMap);
      }
    } catch (_) {}
  }

  void _loadMessages(Map<String, dynamic> ticketData) {
    _messages = [];

    // The main ticket object has a 'message' or 'description' (sent by user -> RIGHT side)
    final origMsg = ticketData['description'] ?? ticketData['message'] ?? '';
    if (origMsg.toString().trim().isNotEmpty) {
      _messages.add({
        'id': null,
        'isOriginal': true,
        'message': origMsg.toString(),
        'sender': 'You',
        'created_at': ticketData['created_at'] ?? '',
        'isAdmin': false,
        'isMe': true,
      });
    }

    final replies = ticketData['messages'] ?? ticketData['replies'] ?? [];
    for (var r in replies) {
      if (r is! Map) continue;
      final text = (r['message'] ?? r['text'] ?? r['content'] ?? '').toString().trim();
      if (text.isEmpty) continue;

      String senderName = '';
      String role = '';
      bool isStaffOrAdminFlag = false;

      if (r['senderName'] != null) {
        senderName = r['senderName'].toString();
      } else if (r['sender_name'] != null) {
        senderName = r['sender_name'].toString();
      } else if (r['user_name'] != null) {
        senderName = r['user_name'].toString();
      } else if (r['sender'] is String) {
        senderName = r['sender'].toString();
      } else if (r['user'] is String) {
        senderName = r['user'].toString();
      } else if (r['author'] is String) {
        senderName = r['author'].toString();
      } else if (r['name'] != null) {
        senderName = r['name'].toString();
      } else if (r['user'] is Map) {
        final u = r['user'] as Map;
        senderName = (u['name'] ?? u['username'] ?? u['first_name'] ?? '').toString();
        role = (u['user_type'] ?? u['role'] ?? u['user_role'] ?? '').toString();
        if (u['is_staff'] == true || u['is_admin'] == true || u['is_superuser'] == true) {
          isStaffOrAdminFlag = true;
        }
      } else if (r['sender'] is Map) {
        final u = r['sender'] as Map;
        senderName = (u['name'] ?? u['username'] ?? u['first_name'] ?? '').toString();
        role = (u['user_type'] ?? u['role'] ?? u['user_role'] ?? '').toString();
        if (u['is_staff'] == true || u['is_admin'] == true || u['is_superuser'] == true) {
          isStaffOrAdminFlag = true;
        }
      } else if (r['author'] is Map) {
        final u = r['author'] as Map;
        senderName = (u['name'] ?? u['username'] ?? u['first_name'] ?? '').toString();
        role = (u['user_type'] ?? u['role'] ?? u['user_role'] ?? '').toString();
        if (u['is_staff'] == true || u['is_admin'] == true || u['is_superuser'] == true) {
          isStaffOrAdminFlag = true;
        }
      }

      if (role.isEmpty) {
        role = (r['sender_role'] ?? r['user_role'] ?? r['role'] ?? r['user_type'] ?? r['sender_type'] ?? '').toString();
      }

      final nameLower = senderName.trim().toLowerCase();
      final roleLower = role.trim().toLowerCase();

      final bool isStaffOrAdmin = isStaffOrAdminFlag ||
          r['is_admin'] == true ||
          r['isAdmin'] == true ||
          r['is_staff'] == true ||
          r['is_support'] == true ||
          r['is_superuser'] == true ||
          nameLower.contains('admin') ||
          nameLower.contains('support') ||
          nameLower.contains('agent') ||
          nameLower.contains('staff') ||
          nameLower.contains('helpdesk') ||
          roleLower.contains('admin') ||
          roleLower.contains('support') ||
          roleLower.contains('agent') ||
          roleLower.contains('staff') ||
          roleLower.contains('helpdesk') ||
          roleLower.contains('superuser');

      // Admin messages -> isAdmin = true (LEFT side)
      // User messages -> isAdmin = false (RIGHT side)
      final bool isAdmin = isStaffOrAdmin;

      final String displaySender = isAdmin
          ? (senderName.isNotEmpty && !nameLower.contains('you') ? senderName : 'Support')
          : 'You';

      _messages.add({
        'id': r['id']?.toString(),
        'isOriginal': false,
        'message': text,
        'sender': displaySender,
        'created_at': r['created_at'] ?? '',
        'isAdmin': isAdmin,
        'isMe': !isAdmin,
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _rx.dispose();
    _replyController.dispose();
    _scrollController.dispose();
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
      builder: (dialogCtx) {
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
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
              onPressed: () async {
                final newText = controller.text.trim();
                if (newText.isEmpty) return;
                Navigator.pop(dialogCtx);
                setState(() {
                  _messages[index]['message'] = newText;
                });
                final ticketId = widget.ticket['id']?.toString() ?? '';
                final ok = await _rx.updateMessage(ticketId, messageId, newText);
                if (ok) {
                  AppToast.success('Message updated successfully');
                  _pollTicketUpdates();
                } else {
                  AppToast.error('Failed to update message');
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(int index, String messageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _messages.removeAt(index);
      });
      final ticketId = widget.ticket['id']?.toString() ?? '';
      final ok = await _rx.deleteMessage(ticketId, messageId);
      if (ok) {
        AppToast.success('Message deleted successfully');
        _pollTicketUpdates();
      } else {
        AppToast.error('Failed to delete message');
      }
    }
  }

  void _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSending) return;

    _replyController.clear();
    _mySentMessages.add(text);

    // Optimistic local UI update (User on RIGHT side)
    setState(() {
      _isSending = true;
      _messages.add({
        'id': null,
        'isOriginal': false,
        'message': text,
        'sender': 'You',
        'created_at': DateTime.now().toIso8601String(),
        'isAdmin': false,
        'isMe': true,
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    final ticketId = widget.ticket['id']?.toString() ?? '';
    final ok = await _rx.replyTicket(ticketId, text);
    if (mounted) {
      setState(() => _isSending = false);
      if (ok != null) {
        _pollTicketUpdates();
      } else {
        AppToast.error('Failed to send message');
      }
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (_) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }
  }

  String _formatDateSeparator(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Today';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
        return 'Today';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day) {
        return 'Yesterday';
      }
      return DateFormat('MMMM d, yyyy').format(dateTime);
    } catch (_) {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    const Color backgroundColor = Color(0xFFFAFAF8);

    final subject = widget.ticket['subject'] ?? widget.ticket['title'] ?? 'Ticket Details';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF151E13)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: const Color(0xFF151E13),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'Support Online',
                  style: TextStyle(
                    color: const Color(0xFF6D7A73),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6D7A73)),
            tooltip: 'Refresh',
            onPressed: _pollTicketUpdates,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48.r, color: Colors.grey.shade400),
                          SizedBox(height: 12.h),
                          Text(
                            'Support Conversation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: const Color(0xFF151E13),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Send a message below to chat with Support.',
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6D7A73)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[_messages.length - 1 - index];
                        // Admin on LEFT (isAdmin = true), User on RIGHT (isAdmin = false)
                        final bool isAdmin = msg['isAdmin'] == true;
                        final bool isUserMe = !isAdmin;
                        final bool isEditable = isUserMe && msg['id'] != null;
                        final senderName = (msg['sender'] ?? '').toString();
                        final dateStr = msg['created_at']?.toString() ?? '';
                        final timeStr = _formatTime(dateStr);

                        // Check if we should show date separator
                        bool showDateHeader = false;
                        String dateHeader = '';
                        if (index == _messages.length - 1) {
                          showDateHeader = true;
                          dateHeader = _formatDateSeparator(dateStr);
                        } else {
                          final nextMsg = _messages[_messages.length - 2 - index];
                          final currDate = _formatDateSeparator(dateStr);
                          final nextDate = _formatDateSeparator(nextMsg['created_at']?.toString());
                          if (currDate != nextDate) {
                            showDateHeader = true;
                            dateHeader = currDate;
                          }
                        }

                        final bubble = Align(
                          alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 8.h,
                              left: isAdmin ? 0 : 50.w,
                              right: isAdmin ? 50.w : 0,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                            decoration: BoxDecoration(
                              color: isAdmin ? Colors.white : primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.r),
                                topRight: Radius.circular(12.r),
                                bottomLeft: isAdmin ? Radius.circular(2.r) : Radius.circular(12.r),
                                bottomRight: isAdmin ? Radius.circular(12.r) : Radius.circular(2.r),
                              ),
                              border: isAdmin ? Border.all(color: Colors.grey.shade200) : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isAdmin) ...[
                                      const Icon(Icons.support_agent_rounded, size: 14, color: primaryColor),
                                      SizedBox(width: 4.w),
                                      Text(
                                        senderName.isNotEmpty && !senderName.toLowerCase().contains('you') ? senderName : 'Support',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        'You',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  msg['message'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: isAdmin ? const Color(0xFF151E13) : Colors.white,
                                    fontFamily: 'Poppins',
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: isAdmin ? Colors.grey.shade600 : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        return Column(
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8ECE9),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    dateHeader,
                                    style: TextStyle(
                                      color: const Color(0xFF4A554E),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            if (isEditable)
                              GestureDetector(
                                onLongPress: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                                    ),
                                    builder: (ctx) {
                                      return SafeArea(
                                        child: Wrap(
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.edit, color: primaryColor),
                                              title: const Text('Edit Message', style: TextStyle(color: Color(0xFF151E13))),
                                              onTap: () {
                                                Navigator.pop(ctx);
                                                _editMessage(_messages.length - 1 - index, msg['id']);
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.delete, color: Colors.redAccent),
                                              title: const Text('Delete Message', style: TextStyle(color: Colors.redAccent)),
                                              onTap: () {
                                                Navigator.pop(ctx);
                                                _deleteMessage(_messages.length - 1 - index, msg['id']);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: bubble,
                              )
                            else
                              bubble,
                          ],
                        );
                      },
                    ),
            ),

            // Text-only Input Bar
            _buildReplyInput(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F5),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _replyController,
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF151E13)),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
                onChanged: _onTyping,
                onSubmitted: (_) => _submitReply(),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _isSending ? null : _submitReply,
            child: CircleAvatar(
              radius: 21.r,
              backgroundColor: primaryColor,
              child: _isSending
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
