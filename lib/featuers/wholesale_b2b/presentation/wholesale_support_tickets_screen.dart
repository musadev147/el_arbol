import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:el_arbol/featuers/wholesale_b2b/presentation/wholesale_single_ticket_screen.dart';

class WholesaleSupportTicketsScreen extends StatefulWidget {
  const WholesaleSupportTicketsScreen({super.key});

  @override
  State<WholesaleSupportTicketsScreen> createState() => _WholesaleSupportTicketsScreenState();
}

class _WholesaleSupportTicketsScreenState extends State<WholesaleSupportTicketsScreen> {
  late WholesaleTicketsRx _rx;

  @override
  void initState() {
    super.initState();
    _rx = WholesaleTicketsRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Create Support Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 4,
              ),
            ],
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
                
                final success = await _rx.createTicket({
                  "subject": subjectController.text,
                  "description": messageController.text,
                });
                
                if (success) {
                  Fluttertoast.showToast(msg: 'Ticket created');
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
              child: const Text('Submit'),
            ),
          ],
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
                    Get.to(() => WholesaleSingleTicketScreen(
                      ticketId: ticket['id']?.toString() ?? '',
                      ticketSubject: ticket['subject'] ?? 'Ticket',
                    ));
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
