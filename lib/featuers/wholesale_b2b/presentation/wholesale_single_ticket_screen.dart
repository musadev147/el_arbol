import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:el_arbol/helpers/di.dart';
import 'package:el_arbol/common_wigdets/custom_app_loading.dart';
import 'package:el_arbol/helpers/support_ticket_unread_manager.dart';

class WholesaleSingleTicketScreen extends StatefulWidget {
  final String ticketId;
  final String ticketSubject;

  const WholesaleSingleTicketScreen({
    super.key,
    required this.ticketId,
    required this.ticketSubject,
  });

  @override
  State<WholesaleSingleTicketScreen> createState() => _WholesaleSingleTicketScreenState();
}

class _WholesaleSingleTicketScreenState extends State<WholesaleSingleTicketScreen> {
  late WholesaleSingleTicketRx _rx;
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _optimisticMessages = [];
  final Set<String> _mySentMessageTexts = {};
  Timer? _pollingTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedSentMessages();
    _rx = WholesaleSingleTicketRx(
      empty: {},
      dataFetcher: BehaviorSubject<Map<String, dynamic>>(),
    );
    _rx.fetchSingleTicket(widget.ticketId);

    // Auto-scroll and mark read after load
    _rx.valueStreamData.listen((data) {
      if (data is Map && data.isNotEmpty) {
        SupportTicketUnreadManager.instance.markTicketAsRead(Map<String, dynamic>.from(data));
      }
      _scrollToBottom();
    });

