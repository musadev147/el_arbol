import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ShiftDay {
  final String dayName;
  final String dateStr;
  final String shopName;
  final String startTime;
  final String endTime;
  final double breakMinutes; // e.g. 30.0 mins
  final bool isOffDay;

  ShiftDay({
    required this.dayName,
    required this.dateStr,
    required this.shopName,
    required this.startTime,
    required this.endTime,
    required this.breakMinutes,
    this.isOffDay = false,
  });

  // Calculate Net Working Hours for this day
  double get netHours {
    if (isOffDay) return 0.0;
    try {
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);
      final diffMins = end.difference(start).inMinutes;
      final netMins = diffMins - breakMinutes;
      return netMins > 0 ? netMins / 60.0 : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2026, 1, 1, hour, minute);
  }
}

class WeeklyShiftScreen extends StatelessWidget {
  const WeeklyShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    final List<ShiftDay> weeklyShifts = [
      ShiftDay(dayName: 'Monday', dateStr: 'June 29', shopName: 'Shop Valencia-04', startTime: '08:00', endTime: '16:30', breakMinutes: 30.0),
      ShiftDay(dayName: 'Tuesday', dateStr: 'June 30', shopName: 'Shop Valencia-04', startTime: '08:00', endTime: '16:30', breakMinutes: 30.0),
      ShiftDay(dayName: 'Wednesday', dateStr: 'July 01', shopName: 'Shop Valencia-04', startTime: '08:00', endTime: '16:30', breakMinutes: 30.0),
      ShiftDay(dayName: 'Thursday', dateStr: 'July 02', shopName: 'Shop Valencia-04', startTime: '08:00', endTime: '16:30', breakMinutes: 30.0),
      ShiftDay(dayName: 'Friday', dateStr: 'July 03', shopName: 'Shop Valencia-04', startTime: '08:00', endTime: '16:30', breakMinutes: 30.0),
      ShiftDay(dayName: 'Saturday', dateStr: 'July 04', shopName: '', startTime: '', endTime: '', breakMinutes: 0.0, isOffDay: true),
      ShiftDay(dayName: 'Sunday', dateStr: 'July 05', shopName: '', startTime: '', endTime: '', breakMinutes: 0.0, isOffDay: true),
    ];

    // Compute weekly total hours
    final double totalNetHours = weeklyShifts.fold(0.0, (sum, day) => sum + day.netHours);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'Weekly Shifts',
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
        child: Column(
          children: [
            // Hours Calculation Card Header
            Container(
              margin: EdgeInsets.all(20.r),
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY TOTAL HOURS',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${totalNetHours.toStringAsFixed(1)} Hours',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.timelapse_rounded, color: primaryColor, size: 28.r),
                  )
                ],
              ),
            ),

            // Daily shifts list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: weeklyShifts.length,
                itemBuilder: (context, index) {
                  final day = weeklyShifts[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: day.isOffDay ? const Color(0xFFF9FAFB) : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: day.isOffDay ? Colors.grey.shade200 : Colors.grey.shade100,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${day.dayName}, ${day.dateStr}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: day.isOffDay ? Colors.grey.shade600 : const Color(0xFF151E13),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (day.isOffDay)
                              Text(
                                'Day Off',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else ...[
                              Text(
                                day.shopName,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Shift: ${day.startTime} - ${day.endTime}  (Break: ${day.breakMinutes.toInt()}m)',
                                style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                              )
                            ]
                          ],
                        ),
                        if (!day.isOffDay)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${day.netHours.toStringAsFixed(1)} hrs',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          )
                      ],
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
