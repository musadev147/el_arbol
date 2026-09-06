import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:el_arbol/helpers/di.dart';
import 'package:el_arbol/constants/app_constants.dart';

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

    // Auto-scroll after initial load
    _rx.valueStreamData.listen((_) {
      _scrollToBottom();
    });

    // Poll periodically for new responses from Admin
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
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
          duration: const Duration(milliseconds: 300),
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

  String _formatDateTime(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ticketSubject,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
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
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'Admin Support Online',
                  style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Chat',
            onPressed: () => _rx.fetchSingleTicket(widget.ticketId),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _optimisticMessages.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
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
          final String currentUserId = appData.read(kKeyUserID)?.toString().trim() ?? '';
          final String currentUserEmail = appData.read(kKeyEmail)?.toString().trim().toLowerCase() ?? '';

          // 1. Initial Ticket Problem Message (sent by user -> RIGHT side)
          if (originalMsg.toString().trim().isNotEmpty) {
            allMessages.add({
              'message': originalMsg.toString(),
              'sender': 'You',
              'created_at': originalDate,
              'isMe': true,
              'isOriginal': true,
            });
          }

          // 2. Replies from backend
          for (var r in backendReplies) {
            if (r is! Map) continue;
            final text = (r['message'] ?? r['text'] ?? r['content'] ?? '').toString().trim();
            if (text.isEmpty) continue;

            final senderId = (r['user'] ?? r['user_id'] ?? r['sender_id'] ?? r['author_id'])?.toString().trim() ?? '';
            final senderEmail = (r['email'] ?? r['user_email'] ?? r['sender_email'])?.toString().trim().toLowerCase() ?? '';
            final role = (r['sender_role'] ?? r['user_role'] ?? r['role'] ?? r['user_type'] ?? r['sender_type'] ?? '')
                .toString()
                .toLowerCase();
            final senderName = (r['sender'] ?? r['user_name'] ?? r['author'] ?? r['name'] ?? '')
                .toString()
                .toLowerCase();

            // Explicit Admin / Staff check
            final bool isExplicitAdminOrStaff = role.contains('admin') ||
                role.contains('staff') ||
                role.contains('support') ||
                role.contains('agent') ||
                role.contains('helpdesk') ||
                role.contains('superuser') ||
                senderName.contains('admin') ||
                senderName.contains('support') ||
                senderName.contains('agent') ||
                senderName.contains('helpdesk') ||
                r['is_staff'] == true ||
                r['is_admin'] == true ||
                r['is_support'] == true ||
                r['is_superuser'] == true;

            // Explicit Me check
            final bool isExplicitMe = r['isMe'] == true ||
                r['is_me'] == true ||
                r['sender'] == 'You' ||
                (currentUserId.isNotEmpty && senderId.isNotEmpty && senderId == currentUserId) ||
                (currentUserEmail.isNotEmpty && senderEmail.isNotEmpty && senderEmail == currentUserEmail) ||
                _mySentMessageTexts.contains(text) ||
                role.contains('customer') ||
                role.contains('wholesale') ||
                role.contains('buyer');

            // Any message sent by ME is on the RIGHT side; any reply from someone else / Admin is on the LEFT side
            bool isMe = false;
            if (isExplicitAdminOrStaff) {
              isMe = false;
            } else if (isExplicitMe) {
              isMe = true;
            } else if (currentUserId.isNotEmpty && senderId.isNotEmpty && senderId != currentUserId) {
              isMe = false;
            } else {
              // A reply on the ticket not sent by the user is from the support team -> LEFT side
              isMe = false;
            }

            allMessages.add({
              'message': text,
              'sender': isMe ? 'You' : 'Admin Support',
              'created_at': r['created_at'] ?? r['timestamp'] ?? '',
              'isMe': isMe,
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

          return Column(
            children: [
              // Ticket Header info banner
              if (ticketData['category'] != null || ticketData['status'] != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category: ${ticketData['category'] ?? 'GENERAL'}',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
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
                              Icon(Icons.chat_bubble_outline_rounded, size: 54.r, color: Colors.grey.shade300),
                              SizedBox(height: 12.h),
                              Text(
                                'Connecting to Admin Support...',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.grey.shade700),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Send a message below to chat with Admin.',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          final msg = allMessages[index];
                          final bool isMe = msg['isMe'] == true;
                          final bool isOriginal = msg['isOriginal'] == true;
                          final String sender = msg['sender'] ?? (isMe ? 'You' : 'Admin Support');
                          final String date = _formatDateTime(msg['created_at']);
                          final String content = msg['message'] ?? '';

                          return _buildMessageBubble(
                            message: content,
                            sender: sender,
                            date: date,
                            isMe: isMe,
                            isOriginal: isOriginal,
                            primaryColor: primaryColor,
                          );
                        },
                      ),
              ),

              // Reply Input Field
              _buildReplyInput(primaryColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required String sender,
    required String date,
    required bool isMe,
    required bool isOriginal,
    required Color primaryColor,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: isMe ? 48.w : 0,
          right: isMe ? 0 : 48.w,
        ),
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
                  isOriginal ? '$sender (Initial Request)' : sender,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white70 : const Color(0xFF00694C),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: isMe ? Colors.white : const Color(0xFF151E13),
                height: 1.3,
              ),
            ),
            if (date.isNotEmpty) ...[
              SizedBox(height: 6.h),
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
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
                  hintText: 'Type your message to Admin...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                ),
                maxLines: 3,
                minLines: 1,
                onSubmitted: (_) => _submitReply(),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: _isSending ? null : _submitReply,
              child: CircleAvatar(
                backgroundColor: primaryColor,
                radius: 22.r,
                child: _isSending
                    ? SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 19),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
