import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'weekly_shift_screen.dart';
import 'request_shift_change_screen.dart';
import 'apply_day_off_screen.dart';
import 'notifications_inbox_screen.dart';
import 'price_list_screen.dart';
import 'update_staff_profile_screen.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../data/rx.dart';
import '../model/staff_dashboard_model.dart';
import 'package:el_arbol/route/app_pages.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  late GetStaffDashboardRx _dashboardRx;
  late StaffCheckInOutRx _checkInOutRx;

  @override
  void initState() {
    super.initState();
    _dashboardRx = GetStaffDashboardRx(
      empty: StaffDashboardModel(),
      dataFetcher: BehaviorSubject<StaffDashboardModel>(),
    );
    _checkInOutRx = StaffCheckInOutRx(empty: null, dataFetcher: BehaviorSubject<dynamic>());
    _dashboardRx.fetchDashboardData();
  }

  @override
  void dispose() {
    _dashboardRx.dispose();
    _checkInOutRx.dispose();
    super.dispose();
  }

  void _handleCheckIn(BuildContext context, List<ActiveStore> activeStores) {
    if (activeStores.length == 1) {
      _performCheckIn(activeStores.first.id!);
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Store to Check In', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                ...activeStores.map((store) => ListTile(
                  title: Text(store.name ?? 'Unknown Store'),
                  subtitle: Text(store.address ?? ''),
                  onTap: () {
                    Get.back();
                    _performCheckIn(store.id!);
                  },
                )).toList(),
              ],
            ),
          );
        }
      );
    }
  }

  void _performCheckIn(int storeId) async {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Store Check-In PIN'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Enter Store PIN (e.g. 45678)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinController.text.trim();
                if (pin.isEmpty) {
                  Fluttertoast.showToast(msg: 'PIN is required');
                  return;
                }
                Navigator.pop(context);
                
                EasyLoading.show(status: 'Checking in...');
                final success = await _checkInOutRx.checkIn(storeId, pin);
                EasyLoading.dismiss();
                if (success) {
                  AppToast.success("Checked in successfully!");
                  _dashboardRx.fetchDashboardData(); // Refresh to update UI
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
              child: const Text('Check In'),
            ),
          ],
        );
      },
    );
  }

  void _handleCheckOut(BuildContext context) async {
    // Assuming the API determines which store to check out of, but we need to pass storeId.
    // If the dashboard returns currentActiveShift, we use its store id.
    final data = _dashboardRx.dataFetcher.value;
    if (data is StaffDashboardModel && data.currentActiveShift != null) {
      EasyLoading.show(status: 'Checking out...');
      final success = await _checkInOutRx.checkOut(Map<String, dynamic>.from(data.currentActiveShift));
      EasyLoading.dismiss();
      if (success) {
        AppToast.success("Checked out successfully!");
        _dashboardRx.fetchDashboardData();
      }
      return;
    }
    AppToast.error("Could not determine active store for check-out.");
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
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
              // Employee info card wrapped in StreamBuilder
              StreamBuilder<StaffDashboardModel>(
                stream: _dashboardRx.valueStreamData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 180.h,
                      child: const CustomAppLoading(message: 'Loading dashboard...'),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data?.profile == null) {
                    return Container(
                      height: 180.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: const Center(child: Text("Could not load dashboard data")),
                    );
                  }

                  final data = snapshot.data!;
                  final profile = data.profile!;
                  final user = profile.user;
                  final name = user?.name ?? 'Unknown';
                  final role = profile.role ?? 'Staff';
                  final staffId = profile.staffId ?? 'N/A';
                  final shiftCount = data.shifts?.length ?? 0;

                  return Container(
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
                                profile.isWorking == true ? 'Working' : 'Active',
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
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '$role  •  MEM-$staffId',
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
                                  '$shiftCount Days Assigned',
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
                                  '-- hrs',
                                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }
              ),
              SizedBox(height: 24.h),

              // Check In / Check Out Section
              StreamBuilder(
                stream: _dashboardRx.valueStreamData,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data is StaffDashboardModel) {
                    final profile = data.profile;
                    final isWorking = profile?.isWorking == true;
                    final activeStores = data.activeStores ?? [];
                    
                    return Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Attendance',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF151E13),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          if (data.hasCompletedShiftToday == true)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: const Center(
                                child: Text('Shift Completed for Today', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            )
                          else if (isWorking)
                            SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: ElevatedButton.icon(
                                onPressed: () => _handleCheckOut(context),
                                icon: const Icon(Icons.logout, color: Colors.white),
                                label: const Text('Check Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: ElevatedButton.icon(
                                onPressed: activeStores.isEmpty ? null : () => _handleCheckIn(context, activeStores),
                                icon: const Icon(Icons.login, color: Colors.white),
                                label: Text(activeStores.isEmpty ? 'No Active Shifts' : 'Check In', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00694C),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                }
              ),
              SizedBox(height: 24.h),              Text(
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
                title: 'My Daily Tasks',
                subtitle: 'View and mark assigned tasks as completed',
                icon: Icons.checklist_rtl_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFFA855F7),
                onTap: () => Get.toNamed(Routes.STAFF_TASKS_SCREEN) ?? Get.to(() => const SizedBox()), // Placeholder for now until routing is set
              ),
              SizedBox(height: 12.h),
              _buildListActionCard(
                context,
                title: 'My Colleagues',
                subtitle: 'View staff directory for assigned stores',
                icon: Icons.people_alt_rounded,
                iconBg: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0EA5E9),
                onTap: () => Get.toNamed(Routes.STAFF_COLLEAGUES_SCREEN) ?? Get.to(() => const SizedBox()),
              ),
              SizedBox(height: 12.h),
              _buildListActionCard(
                context,
                title: 'Order History',
                subtitle: 'View all your processed orders',
                icon: Icons.history_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                onTap: () => Get.toNamed(Routes.STAFF_ORDER_HISTORY_SCREEN) ?? Get.to(() => const SizedBox()),
              ),
              SizedBox(height: 12.h),
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
