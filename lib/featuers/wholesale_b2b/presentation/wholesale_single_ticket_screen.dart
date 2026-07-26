import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  @override
  void initState() {
    super.initState();
    _rx = WholesaleSingleTicketRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
    _rx.fetchSingleTicket(widget.ticketId);
  }

  @override
  void dispose() {
    _rx.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() async {
    final message = _replyController.text.trim();
    if (message.isEmpty) {
      Fluttertoast.showToast(msg: 'Reply cannot be empty');
      return;
    }

    final success = await _rx.replyToTicket(widget.ticketId, message);
    if (success) {
      _replyController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.ticketSubject, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text("Failed to load ticket"));
          }

          final ticketData = data is Map ? data : {};
          final List<dynamic> replies = ticketData['replies'] ?? [];
          
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: replies.length + 1, // +1 for the original message
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Original Ticket Message
                      return _buildMessageBubble(
                        message: ticketData['message'] ?? '',
                        sender: 'You',
                        date: ticketData['created_at'] ?? '',
                        isMe: true,
                        primaryColor: primaryColor,
                      );
                    }
                    
                    final reply = replies[index - 1];
                    final isMe = reply['user_role'] == 'wholesale'; // simple check
                    
                    return _buildMessageBubble(
                      message: reply['message'] ?? '',
                      sender: isMe ? 'You' : 'Support',
                      date: reply['created_at'] ?? '',
                      isMe: isMe,
                      primaryColor: primaryColor,
                    );
                  },
                ),
              ),
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
