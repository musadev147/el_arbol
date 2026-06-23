import 'package:get/get.dart';

import '../featuers/onboarding/onboarding_screen.dart';
import '../common_wigdets/custom_navigation.dart';
import '../featuers/home/presentation/home_screen.dart';
import '../featuers/auth/login/presentation/login_screen.dart';
import '../featuers/auth/role_selection_screen.dart';
import '../featuers/auth/forget_password/presentation/forget_password_screen.dart';
import '../featuers/auth/otp/presentation/otp_screen.dart';
import '../featuers/message/messages_screen.dart';
import '../featuers/wallet/tenant_wallet_screen.dart';
import '../featuers/profile/profile.dart';
import '../splash.dart';
import '../common_wigdets/user_role.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
    ),

    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingScreen(),
    ),

    GetPage(
      name: Routes.LOGIN,
      page: () => SignInScreen(role: Get.arguments is String ? Get.arguments as String : (Get.arguments as UserRole?)?.value),
    ),

    GetPage(
      name: Routes.ROLE_SELECTION,
      page: () => const RoleSelectionScreen(),
    ),

    GetPage(
      name: Routes.NAV,
      page: () => CustomNavigation(
        role: Get.arguments is String
            ? UserRole.fromString(Get.arguments as String)
            : Get.arguments as UserRole?,
      ),
    ),

    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
    ),

    GetPage(
      name: Routes.MESSAGE,
      page: () => const MessagesScreen(),
    ),

    GetPage(
      name: Routes.WALLET,
      page: () => const TenantWallet(),
    ),

    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(points: 100),
    ),

    GetPage(
      name: Routes.FORGET_PASSWORD,
      page: () => const ForgetPasswordScreen(),
    ),

    GetPage(
      name: Routes.OTP,
      page: () => const OtpScreen(),
    ),
  ];
}
