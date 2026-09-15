import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import 'package:el_arbol/common_wigdets/custom_app_loading.dart';
import 'package:el_arbol/helpers/di.dart';
import 'package:el_arbol/constants/app_constants.dart';
import 'package:el_arbol/helpers/support_ticket_unread_manager.dart';
import '../data/customer_tickets_rx.dart';
import 'customer_tickets_screen.dart';

class CustomerChatScreen extends StatefulWidget {
  const CustomerChatScreen({super.key});

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CustomerTicketsRx _ticketsRx;
  StreamSubscription? _subscription;
  Timer? _pollingTimer;

  List<dynamic> _allTickets = [];
  Map<String, dynamic>? _activeTicket;
  List<Map<String, dynamic>> _messages = [];
  final Set<String> _mySentMessageTexts = {};

  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedSentMessages();
    _ticketsRx = CustomerTicketsRx(
      empty: [],
      dataFetcher: BehaviorSubject<List<dynamic>>(),
    );

    _loadTicketsData();

    _subscription = _ticketsRx.valueStreamData.listen((list) {
      if (list is List && mounted) {
        setState(() {
          _allTickets = list;
          if (_allTickets.isNotEmpty) {
            // If active ticket already chosen, refresh it with latest data
            if (_activeTicket != null) {
              final found = _allTickets.firstWhere(
                (t) => t is Map && t['id']?.toString() == _activeTicket!['id']?.toString(),
                orElse: () => _allTickets.first,
              );
              _activeTicket = found is Map ? Map<String, dynamic>.from(found) : null;
            } else {
              _activeTicket = Map<String, dynamic>.from(_allTickets.first);
            }
          }
          _extractMessages();
        });

        if (_activeTicket != null) {
          SupportTicketUnreadManager.instance.markTicketAsRead(_activeTicket!);
        }
      }
    });

