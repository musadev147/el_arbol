import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
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

  void _confirmDeleteTicket(String ticketId) {
    if (ticketId.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEECEB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFCA5A5).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 32,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Delete Support Ticket?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF151E13),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to delete this support ticket? This conversation will be permanently removed.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: Colors.grey.shade50,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Keep',
                        style: TextStyle(
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _rx.deleteTicket(ticketId);
                      },
                      child: Text(
                        'Yes, Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createTicket() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String category = 'ORDER';
    String priority = 'HIGH';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              titlePadding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              actionsPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Support Ticket',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFF0F1F3), height: 1, thickness: 1),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: subjectController,
                        decoration: InputDecoration(
                          labelText: 'Subject *',
                          hintText: 'e.g. Order delivery or catalog issue',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFF00694C)),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          labelText: 'Message / Description *',
                          hintText: 'Describe your issue in detail',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFF00694C)),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFF00694C)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ORDER', child: Text('Order Issue')),
                          DropdownMenuItem(value: 'PAYMENT', child: Text('Payment / Billing')),
                          DropdownMenuItem(value: 'GENERAL', child: Text('General Inquiry')),
                          DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => category = val);
                        },
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFF00694C)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'LOW', child: Text('Low')),
                          DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                          DropdownMenuItem(value: 'HIGH', child: Text('High')),
                          DropdownMenuItem(value: 'URGENT', child: Text('Urgent')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => priority = val);
                        },
                      ),
                      SizedBox(height: 8.h),
                      const Divider(color: Color(0xFFF0F1F3), height: 1, thickness: 1),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final subject = subjectController.text.trim();
                    final message = messageController.text.trim();

                    if (subject.isEmpty || message.isEmpty) {
                      Fluttertoast.showToast(msg: 'Please fill in both Subject and Message');
                      return;
                    }
                    
                    final success = await _rx.createTicket({
                      "subject": subject,
                      "title": subject,
                      "description": message,
                      "message": message,
                      "category": category,
                      "priority": priority,
                    });
                    
                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00694C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _rx.fetchTickets(),
            tooltip: 'Refresh',
          ),
        ],
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
            return const CustomAppLoading(message: 'Loading tickets...');
          }
          final data = snapshot.data;
          
          List<dynamic> tickets = [];
          if (data is Map) {
            if (data['results'] is List) {
              tickets = data['results'] as List;
            } else if (data['data'] is List) {
              tickets = data['data'] as List;
            } else if (data['tickets'] is List) {
              tickets = data['tickets'] as List;
            }
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
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: _createTicket,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Create First Ticket', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final ticketId = ticket['id']?.toString() ?? '';
              final subject = ticket['subject'] ?? ticket['title'] ?? 'Ticket #$ticketId';
              final status = ticket['status'] ?? 'Open';
              final createdAt = ticket['created_at'] ?? ticket['date'] ?? '';

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  onTap: () {
                    Get.to(() => WholesaleSingleTicketScreen(
                      ticketId: ticketId,
                      ticketSubject: subject,
                    ));
                  },
                  title: Text(
                    subject,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(fontSize: 11.sp, color: primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (createdAt.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Text(createdAt, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: Material(
                    color: const Color(0xFFFEECEB),
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: () => _confirmDeleteTicket(ticketId),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFFCA5A5).withOpacity(0.5),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                      ),
                    ),
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
