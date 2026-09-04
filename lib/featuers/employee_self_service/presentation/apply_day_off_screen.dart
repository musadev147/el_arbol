import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../data/rx.dart';
import 'package:rxdart/rxdart.dart';

class ApplyDayOffScreen extends StatefulWidget {
  const ApplyDayOffScreen({super.key});

  @override
  State<ApplyDayOffScreen> createState() => _ApplyDayOffScreenState();
}

class _ApplyDayOffScreenState extends State<ApplyDayOffScreen> {
  DateTime? _selectedDate;
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    _reasonController.dispose();
    _rx.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitRequest() async {
    if (_selectedDate == null) {
      Get.snackbar('Error', 'Please select a date from the calendar.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final success = await _rx.createRequest(dateStr, _reasonController.text.trim());
      
      if (success) {
        setState(() {
          _selectedDate = null;
          _reasonController.clear();
        });
      }
    }
  }

  void _confirmDelete(String id) {
    if (id.isEmpty) return;
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
                'Cancel Day Off Request?',
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
                'Are you sure you want to cancel this day off request? This action cannot be undone.',
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
                        await _rx.deleteRequest(id);
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'Apply for Day Off',
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
                  // Date picker trigger button
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, color: primaryColor),
                              SizedBox(width: 12.w),
                              Text(
                                _selectedDate == null
                                    ? 'Select Date from Calendar'
                                    : DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                                  color: _selectedDate == null ? Colors.grey.shade600 : const Color(0xFF151E13),
                                ),
                              )
                            ],
                          ),
                          Text(
                            'Choose',
                            style: TextStyle(color: primaryColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Text(
                    'Reason / Additional Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter reason for this day off request...',
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
                        return 'Please provide a reason';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

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
                        'Apply Now',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),
                  Text(
                    'Your Day Off Applications',
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
                        return const CustomAppLoading(message: 'Loading day off applications...');
                      }

                      final rawData = snapshot.data;
                      List<dynamic> allRequests = [];
                      if (rawData is List) {
                        allRequests = rawData;
                      } else if (rawData is Map && rawData['results'] is List) {
                        allRequests = rawData['results'] as List;
                      }

                      if (allRequests.isEmpty) {
                        return NoInternetOrDataWidget(
                          title: 'No Applications Found',
                          message: 'You have not submitted any day off requests.',
                          onRetry: () => _rx.fetchDayOffRequests(),
                          isFullPage: false,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allRequests.length,
                        itemBuilder: (context, index) {
                          final req = allRequests[index] is Map ? allRequests[index] as Map : {};
                          final id = req['id']?.toString() ?? '';
                          final dateStr = req['date'] ?? '';
                          DateTime parsedDate;
                          try {
                            parsedDate = DateTime.parse(dateStr);
                          } catch (_) {
                            parsedDate = DateTime.now();
                          }
                          final reason = req['reason'] ?? '';
                          final status = (req['status'] ?? 'Pending').toString();

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, MMM dd, yyyy').format(parsedDate),
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF151E13),
                                        ),
                                      ),
                                      if (reason.isNotEmpty) ...[
                                        SizedBox(height: 4.h),
                                        Text(
                                          reason,
                                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: status.toLowerCase() == 'approved'
                                            ? Colors.green.withOpacity(0.1)
                                            : status.toLowerCase() == 'rejected'
                                                ? Colors.red.withOpacity(0.1)
                                                : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: status.toLowerCase() == 'approved'
                                              ? Colors.green
                                              : status.toLowerCase() == 'rejected'
                                                  ? Colors.red
                                                  : Colors.orange,
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
