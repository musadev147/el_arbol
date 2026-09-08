import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'weekly_shift_screen.dart';
import 'request_shift_change_screen.dart';
import 'apply_day_off_screen.dart';
import 'notifications_inbox_screen.dart';
import 'price_list_screen.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/app_shimmer.dart';
import '../data/rx.dart';
import '../model/staff_dashboard_model.dart';
import 'package:el_arbol/route/app_pages.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import 'package:el_arbol/helpers/di.dart';
import '../../wholesale_b2b/presentation/wholesale_add_product_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  late GetStaffDashboardRx _dashboardRx;
  late StaffCheckInOutRx _checkInOutRx;
  int? _selectedStoreFilterId;

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

  bool _isStoreOpen(ActiveStore store) {
    if (store.isActive == false) return false;
    if (store.openTime != null && store.closeTime != null) {
      try {
        final now = DateTime.now();
        final openParts = store.openTime!.split(':').map(int.parse).toList();
        final closeParts = store.closeTime!.split(':').map(int.parse).toList();
        final openDateTime = DateTime(now.year, now.month, now.day, openParts[0], openParts[1]);
        final closeDateTime = DateTime(now.year, now.month, now.day, closeParts[0], closeParts[1]);
        return now.isAfter(openDateTime) && now.isBefore(closeDateTime);
      } catch (_) {}
    }
    return store.isActive ?? true;
  }

  double _calculateShiftHours(StaffShift shift) {
    if (shift.startTime == null || shift.endTime == null) return 0.0;
    try {
      final startParts = shift.startTime!.split(':').map(int.parse).toList();
      final endParts = shift.endTime!.split(':').map(int.parse).toList();
      double startHours = startParts[0] + (startParts.length > 1 ? startParts[1] / 60.0 : 0.0);
      double endHours = endParts[0] + (endParts.length > 1 ? endParts[1] / 60.0 : 0.0);
      if (endHours < startHours) {
        endHours += 24.0; // Overnight shift
      }
      double total = endHours - startHours;
      if (shift.breakDurationMinutes != null && shift.breakDurationMinutes! > 0) {
        total -= (shift.breakDurationMinutes! / 60.0);
      }
      return total > 0 ? total : 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  double _getCalculatedTotalHours(List<StaffShift>? shifts, int? storeFilterId) {
    if (shifts == null || shifts.isEmpty) return 0.0;
    double total = 0.0;
    for (final shift in shifts) {
      if (storeFilterId != null) {
        if (shift.store != storeFilterId) continue;
      }
      total += _calculateShiftHours(shift);
    }
    return total;
  }

  String _resolveStoreImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    String cleanUrl = url.trim();
    if (cleanUrl.startsWith('http://')) {
      cleanUrl = cleanUrl.replaceFirst('http://', 'https://');
    } else if (cleanUrl.startsWith('/')) {
      cleanUrl = 'https://apielarbol.icommerce.com.bd$cleanUrl';
    }
    return cleanUrl;
  }

  Widget _buildStoreImage(String? imageUrl, {double size = 46}) {
    final cleanUrl = _resolveStoreImageUrl(imageUrl);
    if (cleanUrl.isEmpty) {
      return Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: const Color(0xFF00694C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.storefront_rounded, color: const Color(0xFF00694C), size: (size * 0.55).sp),
      );
    }

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.r),
        child: CachedNetworkImage(
          imageUrl: cleanUrl,
          width: size.w,
          height: size.w,
          fit: BoxFit.cover,
          placeholder: (context, url) => AppShimmer.box(
            width: size.w,
            height: size.w,
            borderRadius: BorderRadius.circular(12.r),
          ),
          errorWidget: (context, url, error) => Container(
            color: const Color(0xFF00694C).withValues(alpha: 0.1),
            child: Icon(Icons.storefront_rounded, color: const Color(0xFF00694C), size: (size * 0.55).sp),
          ),
        ),
      ),
    );
  }

  void _handleCheckIn(BuildContext context, List<ActiveStore> activeStores) {
    if (activeStores.length == 1) {
      _performCheckIn(activeStores.first);
    } else {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Store to Check In', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                SizedBox(height: 16.h),
                ...activeStores.map((store) {
                  final isOpen = _isStoreOpen(store);
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    leading: _buildStoreImage(store.image, size: 48),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name ?? 'Unknown Store',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: isOpen ? Colors.green.shade200 : Colors.red.shade200),
                          ),
                          child: Text(
                            isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      store.hours != null ? 'Hours: ${store.hours}' : (store.address ?? ''),
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                    onTap: () {
                      Get.back();
                      _performCheckIn(store);
                    },
                  );
                }),
              ],
            ),
          );
        },
      );
    }
  }

  void _performCheckIn(ActiveStore store) async {
    final pinController = TextEditingController();
    final isOpen = _isStoreOpen(store);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStoreImage(store.image, size: 42),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      store.name ?? 'Store Check-In',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (store.city != null || store.address != null)
                      Text(
                        store.city ?? store.address ?? '',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: isOpen ? Colors.green.shade300 : Colors.red.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 4.r,
                      backgroundColor: isOpen ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: isOpen ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.hours != null || (store.openTime != null && store.closeTime != null)) ...[
                Text(
                  'Hours: ${store.hours ?? "${store.openTime} - ${store.closeTime}"}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 12.h),
              ],
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Store PIN (e.g. 45678)',
                  border: OutlineInputBorder(),
                ),
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
                final pin = pinController.text.trim();
                if (pin.isEmpty) {
                  Fluttertoast.showToast(msg: 'PIN is required');
                  return;
                }
                Navigator.pop(context);
                
                EasyLoading.show(status: 'Checking in...');
                final success = await _checkInOutRx.checkIn(store.id!, pin);
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
    final data = _dashboardRx.dataFetcher.value;
    if (data.currentActiveShift != null) {
      EasyLoading.show(status: 'Checking out...');
      final success = await _checkInOutRx.checkOut(Map<String, dynamic>.from(data.currentActiveShift));
      EasyLoading.dismiss();
      if (success) {
        final now = DateTime.now();
        final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        appData.write('staff_shift_completed_$todayStr', true);
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
          'Staff Dashboard',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          StreamBuilder<StaffDashboardModel>(
            stream: _dashboardRx.valueStreamData,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.notifications?.where((n) => n.isRead != true).length ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF151E13)),
                    onPressed: () => Get.to(() => const NotificationsInboxScreen())?.then((_) => _dashboardRx.fetchDashboardData()),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6.w,
                      top: 6.h,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
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
                      child: const CustomAppLoading.card(itemCount: 1),
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
                  final activeStores = data.activeStores ?? [];
                  final calculatedHours = _getCalculatedTotalHours(data.shifts, _selectedStoreFilterId);
                  final filteredShiftCount = _selectedStoreFilterId == null
                      ? (data.shifts?.length ?? 0)
                      : (data.shifts?.where((s) => s.store == _selectedStoreFilterId).length ?? 0);

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
                        if (activeStores.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'STORE FILTER',
                                style: TextStyle(color: Colors.white60, fontSize: 10.sp, fontWeight: FontWeight.bold),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: _selectedStoreFilterId,
                                  dropdownColor: const Color(0xFF004D38),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                                  isDense: true,
                                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('All Stores', style: TextStyle(color: Colors.white)),
                                    ),
                                    ...activeStores.map((store) => DropdownMenuItem<int?>(
                                      value: store.id,
                                      child: Text(store.name ?? 'Store #${store.id}', style: const TextStyle(color: Colors.white)),
                                    )),
                                  ],
                                  onChanged: (newVal) {
                                    setState(() {
                                      _selectedStoreFilterId = newVal;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
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
                                  '$filteredShiftCount Days Assigned',
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
                                  '${calculatedHours.toStringAsFixed(1)} hrs',
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
                    final now = DateTime.now();
                    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                    final hasCompletedToday = data.hasCompletedShiftToday == true ||
                        (appData.read('staff_shift_completed_$todayStr') == true) ||
                        (data.shifts?.any((s) => (s.date == todayStr || s.date?.startsWith(todayStr) == true) && (s.status?.toUpperCase() == 'COMPLETED')) == true);

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
                          if (hasCompletedToday && !isWorking)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20.r),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Shift completed for today',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
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
              SizedBox(height: 24.h),
              Text(
                'Staff Actions',
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
                title: 'Add Product',
                subtitle: 'Register new organic produce or products to store',
                icon: Icons.add_business_rounded,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
                onTap: () => Get.to(() => const WholesaleAddProductScreen()),
              ),
              SizedBox(height: 12.h),
              _buildListActionCard(
                context,
                title: 'My Daily Tasks',
                subtitle: 'View and mark assigned tasks as completed',
                icon: Icons.checklist_rtl_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFFA855F7),
                onTap: () => Get.toNamed(Routes.STAFF_TASKS_SCREEN) ?? Get.to(() => const SizedBox()),
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
