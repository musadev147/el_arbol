import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import 'package:el_arbol/common_wigdets/custom_app_loading.dart';
import 'package:el_arbol/helpers/di.dart';
import 'package:el_arbol/helpers/support_ticket_unread_manager.dart';
import '../data/wholesale_rx.dart';
import '../data/wholesale_api.dart';
import 'wholesale_support_tickets_screen.dart';

class WholesaleChatScreen extends StatefulWidget {
  const WholesaleChatScreen({super.key});

  @override
  State<WholesaleChatScreen> createState() => _WholesaleChatScreenState();
}

class _WholesaleChatScreenState extends State<WholesaleChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late WholesaleTicketsRx _ticketsRx;
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
    _ticketsRx = WholesaleTicketsRx(
      empty: {},
      dataFetcher: BehaviorSubject<Map<String, dynamic>>(),
    );

    _loadTicketsData();

    _subscription = _ticketsRx.valueStreamData.listen((data) {
      if (data is Map && mounted) {
        List<dynamic> list = [];
        if (data['results'] is List) {
          list = data['results'] as List;
        } else if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['tickets'] is List) {
          list = data['tickets'] as List;
        }

        setState(() {
          _allTickets = list;
          if (_allTickets.isNotEmpty) {
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
      final saved = appData.read('wholesale_sent_chat_messages');
      if (saved is List) {
        _mySentMessageTexts.addAll(saved.map((e) => e.toString().trim()));
      }
    } catch (_) {}
  }

  void _persistSentMessage(String text) {
    try {
      _mySentMessageTexts.add(text.trim());
      appData.write('wholesale_sent_chat_messages', _mySentMessageTexts.toList());
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

    final List<Map<String, dynamic>> parsedList = [];

    // Main initial ticket message/description (created by wholesale user -> RIGHT side)
    final origMsg = _activeTicket!['description'] ?? _activeTicket!['message'] ?? '';
    if (origMsg.toString().trim().isNotEmpty) {
      parsedList.add({
        'id': null,
        'message': origMsg.toString().trim(),
        'sender': 'You',
        'created_at': _activeTicket!['created_at'] ?? '',
        'isAdmin': false,
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

        parsedList.add({
          'id': r['id']?.toString(),
          'message': text,
          'sender': displaySender,
          'created_at': r['created_at'] ?? '',
          'isAdmin': isAdmin,
          'isMe': !isAdmin,
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

    // Optimistic UI addition (User message on RIGHT side)
    final optimisticMsg = {
      'id': null,
      'message': text,
      'sender': 'You',
      'created_at': DateTime.now().toIso8601String(),
      'isAdmin': false,
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
        await WholesaleApi.instance.createTicketReply(ticketId, text);
      } else {
        final payload = {
          "subject": "Wholesale Support Inquiry",
          "title": "Wholesale Support Inquiry",
          "description": text,
          "message": text,
          "category": "GENERAL",
          "priority": "HIGH",
        };
        await WholesaleApi.instance.createTicket(payload);
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
                      'Wholesale Conversations',
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
                          MaterialPageRoute(builder: (_) => const WholesaleSupportTicketsScreen()),
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

    final String ticketSubject = _activeTicket != null && _activeTicket!['subject'] != null
        ? _activeTicket!['subject'].toString()
        : 'Wholesale Support Chat';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticketSubject,
              style: TextStyle(
                color: const Color(0xFF151E13),
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
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
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF151E13)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: primaryColor),
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
                                  'Wholesale Support Chat',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF151E13),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "We're here to help! Send a message below to chat with our B2B Administrator Support.",
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
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[_messages.length - 1 - index];
                              // Admin on LEFT (isAdmin = true), User on RIGHT (isAdmin = false)
                              final bool isAdmin = msg['isAdmin'] == true;
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
                                                  senderName.isNotEmpty && !senderName.toLowerCase().contains('you')
                                                      ? senderName
                                                      : 'Admin Support',
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
            ),

            // Only Clean Text Input Bar (No emoji, No image/attachment icons)
            Container(
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
                        controller: _messageController,
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF151E13)),
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _sendMessage,
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
            ),
          ],
        ),
      ),
    );
  }
}