    // Poll periodically for new responses from Admin
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _rx.fetchSingleTicket(widget.ticketId, silent: true);
      }
    });
  }

  void _loadPersistedSentMessages() {
    try {
      final saved = appData.read('wholesale_sent_ticket_messages_${widget.ticketId}');
      if (saved is List) {
        _mySentMessageTexts.addAll(saved.map((e) => e.toString().trim()));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _replyController.dispose();
    _scrollController.dispose();
    _rx.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitReply() async {
    final message = _replyController.text.trim();
    if (message.isEmpty || _isSending) return;

    _replyController.clear();
    _mySentMessageTexts.add(message);
    try {
      final key = 'wholesale_sent_ticket_messages_${widget.ticketId}';
      final saved = (appData.read(key) is List) ? List<String>.from(appData.read(key)) : <String>[];
      if (!saved.contains(message)) {
        saved.add(message);
        appData.write(key, saved);
      }
    } catch (_) {}

    setState(() {
      _isSending = true;
      _optimisticMessages.add({
        'message': message,
        'sender': 'You',
        'created_at': DateTime.now().toIso8601String(),
        'isAdmin': false,
        'isMe': true,
        'isOptimistic': true,
      });
    });
    _scrollToBottom();

    final success = await _rx.replyToTicket(widget.ticketId, message);
    if (mounted) {
      setState(() {
        _isSending = false;
        if (success) {
          _optimisticMessages.clear();
        }
      });
      _scrollToBottom();
    }
  }

  String _formatTime(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }
  }

  String _formatDateSeparator(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return 'Today';
    try {
      final dateTime = DateTime.parse(raw.toString()).toLocal();
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
              widget.ticketSubject,
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
                  'Admin Support Online',
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
            tooltip: 'Refresh Chat',
            onPressed: () => _rx.fetchSingleTicket(widget.ticketId),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _optimisticMessages.isEmpty) {
            return const CustomAppLoading.chat();
          }

          final rawData = snapshot.data;
          Map<String, dynamic> ticketData = {};
          if (rawData is Map) {
            if (rawData.containsKey('data') && rawData['data'] is Map) {
              ticketData = Map<String, dynamic>.from(rawData['data']);
            } else if (rawData.containsKey('ticket') && rawData['ticket'] is Map) {
              ticketData = Map<String, dynamic>.from(rawData['ticket']);
            } else {
              ticketData = Map<String, dynamic>.from(rawData);
            }
          }

          // Extract original message
          final originalMsg = ticketData['description'] ??
              ticketData['message'] ??
              ticketData['content'] ??
              ticketData['title'] ??
              '';
          final originalDate = ticketData['created_at'] ?? ticketData['date'] ?? '';

          // Extract replies/messages array
          List<dynamic> backendReplies = [];
          if (ticketData['messages'] is List) {
            backendReplies = ticketData['messages'];
          } else if (ticketData['replies'] is List) {
            backendReplies = ticketData['replies'];
          } else if (ticketData['data'] is Map && ticketData['data']['messages'] is List) {
            backendReplies = ticketData['data']['messages'];
          }

          // Build unified message list
          final List<Map<String, dynamic>> allMessages = [];

          // 1. Initial Ticket Problem Message (sent by user -> RIGHT side)
          if (originalMsg.toString().trim().isNotEmpty) {
            allMessages.add({
              'message': originalMsg.toString(),
              'sender': 'You',
              'created_at': originalDate,
              'isAdmin': false,
              'isMe': true,
              'isOriginal': true,
            });
          }

          // 2. Replies from backend
          for (var r in backendReplies) {
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
            // User messages (e.g. 'mousa') -> isAdmin = false (RIGHT side)
            final bool isAdmin = isStaffOrAdmin;

            final String displaySender = isAdmin
                ? (senderName.isNotEmpty && !nameLower.contains('you') ? senderName : 'Admin Support')
                : 'You';

            allMessages.add({
              'message': text,
              'sender': displaySender,
              'created_at': r['created_at'] ?? r['timestamp'] ?? '',
              'isAdmin': isAdmin,
              'isMe': !isAdmin,
            });
          }

          // 3. Optimistic local messages (deduplicated)
          final backendTexts = allMessages.map((m) => m['message'].toString().trim()).toSet();
          for (var opt in _optimisticMessages) {
            final optText = opt['message'].toString().trim();
            if (!backendTexts.contains(optText)) {
              allMessages.add(opt);
            }
          }

          return SafeArea(
            child: Column(
              children: [
                // Ticket Category/Status Pill
                if (ticketData['category'] != null || ticketData['status'] != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    color: const Color(0xFFF0F4F2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Category: ${ticketData['category'] ?? 'GENERAL'}',
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF4A554E), fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            (ticketData['status'] ?? 'OPEN').toString().toUpperCase(),
                            style: TextStyle(fontSize: 10.sp, color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),

                // Chat Messages List
                Expanded(
                  child: allMessages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.r),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, size: 48.r, color: Colors.grey.shade400),
                                SizedBox(height: 12.h),
                                Text(
                                  'Wholesale Ticket Conversation',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                    color: const Color(0xFF151E13),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  'Send a message below to chat with Admin Support.',
                                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6D7A73)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          itemCount: allMessages.length,
                          itemBuilder: (context, index) {
                            final msg = allMessages[index];
                            // Admin on LEFT (isAdmin = true), User on RIGHT (isAdmin = false)
                            final bool isAdmin = msg['isAdmin'] == true;
                            final String sender = msg['sender'] ?? (isAdmin ? 'Admin Support' : 'You');
                            final String dateStr = msg['created_at']?.toString() ?? '';
                            final timeStr = _formatTime(dateStr);
                            final String content = msg['message'] ?? '';

                            // Date separator logic
                            bool showDateHeader = false;
                            String dateHeader = '';
                            if (index == 0) {
                              showDateHeader = true;
                              dateHeader = _formatDateSeparator(dateStr);
                            } else {
                              final prevMsg = allMessages[index - 1];
                              final currDate = _formatDateSeparator(dateStr);
                              final prevDate = _formatDateSeparator(prevMsg['created_at']?.toString());
                              if (currDate != prevDate) {
                                showDateHeader = true;
                                dateHeader = currDate;
                              }
                            }

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
                                Align(
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
                                                sender.isNotEmpty && !sender.toLowerCase().contains('you') ? sender : 'Admin Support',
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
                                          content,
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
                                ),
                              ],
                            );
                          },
                        ),
                ),

                // Reply Input Field (Text Only, No emojis/images)
                _buildReplyInput(primaryColor),
              ],
            ),
          );
        },
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
