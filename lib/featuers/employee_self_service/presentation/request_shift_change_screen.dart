import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../data/rx.dart';

class RequestShiftChangeScreen extends StatefulWidget {
  const RequestShiftChangeScreen({super.key});

  @override
  State<RequestShiftChangeScreen> createState() => _RequestShiftChangeScreenState();
}

class _RequestShiftChangeScreenState extends State<RequestShiftChangeScreen> {
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final StaffDayOffRequestsRx _rx = StaffDayOffRequestsRx(
    empty: [],
    dataFetcher: BehaviorSubject<dynamic>(),
  );

  @override
  void initState() {
    super.initState();
    _rx.fetchDayOffRequests();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _rx.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00694C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF151E13),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final reason = _noteController.text.trim();

      final success = await _rx.createRequest(dateStr, reason);
      if (success) {
        _noteController.clear();
      }
    }
  }

  void _confirmDelete(String id) {
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
                'Cancel Shift Request?',
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
                'Are you sure you want to cancel this shift change request? This action cannot be undone.',
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
                      onPressed: () {
                        Navigator.pop(ctx);
                        _rx.deleteRequest(id);
                      },
                      child: Text(
                        'Yes, Cancel',
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

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'approved') return Colors.green;
    if (s == 'rejected' || s == 'declined') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'Request Shift Change',
          style: TextStyle(
            color: const Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF151E13)),
            onPressed: () => _rx.fetchDayOffRequests(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () => _rx.fetchDayOffRequests(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Box
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Select the target date and write a note requesting a shift change or day off. Management will review and update your schedule.',
                            style: TextStyle(fontSize: 12.sp, color: Colors.blue.shade900, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Date Picker Section
                  Text(
                    'Target Date',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: primaryColor, size: 18),
                              SizedBox(width: 10.w),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF151E13)),
                              ),
                            ],
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Shift Modification Note
                  Text(
                    'Shift Modification Note',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe details of your request (e.g. shift swap, preferred hours, reason)...',
                      hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please write your request reason or details';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit Request',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),
                  Text(
                    'Request History',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  StreamBuilder<dynamic>(
                    stream: _rx.valueStreamData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CustomAppLoading(message: 'Loading request history...');
                      }

                      if (snapshot.hasError) {
                        return NoInternetOrDataWidget(
                          title: 'Failed to Load History',
                          message: 'Could not fetch shift change requests. Please check your internet connection.',
                          onRetry: () => _rx.fetchDayOffRequests(),
                          isFullPage: false,
                        );
                      }

                      final List<dynamic> requests = (snapshot.data is List) ? (snapshot.data as List) : [];

                      if (requests.isEmpty) {
                        return NoInternetOrDataWidget(
                          title: 'No Shift Requests Yet',
                          message: 'You have not submitted any shift change requests.',
                          isFullPage: false,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final req = requests[index] is Map ? requests[index] as Map : {};
                          final id = req['id']?.toString() ?? '';
                          final date = req['date']?.toString() ?? 'N/A';
                          final reason = req['reason']?.toString() ?? req['note']?.toString() ?? '';
                          final status = req['status']?.toString() ?? 'Pending';
                          final statusColor = _getStatusColor(status);

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.event, size: 16.r, color: primaryColor),
                                        SizedBox(width: 6.w),
                                        Text(
                                          date,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: const Color(0xFF151E13),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                        if (status.toLowerCase() == 'pending' && id.isNotEmpty) ...[
                                          SizedBox(width: 8.w),
                                          Material(
                                            color: const Color(0xFFFEECEB),
                                            borderRadius: BorderRadius.circular(8.r),
                                            child: InkWell(
                                              onTap: () => _confirmDelete(id),
                                              borderRadius: BorderRadius.circular(8.r),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8.r),
                                                  border: Border.all(
                                                    color: const Color(0xFFFCA5A5).withOpacity(0.6),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.delete_outline_rounded,
                                                      color: Color(0xFFDC2626),
                                                      size: 14,
                                                    ),
                                                    SizedBox(width: 3.w),
                                                    Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        color: const Color(0xFFDC2626),
                                                        fontSize: 10.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                if (reason.isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Text(
                                    reason,
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800, height: 1.3),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
