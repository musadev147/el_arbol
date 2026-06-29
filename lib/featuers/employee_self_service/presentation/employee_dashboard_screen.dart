import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'weekly_shift_screen.dart';
import 'request_shift_change_screen.dart';
import 'apply_day_off_screen.dart';
import 'notifications_inbox_screen.dart';
import 'price_list_screen.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    const Color cardColor = Colors.white;
    const Color backgroundColor = Color(0xFFFAFAF8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Self-Service',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF151E13)),
            onPressed: () => Get.to(() => const NotificationsInboxScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee info card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, Color(0xFF004D38)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MEMBER PORTAL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Sofia Rossi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Floor Assistant  •  MEM-8902',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.sp,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WEEKLY SHIFTS',
                              style: TextStyle(color: Colors.white60, fontSize: 10.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '5 Days Assigned',
                              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'EST. HOURS',
                              style: TextStyle(color: Colors.white60, fontSize: 10.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '37.5 hrs (Net)',
                              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                'My Self-Service Actions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF151E13),
                ),
              ),
              SizedBox(height: 14.h),

              // Actions Menu list
              _buildListActionCard(
                context,
                title: 'Weekly Shifts & Hours',
                subtitle: 'Assigned stores, times, and break details',
                icon: Icons.calendar_view_week_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                onTap: () => Get.to(() => const WeeklyShiftScreen()),
              ),
              SizedBox(height: 12.h),
              _buildListActionCard(
                context,
                title: 'Request Shift Change',
                subtitle: 'Submit shift modification requests to admin',
                icon: Icons.edit_calendar_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                onTap: () => Get.to(() => const RequestShiftChangeScreen()),
              ),
              SizedBox(height: 12.h),
              _buildListActionCard(
                context,
                title: 'Apply for Day Off',
                subtitle: 'Schedule an extra day off from work',
                icon: Icons.event_busy_rounded,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
                onTap: () => Get.to(() => const ApplyDayOffScreen()),
              ),
              SizedBox(height: 12.h),
              _buildListActionCard(
                context,
                title: 'Notifications Inbox',
                subtitle: 'Price alerts, management news, & direct messages',
                icon: Icons.all_inbox_rounded,
                iconBg: const Color(0xFFEEF2F6),
                iconColor: const Color(0xFF64748B),
                onTap: () => Get.to(() => const NotificationsInboxScreen()),
              ),
              SizedBox(height: 12.h),
              _buildListActionCard(
                context,
                title: 'Product Price List',
                subtitle: 'View A-Z product catalog pricing sheets',
                icon: Icons.sell_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF10B981),
                onTap: () => Get.to(() => const PriceListScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade100, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6D7A73),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20.r),
          ],
        ),
      ),
    );
  }
}
