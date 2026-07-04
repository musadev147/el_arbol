import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:el_arbol/common_wigdets/user_role.dart';
import 'package:el_arbol/route/app_pages.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.customer;

  @override
  Widget build(BuildContext context) {
    const Color primaryBrandColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              // Brand logo
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.eco, color: primaryBrandColor, size: 28),
                    SizedBox(width: 6.w),
                    Text(
                      'El Árbol',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF151E13),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                'Select Your Role',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF151E13),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Choose the account portal you want to log into.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6D7A73),
                ),
              ),
              SizedBox(height: 32.h),

              // Role Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildRoleCard(
                      UserRole.customer,
                      'Customer App',
                      'Fresh organic products, local shop finder, home delivery & leftover packs.',
                      Icons.shopping_bag,
                      primaryBrandColor,
                    ),
                    SizedBox(height: 16.h),
                    _buildRoleCard(
                      UserRole.wholesale,
                      'Wholesales',
                      'Direct orders, bulk purchase, and farm-to-merchant delivery.',
                      Icons.storefront,
                      primaryBrandColor,
                    ),
                    SizedBox(height: 16.h),
                    _buildRoleCard(
                      UserRole.shopPortal,
                      'Shop Portal',
                      'Internal store staff portal for order fulfillment and stock scanner.',
                      Icons.local_shipping,
                      primaryBrandColor,
                    ),
                    SizedBox(height: 16.h),
                    _buildRoleCard(
                      UserRole.employeeSelfService,
                      'Employee Self-service',
                      'View work schedule, request leaves, and access payslips.',
                      Icons.badge,
                      primaryBrandColor,
                    ),
                  ],
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.LOGIN, arguments: _selectedRole);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrandColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    UserRole role,
    String title,
    String subtitle,
    IconData icon,
    Color brandColor,
  ) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? brandColor : Colors.grey.shade200,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected ? brandColor.withOpacity(0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? brandColor : Colors.grey.shade600,
                size: 24.r,
              ),
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
                      fontSize: 16.sp,
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
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: brandColor,
                size: 20.r,
              ),
          ],
        ),
      ),
    );
  }
}
