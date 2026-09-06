import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'route/app_pages.dart';
import 'constants/app_constants.dart';
import 'constants/app_colors.dart';
import 'constants/app_assets/assets_icons.dart';
import 'helpers/di.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));

    // Wait until DI/appData is fully loaded. Check tokens/session.
    // Replace with correct import for appData
    // We will use standard dependency injection (appData) if already imported, else GetStorage or SharedPreferences
    // Let's implement it inside the replacement block.
    
    // Using simple approach based on what we saw in Rx:
    try {
      // Import needed manually if not present
      final bool hasToken = appData.read(kKeyAccessToken)?.isNotEmpty ?? false;
      
      if (hasToken) {
        final String? userRoleStr = appData.read('user_role');
        if (userRoleStr != null && userRoleStr.isNotEmpty) {
          Get.offAllNamed(Routes.NAV, arguments: userRoleStr);
          return;
        }
      }
      
      // If we are not logged in or have missing role, go to Role Selection
      Get.offAllNamed(Routes.ROLE_SELECTION);
    } catch (e) {
      Get.offAllNamed(Routes.ONBOARDING);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00694C), // primary brand green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                AssetsIcons.logoIcons,
                width: 100.w,
                height: 100.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'El Árbol',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Frutas & Verduras',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