    // Automatically poll every 3 seconds for new incoming replies from Admin
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _ticketsRx.fetchTickets();
      }
    });
  }

  void _loadPersistedSentMessages() {
    try {
      final saved = appData.read('customer_sent_chat_messages');
      if (saved is List) {
        _mySentMessageTexts.addAll(saved.map((e) => e.toString().trim()));
      }
    } catch (_) {}
  }

  void _persistSentMessage(String text) {
    try {
      _mySentMessageTexts.add(text.trim());
      appData.write('customer_sent_chat_messages', _mySentMessageTexts.toList());
    } catch (_) {}
  }

  Future<void> _loadTicketsData() async {
    setState(() => _isLoading = true);
    await _ticketsRx.fetchTickets();
    if (mounted) {
      setState(() => _isLoading = false);
      _scrollToBottom(immediate: true, force: true);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _subscription?.cancel();
    _ticketsRx.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _extractMessages() {
    if (_activeTicket == null) {
      _messages = [];
      return;
    }

    final currentUserId = appData.read(kKeyUserID)?.toString().trim() ?? '';
    final currentUserEmail = appData.read(kKeyEmail)?.toString().trim().toLowerCase() ?? '';

    final List<Map<String, dynamic>> parsedList = [];

    // Main initial ticket message/description (created by user)
    final origMsg = _activeTicket!['description'] ?? _activeTicket!['message'] ?? '';
    if (origMsg.toString().trim().isNotEmpty) {
      parsedList.add({
        'id': null,
        'message': origMsg.toString().trim(),
        'sender': 'You',
        'created_at': _activeTicket!['created_at'] ?? '',
        'isMe': true,
      });
    }

    // Replies list
    final rawReplies = _activeTicket!['messages'] ?? _activeTicket!['replies'] ?? [];
    if (rawReplies is List) {
      for (var r in rawReplies) {
        if (r is! Map) continue;
        final text = (r['message'] ?? r['text'] ?? r['content'] ?? '').toString().trim();
        if (text.isEmpty) continue;

        final role = (r['sender_role'] ?? r['user_role'] ?? r['role'] ?? r['user_type'] ?? r['sender_type'] ?? '')
            .toString()
            .toLowerCase();
        final senderStr = (r['senderName'] ?? r['sender_name'] ?? r['sender'] ?? r['user_name'] ?? r['author'] ?? r['name'] ?? '')
            .toString()
            .toLowerCase();

        final bool isExplicitAdminOrStaff = role.contains('admin') ||
            role.contains('support') ||
            role.contains('agent') ||
            role.contains('staff') ||
            senderStr.contains('admin') ||
            senderStr.contains('support') ||
            senderStr.contains('agent') ||
            r['is_admin'] == true ||
            r['isAdmin'] == true ||
            r['is_support'] == true;

        final senderId = (r['user_id'] ?? r['user'] ?? r['sender_id'] ?? r['author_id'])?.toString().trim() ?? '';
        final senderEmail = (r['senderEmail'] ?? r['sender_email'] ?? r['email'] ?? r['user_email'])?.toString().trim().toLowerCase() ?? '';

        final bool isExplicitMe = r['isMe'] == true ||
            r['is_me'] == true ||
            r['sender'] == 'You' ||
            (currentUserId.isNotEmpty && senderId.isNotEmpty && senderId == currentUserId) ||
            (currentUserEmail.isNotEmpty && senderEmail.isNotEmpty && senderEmail == currentUserEmail) ||
            _mySentMessageTexts.contains(text);

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

        parsedList.add({
          'id': r['id']?.toString(),
          'message': text,
          'sender': isMe ? 'You' : (r['senderName'] ?? r['sender_name'] ?? r['sender'] ?? 'admin'),
          'created_at': r['created_at'] ?? '',
          'isMe': isMe,
        });
      }
    }

    _messages = parsedList;
    _scrollToBottom();
  }

  void _scrollToBottom({bool immediate = false, bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (force || _scrollController.position.pixels < 250) {
          if (immediate) {
            _scrollController.jumpTo(0.0);
          } else {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        }
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    _persistSentMessage(text);

    // Optimistic UI addition
    final optimisticMsg = {
      'id': null,
      'message': text,
      'sender': 'You',
      'created_at': DateTime.now().toIso8601String(),
      'isMe': true,
    };

    setState(() {
      _messages.add(optimisticMsg);
    });
    _scrollToBottom(immediate: true, force: true);

    _isSending = true;
    try {
      if (_activeTicket != null && _activeTicket!['id'] != null) {
        final ticketId = _activeTicket!['id'].toString();
        final res = await _ticketsRx.replyTicket(ticketId, text);
        if (res == null) {
          // If error returned
          AppToast.error("Failed to send message. Please try again.");
        }
      } else {
        // Automatically create a new support chat ticket for the customer
        final created = await _ticketsRx.createTicket(
          "Customer Support Inquiry",
          text,
          category: "GENERAL",
          priority: "HIGH",
        );
        if (!created) {
          AppToast.error("Failed to send message. Please try again.");
        }
      }
      await _ticketsRx.fetchTickets();
      if (mounted) {
        _scrollToBottom(force: true);
      }
    } catch (e) {
      AppToast.error("Failed to send message.");
    } finally {
      _isSending = false;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  void _showTicketSelectorDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Support Conversations',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF151E13),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF00694C)),
                      label: const Text('New Ticket', style: TextStyle(color: Color(0xFF00694C), fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CustomerSupportTicketsScreen()),
                        ).then((_) => _loadTicketsData());
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (_allTickets.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'No support tickets created yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _allTickets.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final t = Map<String, dynamic>.from(_allTickets[index]);
                        final subject = t['subject'] ?? t['title'] ?? 'Ticket #${t['id'] ?? index + 1}';
                        final isCurrent = _activeTicket?['id']?.toString() == t['id']?.toString();
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          leading: CircleAvatar(
                            backgroundColor: isCurrent ? const Color(0xFF00694C) : const Color(0xFFECF7E4),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 18.r,
                              color: isCurrent ? Colors.white : const Color(0xFF00694C),
                            ),
                          ),
                          title: Text(
                            subject,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isCurrent ? const Color(0xFF00694C) : const Color(0xFF151E13),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Status: ${t['status'] ?? 'OPEN'}',
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                          ),
                          trailing: isCurrent
                              ? const Icon(Icons.check_circle, color: Color(0xFF00694C), size: 20)
                              : null,
                          onTap: () {
                            setState(() {
                              _activeTicket = t;
                              _extractMessages();
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    const Color backgroundColor = Color(0xFFFAFAF8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support Chat',
              style: TextStyle(
                color: const Color(0xFF151E13),
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _activeTicket != null && _activeTicket!['subject'] != null
                  ? '${_activeTicket!['subject']}'
                  : 'Chatting with Administrator',
              style: TextStyle(
                color: const Color(0xFF6D7A73),
                fontSize: 11.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF00694C)),
            tooltip: 'All Conversations',
            onPressed: _showTicketSelectorDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6D7A73)),
            tooltip: 'Refresh',
            onPressed: _loadTicketsData,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const CustomAppLoading.chat()
                  : _messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, size: 52.r, color: Colors.grey.shade400),
                                SizedBox(height: 14.h),
                                Text(
                                  'Support Chat',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF151E13),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "We're here to help! Send a message below to chat with our Administrator Support.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: const Color(0xFF6D7A73), fontSize: 13.sp),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: primaryColor,
                          onRefresh: () => _ticketsRx.fetchTickets(),
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: EdgeInsets.all(16.r),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[_messages.length - 1 - index];
                              final isMe = msg['isMe'] == true;
                              final senderName = (msg['sender'] ?? '').toString();

                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: 12.h,
                                    left: isMe ? 48.w : 0,
                                    right: isMe ? 0 : 48.w,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                  decoration: BoxDecoration(
                                    color: isMe ? primaryColor : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.r),
                                      topRight: Radius.circular(12.r),
                                      bottomLeft: isMe ? Radius.circular(12.r) : Radius.circular(3.r),
                                      bottomRight: isMe ? Radius.circular(3.r) : Radius.circular(12.r),
                                    ),
                                    border: isMe ? null : Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe) ...[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.support_agent_rounded, size: 14.r, color: primaryColor),
                                            SizedBox(width: 4.w),
                                            Text(
                                              senderName.isNotEmpty && !senderName.toLowerCase().contains('you')
                                                  ? senderName
                                                  : 'admin',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                      ],
                                      Text(
                                        msg['message'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: isMe ? Colors.white : const Color(0xFF151E13),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatTime(msg['created_at']),
                                            style: TextStyle(
                                              fontSize: 9.sp,
                                              color: isMe ? Colors.white70 : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),

            // Bottom Message Input Row
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: primaryColor,
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
