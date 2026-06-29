import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ShiftChangeRequest {
  final String dateStr;
  final String note;
  final String status; // 'Pending', 'Approved', 'Rejected'

  ShiftChangeRequest({required this.dateStr, required this.note, required this.status});
}

class RequestShiftChangeScreen extends StatefulWidget {
  const RequestShiftChangeScreen({super.key});

  @override
  State<RequestShiftChangeScreen> createState() => _RequestShiftChangeScreenState();
}

class _RequestShiftChangeScreenState extends State<RequestShiftChangeScreen> {
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<ShiftChangeRequest> _requestHistory = [
    ShiftChangeRequest(
      dateStr: '2026-06-25',
      note: 'Request to swap Thursday shift with Saturday floor cover.',
      status: 'Approved',
    ),
    ShiftChangeRequest(
      dateStr: '2026-06-12',
      note: 'Need to start Friday shift at 10:00 AM instead of 08:00 AM due to doctor appointment.',
      status: 'Approved',
    )
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _requestHistory.insert(
          0,
          ShiftChangeRequest(
            dateStr: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            note: _noteController.text,
            status: 'Pending',
          ),
        );
        _noteController.clear();
      });

      Get.snackbar(
        'Request Submitted',
        'Your shift change request was sent to the Admin Control Panel.',
        backgroundColor: const Color(0xFF00694C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          'Write a note requesting shift changes. Management will review and update your schedule from the control panel.',
                          style: TextStyle(fontSize: 12.sp, color: Colors.blue.shade900, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

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
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Describe details of your request (e.g. date to change, shift times, preferred hours, reason)...',
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
                      return 'Please write your request note';
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

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _requestHistory.length,
                  itemBuilder: (context, index) {
                    final req = _requestHistory[index];
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
                              Text(
                                req.dateStr,
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: req.status == 'Approved'
                                      ? Colors.green.withOpacity(0.1)
                                      : req.status == 'Pending'
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  req.status,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: req.status == 'Approved'
                                        ? Colors.green
                                        : req.status == 'Pending'
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            req.note,
                            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF151E13), height: 1.3),
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
