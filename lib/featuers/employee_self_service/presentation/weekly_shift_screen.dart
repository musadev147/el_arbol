import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../data/rx.dart';
import '../model/get_staff_history_model.dart';

class WeeklyShiftScreen extends StatefulWidget {
  const WeeklyShiftScreen({super.key});

  @override
  State<WeeklyShiftScreen> createState() => _WeeklyShiftScreenState();
}

class _WeeklyShiftScreenState extends State<WeeklyShiftScreen> {
  late GetStaffHistoryRx _historyRx;

  @override
  void initState() {
    super.initState();
    _historyRx = GetStaffHistoryRx(
      empty: GetStaffHistoryModel(),
      dataFetcher: BehaviorSubject<GetStaffHistoryModel>(),
    );
    _historyRx.fetchHistoryData();
  }

  @override
  void dispose() {
    _historyRx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

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
        child: StreamBuilder<GetStaffHistoryModel>(
          stream: _historyRx.valueStreamData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data?.shifts == null) {
              return const Center(child: Text("Could not load shift history"));
            }

            final data = snapshot.data!;
            final shifts = data.shifts!;
            final totalHours = data.totalHours ?? 0.0;

            return Column(
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
                            '${totalHours.toStringAsFixed(1)} Hours',
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
                    itemCount: shifts.length,
                    itemBuilder: (context, index) {
                      final shift = shifts[index];
                      final isOffDay = (shift.status?.toLowerCase() == 'day off') || (shift.status?.toLowerCase() == 'off');
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: isOffDay ? const Color(0xFFF9FAFB) : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isOffDay ? Colors.grey.shade200 : Colors.grey.shade100,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (!isOffDay && shift.storeImage != null && shift.storeImage!.isNotEmpty) ...[
                                    Container(
                                      width: 48.r,
                                      height: 48.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(shift.storeImage!),
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                  ] else if (!isOffDay) ...[
                                    Container(
                                      width: 48.r,
                                      height: 48.r,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.storefront, color: primaryColor, size: 24.r),
                                    ),
                                    SizedBox(width: 12.w),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          shift.date ?? 'Unknown Date',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                            color: isOffDay ? Colors.grey.shade600 : const Color(0xFF151E13),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        if (isOffDay)
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
                                            shift.storeName ?? 'Unknown Store',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Shift: ${shift.startTime ?? ''} - ${shift.endTime ?? ''}',
                                            style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                                          )
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isOffDay && shift.hours != null)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '${shift.hours!.toStringAsFixed(1)} hrs',
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
            );
          }
        ),
      ),
    );
  }
}
