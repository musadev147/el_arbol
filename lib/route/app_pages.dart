import 'package:get/get.dart';
import '../common_wigdets/custom_navigation.dart';
import '../featuers/auth/login/presentation/login_screen.dart';
import '../featuers/customers/home/presentation/home_screen.dart';
import '../featuers/customers/message/messages_screen.dart';
import '../featuers/customers/profile/profile.dart';
import '../featuers/customers/wallet/tenant_wallet_screen.dart';
import '../featuers/role_selection_screen.dart';
import '../featuers/auth/forget_password/presentation/forget_password_screen.dart';
import '../featuers/auth/otp/presentation/otp_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../splash.dart';
import '../common_wigdets/user_role.dart';

import '../featuers/auth/register/presentation/register_screen.dart';
import '../featuers/customers/wishlist/presentation/wishlist_screen.dart';
import '../featuers/employee_self_service/presentation/staff_tasks_screen.dart';
import '../featuers/employee_self_service/presentation/staff_colleagues_screen.dart';
import '../featuers/employee_self_service/presentation/staff_order_history_screen.dart';
import '../featuers/wholesale_b2b/presentation/wholesale_notifications_screen.dart';
import '../featuers/wholesale_b2b/presentation/wholesale_daily_reports_screen.dart';
import '../featuers/wholesale_b2b/presentation/wholesale_support_tickets_screen.dart';
import '../featuers/wholesale_b2b/presentation/wholesale_add_product_screen.dart';

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
      page: () => const ProfileScreen(),
    ),

    GetPage(
      name: Routes.FORGET_PASSWORD,
      page: () => const ForgetPasswordScreen(),
    ),

    GetPage(
      name: Routes.OTP,
      page: () => const OtpScreen(),
    ),

    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterScreen(role: Get.arguments is String ? Get.arguments as String : (Get.arguments as UserRole?)?.value),
    ),
    GetPage(
      name: Routes.WISHLIST,
      page: () => const WishlistScreen(),
    ),
    GetPage(
      name: Routes.STAFF_TASKS_SCREEN,
      page: () => const StaffTasksScreen(),
    ),
    GetPage(
      name: Routes.STAFF_COLLEAGUES_SCREEN,
      page: () => const StaffColleaguesScreen(),
    ),
    GetPage(
      name: Routes.STAFF_ORDER_HISTORY_SCREEN,
      page: () => const StaffOrderHistoryScreen(),
    ),
    GetPage(
      name: Routes.WHOLESALE_NOTIFICATIONS_SCREEN,
      page: () => const WholesaleNotificationsScreen(),
    ),
    GetPage(
      name: Routes.WHOLESALE_DAILY_REPORTS_SCREEN,
      page: () => const WholesaleDailyReportsScreen(),
    ),
    GetPage(
      name: Routes.WHOLESALE_SUPPORT_TICKETS_SCREEN,
      page: () => const WholesaleSupportTicketsScreen(),
    ),
    GetPage(
      name: Routes.WHOLESALE_ADD_PRODUCT,
      page: () => const WholesaleAddProductScreen(),
    ),
  ];
}
