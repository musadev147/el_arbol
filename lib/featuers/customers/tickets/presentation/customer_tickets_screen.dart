import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../data/customer_tickets_rx.dart';
import 'customer_ticket_chat_screen.dart';

class CustomerSupportTicketsScreen extends StatefulWidget {
  const CustomerSupportTicketsScreen({super.key});

  @override
  State<CustomerSupportTicketsScreen> createState() => _CustomerSupportTicketsScreenState();
}

class _CustomerSupportTicketsScreenState extends State<CustomerSupportTicketsScreen> {
  late CustomerTicketsRx _rx;

  @override
  void initState() {
    super.initState();
    _rx = CustomerTicketsRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _rx.fetchTickets();
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  void _createTicket() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String category = 'ORDER';
    String priority = 'LOW';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              title: const Text('Create Support Ticket'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: messageController,
                      decoration: const InputDecoration(labelText: 'Message / Description'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'ORDER', child: Text('Order Issue')),
                        DropdownMenuItem(value: 'GENERAL', child: Text('General Inquiry')),
                        DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => category = val);
                      },
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: 'LOW', child: Text('Low')),
                        DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                        DropdownMenuItem(value: 'HIGH', child: Text('High')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => priority = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (subjectController.text.isEmpty || messageController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Please fill all fields');
                      return;
                    }
                    
                    final success = await _rx.createTicket(
                      subjectController.text,
                      messageController.text,
                      category: category,
                      priority: priority,
                    );
                    
                    if (success) {
                      Fluttertoast.showToast(msg: 'Ticket created');
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Support Tickets', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTicket,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Ticket', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final data = snapshot.data;
          
          List<dynamic> tickets = [];
          if (data is Map && data['results'] is List) {
            tickets = data['results'] as List;
          } else if (data is List) {
            tickets = data;
          }
          
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent, size: 64.r, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text('No tickets found', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.r),
                  onTap: () {
                    Get.to(() => CustomerTicketChatScreen(ticket: ticket));
                  },
                  title: Text(ticket['subject'] ?? 'Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Text('Status: ${ticket['status'] ?? 'Open'}', style: TextStyle(fontSize: 12.sp, color: primaryColor, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8.h),
                      Text(ticket['created_at'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
