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
    if (text.isEmpty) return;

    _messageController.clear();

    // Optimistic local UI update so staff sees message right away
    final optimisticMsg = StaffChatMessage(
      message: text,
      sender: 'STAFF',
      createdAt: DateTime.now().toIso8601String(),
    );
    final currentList = _chatRx.dataFetcher.hasValue ? _chatRx.dataFetcher.value : <StaffChatMessage>[];
    _chatRx.dataFetcher.sink.add(List<StaffChatMessage>.from(currentList)..add(optimisticMsg));
    _scrollToBottom(immediate: true, force: true);

    final success = await _chatRx.sendMessage(text);
    if (success) {
      _scrollToBottom(force: true);
      _chatRx.fetchChatMessages(silent: true);
    } else {
      AppToast.error('Failed to send message. Please try again.');
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (_) {
      return '';
    }
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
              'Chatting with Administrator',
              style: TextStyle(
                color: const Color(0xFF6D7A73),
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
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
                          Icon(Icons.error_outline, size: 40.r, color: Colors.grey),
                          SizedBox(height: 8.h),
                          const Text('Failed to load chat messages'),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 48.r, color: Colors.grey.shade400),
                          SizedBox(height: 12.h),
                          Text(
                            'No messages yet.\nSend a message to start chatting with Admin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () => _chatRx.fetchChatMessages(),
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.all(16.r),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[messages.length - 1 - index];
                        // Message is from staff (me) if sender is STAFF or adminUser is null and sender is not ADMIN
                        final isMe = (msg.sender?.toUpperCase() == 'STAFF') ||
                            (msg.adminUser == null && msg.sender?.toUpperCase() != 'ADMIN');

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
                                        msg.adminName?.isNotEmpty == true ? msg.adminName! : 'Admin Support',
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
                                  msg.message ?? '',
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
                                      _formatTime(msg.createdAt),
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
                  );
                },
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
