import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DayOffRequest {
  final DateTime date;
  final String reason;
  final String status;

  DayOffRequest({required this.date, required this.reason, required this.status});
}

class ApplyDayOffScreen extends StatefulWidget {
  const ApplyDayOffScreen({super.key});

  @override
  State<ApplyDayOffScreen> createState() => _ApplyDayOffScreenState();
}

class _ApplyDayOffScreenState extends State<ApplyDayOffScreen> {
  DateTime? _selectedDate;
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<DayOffRequest> _requests = [
    DayOffRequest(
      date: DateTime.now().add(const Duration(days: 10)),
      reason: 'Family gathering event.',
      status: 'Approved',
    ),
    DayOffRequest(
      date: DateTime.now().add(const Duration(days: 15)),
      reason: 'Personal errands.',
      status: 'Pending',
    )
  ];

  @override
  void dispose() {
    _reasonController.dispose();
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

  void _submitRequest() {
    if (_selectedDate == null) {
      Get.snackbar('Error', 'Please select a date from the calendar.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _requests.insert(
          0,
          DayOffRequest(
            date: _selectedDate!,
            reason: _reasonController.text,
            status: 'Pending',
          ),
        );
        _selectedDate = null;
        _reasonController.clear();
      });

      Get.snackbar(
        'Application Submitted',
        'Your day off request has been sent for admin approval.',
        backgroundColor: const Color(0xFF00694C),
        colorText: Colors.white,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMM dd, yyyy').format(req.date),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF151E13),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                req.reason,
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: req.status == 'Approved'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              req.status,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: req.status == 'Approved' ? Colors.green : Colors.orange,
                              ),
                            ),
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
