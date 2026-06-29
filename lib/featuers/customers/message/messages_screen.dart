import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'El Árbol Store Support',
      'lastMessage': 'We are preparing your Click & Collect order now.',
      'time': '10:45 AM',
      'unread': true,
      'avatarColor': const Color(0xFF00694C),
      'avatarIcon': Icons.store,
      'messages': [
        {'text': 'Hello! Welcome to El Árbol support.', 'isMe': false},
        {'text': 'I have a question about my Click & Collect order.', 'isMe': true},
        {'text': 'Sure, go ahead! We are preparing your Click & Collect order now.', 'isMe': false},
      ],
    },
    {
      'name': 'Delivery Partner (Carlos)',
      'lastMessage': 'I am on my way to your location.',
      'time': 'Yesterday',
      'unread': false,
      'avatarColor': Colors.blue,
      'avatarIcon': Icons.directions_bike,
      'messages': [
        {'text': 'Hi, I will be delivering your organic items soon.', 'isMe': false},
        {'text': 'Great, thank you!', 'isMe': true},
        {'text': 'I am on my way to your location.', 'isMe': false},
      ],
    },
    {
      'name': 'System Alerts',
      'lastMessage': 'Surplus leftover packs listed nearby!',
      'time': '2 days ago',
      'unread': false,
      'avatarColor': Colors.amber,
      'avatarIcon': Icons.notifications_active,
      'messages': [
        {'text': 'New discounts and surplus leftover packs listed nearby!', 'isMe': false},
      ],
    },
  ];

  void _openChatDetail(Map<String, dynamic> chat) {
    final messageController = TextEditingController();
    final scrollController = ScrollController();

    setState(() {
      chat['unread'] = false;
    });

    Get.to(() => Scaffold(
          backgroundColor: const Color(0xFFFAFAF8),
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: chat['avatarColor'].withOpacity(0.1),
                  child: Icon(chat['avatarIcon'], color: chat['avatarColor'], size: 20.r),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    chat['name'],
                    style: TextStyle(
                      color: const Color(0xFF151E13),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
              onPressed: () => Get.back(),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setChatState) {
                    final List<Map<String, dynamic>> msgs = chat['messages'];
                    
                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(16.r),
                      itemCount: msgs.length,
                      itemBuilder: (context, index) {
                        final m = msgs[index];
                        final bool isMe = m['isMe'];

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF00694C) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.r),
                                topRight: Radius.circular(12.r),
                                bottomLeft: isMe ? Radius.circular(12.r) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : Radius.circular(12.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: Text(
                              m['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Message Input panel
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        if (messageController.text.isNotEmpty) {
                          final text = messageController.text;
                          setState(() {
                            chat['messages'].add({'text': text, 'isMe': true});
                            chat['lastMessage'] = text;
                            chat['time'] = 'Just now';
                          });
                          messageController.clear();
                          
                          // Auto scroll to bottom
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (scrollController.hasClients) {
                              scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                            }
                          });

                          // Mock response
                          Future.delayed(const Duration(milliseconds: 1500), () {
                            setState(() {
                              chat['messages'].add({
                                'text': 'Thanks for contacting us! An agent will connect shortly.',
                                'isMe': false
                              });
                              chat['lastMessage'] = 'Thanks for contacting us!';
                              chat['time'] = 'Just now';
                            });
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00694C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  final bool isUnread = chat['unread'] == true;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ListTile(
                      onTap: () => _openChatDetail(chat),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: chat['avatarColor'].withOpacity(0.1),
                            child: Icon(chat['avatarIcon'], color: chat['avatarColor']),
                          ),
                          if (isUnread)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        chat['name'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14.sp,
                          color: const Color(0xFF151E13),
                        ),
                      ),
                      subtitle: Text(
                        chat['lastMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isUnread ? const Color(0xFF151E13) : Colors.grey,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: Text(
                        chat['time'],
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
