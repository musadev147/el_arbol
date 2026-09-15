import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import 'package:el_arbol/common_wigdets/custom_app_loading.dart';
import '../data/rx.dart';
import '../model/staff_chat_model.dart';

class StaffChatScreen extends StatefulWidget {
  const StaffChatScreen({super.key});

  @override
  State<StaffChatScreen> createState() => _StaffChatScreenState();
}

class _StaffChatScreenState extends State<StaffChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final StaffChatRx _chatRx;
  StreamSubscription? _chatSubscription;
  Timer? _pollingTimer;
  bool _isSending = false;

  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _chatRx = StaffChatRx.instance;
    _chatRx.markAllAsRead();
    _chatRx.fetchChatMessages().then((_) {
      if (mounted) {
        _chatRx.markAllAsRead();
        _scrollToBottom(immediate: true, force: true);
      }
    });

    // Auto-scroll and mark read whenever new messages arrive
    _chatSubscription = _chatRx.valueStreamData.listen((list) {
      if (list.length > _lastMessageCount) {
        _lastMessageCount = list.length;
        _scrollToBottom(force: _lastMessageCount == 0);
        if (mounted) {
          _chatRx.markAllAsRead();
        }
      }
    });

    // Automatically poll every 3 seconds for new incoming messages from Admin while on this screen
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _chatRx.fetchChatMessages(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _chatSubscription?.cancel();
    _chatRx.markAllAsRead();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

    // Optimistic local UI update (Staff / User on RIGHT side)
    final optimisticMsg = StaffChatMessage(
      message: text,
      sender: 'STAFF',
      createdAt: DateTime.now().toIso8601String(),
    );
    final currentList = _chatRx.dataFetcher.hasValue ? _chatRx.dataFetcher.value : <StaffChatMessage>[];
    _chatRx.dataFetcher.sink.add(List<StaffChatMessage>.from(currentList)..add(optimisticMsg));
    _scrollToBottom(immediate: true, force: true);

    setState(() => _isSending = true);
    final success = await _chatRx.sendMessage(text);
    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _scrollToBottom(force: true);
        _chatRx.fetchChatMessages(silent: true);
      } else {
        AppToast.error('Failed to send message. Please try again.');
      }
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
              'Staff Support',
              style: TextStyle(
                color: const Color(0xFF151E13),
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
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
            tooltip: 'Refresh',
            onPressed: () => _chatRx.fetchChatMessages(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<StaffChatMessage>>(
                stream: _chatRx.valueStreamData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      (!_chatRx.dataFetcher.hasValue || _chatRx.dataFetcher.value.isEmpty)) {
                    return const CustomAppLoading.chat();
                  }

                  if (snapshot.hasError && (!_chatRx.dataFetcher.hasValue || _chatRx.dataFetcher.value.isEmpty)) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 40.r, color: Colors.grey.shade400),
                          SizedBox(height: 8.h),
                          Text('Failed to load chat messages', style: TextStyle(color: Colors.grey.shade600)),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                            onPressed: () => _chatRx.fetchChatMessages(),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = snapshot.data ?? (_chatRx.dataFetcher.hasValue ? _chatRx.dataFetcher.value : []);
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 52.r, color: Colors.grey.shade400),
                            SizedBox(height: 14.h),
                            Text(
                              'Staff Support Chat',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF151E13),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Send a message below to chat with the Admin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: const Color(0xFF6D7A73), fontSize: 13.sp),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () => _chatRx.fetchChatMessages(),
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[messages.length - 1 - index];
                        // Admin on LEFT (isAdmin = true), Staff / User on RIGHT (isAdmin = false)
                        final bool isAdmin = (msg.sender?.toUpperCase() == 'ADMIN') ||
                            (msg.adminUser != null && msg.sender?.toUpperCase() != 'STAFF');
                        final timeStr = _formatTime(msg.createdAt);
                        final dateStr = msg.createdAt;

                        // Check if we should show date separator
                        bool showDateHeader = false;
                        String dateHeader = '';
                        if (index == messages.length - 1) {
                          showDateHeader = true;
                          dateHeader = _formatDateSeparator(dateStr);
                        } else {
                          final nextMsg = messages[messages.length - 2 - index];
                          final currDate = _formatDateSeparator(dateStr);
                          final nextDate = _formatDateSeparator(nextMsg.createdAt);
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
                                            msg.adminName?.isNotEmpty == true ? msg.adminName! : 'Admin Support',
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
                                      msg.message ?? '',
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
                  );
                },
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
                    onTap: _isSending ? null : _sendMessage,
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
