import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route/app_pages.dart';
import 'constants/app_constants.dart';
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
    return const Scaffold(
      backgroundColor: Color(0xFF00694C), // primary brand green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'El Árbol',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
