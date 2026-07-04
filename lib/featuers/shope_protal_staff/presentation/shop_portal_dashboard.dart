import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'create_order_screen.dart';
import 'track_orders_screen.dart';
import 'previous_orders_screen.dart';
import 'daily_financial_report_screen.dart';
import 'manage_wholesale_orders_screen.dart';

class ShopPortalDashboardScreen extends StatelessWidget {
  const ShopPortalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    const Color cardColor = Colors.white;
    const Color backgroundColor = Color(0xFFFAFAF8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Shop Portal',
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
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF151E13)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store & Employee info card
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
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
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
                          'EL ÁRBOL STORE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Active Shift',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Store Staff: EMP-9082',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.store, color: Colors.white70, size: 16),
                        SizedBox(width: 6.w),
                        Text(
                          'Shop ID: SHOP-VALENCIA-04',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                'Daily Operations',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF151E13),
                ),
              ),
              SizedBox(height: 14.h),

              // Quick Actions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 0.9,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Create Order',
                    subtitle: 'Fruits, Veggies & Grocery list',
                    icon: Icons.add_shopping_cart_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    onTap: () => Get.to(() => const CreateOrderScreen()),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Track Orders',
                    subtitle: 'Active pending approvals',
                    icon: Icons.track_changes_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    onTap: () => Get.to(() => const TrackOrdersScreen()),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Previous Orders',
                    subtitle: 'Browse, share & download',
                    icon: Icons.history_rounded,
                    iconColor: const Color(0xFF10B981),
                    onTap: () => Get.to(() => const PreviousOrdersScreen()),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Financial Report',
                    subtitle: 'Submit daily totals',
                    icon: Icons.analytics_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    onTap: () => Get.to(() => const DailyFinancialReportScreen()),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'B2B Wholesale',
                    subtitle: 'Adjust B2B invoice & refunds',
                    icon: Icons.business_center_rounded,
                    iconColor: const Color(0xFFEC4899),
                    onTap: () => Get.to(() => const ManageWholesaleOrdersScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24.r,
              ),
            ),
            Column(
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
                    fontSize: 11.sp,
                    color: const Color(0xFF6D7A73),
                    height: 1.3,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
