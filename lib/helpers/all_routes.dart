// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:el_arbol/common_wigdets/custom_successfull_screen.dart';
// import 'package:el_arbol/features/authentigation/forgot_password/presentation/forgot_password_screen.dart';
// import 'package:el_arbol/features/authentigation/forgot_password/presentation/otp_screen.dart';
// import 'package:el_arbol/features/authentigation/presentation/auth_screen.dart';
// import 'package:el_arbol/features/authentigation/login/presentation/login_screen.dart';
// import 'package:el_arbol/features/authentigation/forgot_password/presentation/reset_password_screen.dart';
// import 'package:el_arbol/features/buyer_item_details/presentation/buyer_item_details_screen.dart';
// import 'package:el_arbol/features/category/presentation/category_screen1.dart';
// import 'package:el_arbol/features/checkout_screen/presentation/checkout_screen.dart';
// import 'package:el_arbol/features/coin_management/presenation/coin_management_screen.dart';
// import 'package:el_arbol/features/faq/presentation/faq_screen.dart';
// import 'package:el_arbol/features/game/presentation/game_adds_screen.dart';
// import 'package:el_arbol/features/activity/presentation/category_select_screen.dart';
// import 'package:el_arbol/features/game/presentation/congratulation_screen.dart';
// import 'package:el_arbol/features/game/presentation/game_screen.dart';
// import 'package:el_arbol/features/activity/presentation/sub_category_screen.dart';
// import 'package:el_arbol/features/leaderboard/presentation/leaderboard_screen.dart';
// import 'package:el_arbol/features/onboarding/presentation/onboarding_screen1.dart';
// import 'package:el_arbol/features/onboarding/presentation/onboarding_screen5.dart';
// import 'package:el_arbol/features/onboarding/presentation/onboarding_screen6.dart';
// import 'package:el_arbol/features/onboarding/presentation/onboarding_screen7.dart';
// import 'package:el_arbol/features/onboarding/presentation/onboarding_screen8.dart';
// import 'package:el_arbol/features/onboarding/presentation/onboarding_screen9.dart';
// import 'package:el_arbol/features/seller_item_details/presentation/seller_item_details_screen.dart';
// import 'package:el_arbol/features/settings/presentation/change_password/change_passwrod_otp_screen.dart';
// import 'package:el_arbol/features/settings/presentation/change_password/change_passwrod_screen.dart';
// import 'package:el_arbol/features/settings/presentation/contact_us/contact_us_screen.dart';
// import 'package:el_arbol/features/settings/presentation/delete_account/delete_account_otp_screen.dart';
// import 'package:el_arbol/features/settings/presentation/delete_account/delete_account_screen.dart';
// import 'package:el_arbol/features/settings/presentation/personal_information/edit_email_screen.dart';
// import 'package:el_arbol/features/settings/presentation/personal_information/personal_information_screen.dart';
// import 'package:el_arbol/features/settings/presentation/setting_screen.dart';
// import 'package:el_arbol/features/settings/login_and_security_screen/login_and_security_screen.dart';
// import '../features/bottom_navigation_bar/bottom_nav_bar.dart';
// import '../features/activity/presentation/activity_screen.dart';
// import '../features/authentigation/forgot_password/presentation/password_changed_confirmation_screen.dart';
// import '../features/authentigation/forgot_password/presentation/password_changed_error_screen.dart';
// import '../features/authentigation/signup/presentation/activate_your_account_screen.dart';
// import '../features/authentigation/signup/presentation/signup_screen.dart';
// import '../features/buy_items/presentation/buy_items_screen.dart';
// import '../features/category/presentation/category_screen2.dart';
// import '../features/category/presentation/category_screen3.dart';
// import '../features/community_rules/presentation/community_rules_screen.dart';
// import '../features/edit_product/presentation/edit_product_screen.dart';
// import '../features/my_bag_screen/presentation/my_bag_screen.dart';
// import '../features/notification/presentation/settings_screen.dart';
// import '../features/notification/presentation/notification_settings_screen.dart';
// import '../features/onboarding/presentation/onboarding_screen2.dart';
// import '../features/onboarding/presentation/onboarding_screen3.dart';
// import '../features/onboarding/presentation/onboarding_screen3a.dart';
// import '../features/onboarding/presentation/onboarding_screen4.dart';
// import '../features/order_details/presentation/order_details_screen.dart';
// import '../features/product_size_screen/presentation/product_size_screen.dart';
// import '../features/search/presentation/filter_search_screen.dart';
// import '../features/search/presentation/search_result_screen.dart';
// import '../features/search/presentation/search_screen.dart';
// import '../features/seller_item/presentation/seller_item_screen.dart';
// import '../features/settings/presentation/edit_profile/edit_profile.dart';
// import '../features/settings/presentation/giveus_feedback_report_concern/giveus_feedback_report_concern_screen.dart';
// import '../features/settings/presentation/login_security/login_security_screen.dart';
// import '../features/settings/presentation/personal_information/edit_mobile_number_screen.dart';
// import '../features/settings/presentation/privacy_sharing/privacy_sharing_screen.dart';
// import '../features/settings/presentation/subscription_setting_screen/subscription_setting_screen.dart';
// import '../features/subscription_screen/subscription_screen.dart';
//
// final class Routes {
//   static final Routes _routes = Routes._internal();
//   Routes._internal();
//   static Routes get instance => _routes;
//   static const String navigationScreen = '/navigation_screen';
//   static const String editProductScreen = '/edit_product_screen';
//   static const String productSizeScreen = '/product_size_screen';
//   static const String sellerItemScreen = '/seller_item_screen';
//   static const String sellerDetailScreen = '/seller_detail_screen';
//   static const String buyItemsScreen = '/buy_items_screen';
//   static const String activityHomeScreen = '/activity_home_screen';
//   static const String buyerItemDetailScreen = '/buyer_item_detail_screen';
//   static const String searchScreen = '/search_screen';
//   static const String searchResultScreen = '/search_result_screen';
//   static const String filterSearchScreen = '/filter_search_screen';
//   static const String categoryScreen1 = '/category_screen1';
//   static const String categoryScreen2 = '/category_screen2';
//   static const String categoryScreen3 = '/category_screen3';
//   static const String myBagScreen = '/my_bag_screen';
//   static const String checkoutScreen = '/checkout_screen';
//   static const String orderDetailsScreen = '/order_details_screen';
//   static const String categoryHomeScreen = '/category_home_screen';
//   static const String categorySelectScreen = '/category_select_screen';
//   static const String subCategorySelectScreen = '/subcategory_select_screen';
//   static const String gameScreen = '/game_screen';
//   static const String gameAddsScreen = '/game_adds_screen';
//   static const String congratulationScreen = '/congratulation_screen';
//   static const String authScreen = '/auth_screen';
//   static const String signupScreen = '/signup_screen';
//   static const String activateYourAccountScreen =
//       '/activate_your_account_screen';
//   static const String loginScreen = '/login_screen';
//   static const String forgotPasswordScreen = '/forgot_password_screen';
//   static const String otpScreen = '/otp_screen';
//   static const String resetPasswordScreen = '/reset_password_screen';
//   static const String passwordChangedConfirmationScreen =
//       '/password_changed_confirmation_screen';
//   static const String passwordChangedErrorScreen =
//       '/password_changed_error_screen';
//   static const String coinManagementScreen = '/coin_menagement_screen';
//   static const String subscriptionScreen = '/subscription_screen';
//   static const String onBoardingScreen1 = '/onboarding_screen1';
//   static const String onBoardingScreen2 = '/onboarding_screen2';
//   static const String onBoardingScreen3 = '/onboarding_screen3';
//   static const String onBoardingScreen3A = '/onboarding_screen3a';
//   static const String onBoardingScreen4 = '/onboarding_screen4';
//   static const String onBoardingScreen5 = '/onboarding_screen5';
//   static const String onBoardingScreen6 = '/onboarding_screen6';
//   static const String onBoardingScreen7 = '/onboarding_screen7';
//   static const String onBoardingScreen8 = '/onboarding_screen8';
//   static const String onBoardingScreen9 = '/onboarding_screen9';
//   static const String faqScreen = '/faq_screen';
//   static const String settingScreen = '/setting_screen';
//   static const String deleteAccountOtpScreen = '/delete_account_otp_screen';
//   static const String deleteAccountScreen = '/delete_account_screen';
//   static const String changePasswordScreen = '/change_password_screen';
//   static const String notificationScreen = '/notification_screen';
//   static const String notificationSettingsScreen =
//       '/notifications_settings_screen';
//   static const String changePasswordOtpScreen = '/change_password_otp_screen';
//   static const String personalInformation = '/personal_information';
//   static const String leaderboardScreen = '/leaderboard_screen';
//   static const String mobileEditScreen = '/mobile_edit_screen';
//   static const String emailEditScreen = '/email_edit_screen';
//   static const String customSuccessfullScreen = '/customm_successfull_screen';
//   static const String contactUsScreen = '/contact_us_screen';
//   static const String communityRulesScreen = '/community_rules_screen';
//   static const String editProfileCScreen = '/edit_profile_c_screen';
//   static const String subscriptionSettingScreen =
//       '/subscription_setting_screen';
//   static const String loginSecurityScreen = '/login_security_screen';
//   static const String privacySharingScreen = '/privacy_sharing_screen';
//   static const String giveusFeedbackScreen = '/giveus_feedback_screen';
//   static const String newSettingScreen = '/new_setting_screen';
//   static const String loginAndSecurity = '/login_and_security';
// }
//
// final class RouteGenerator {
//   static final RouteGenerator _routeGenerator = RouteGenerator._internal();
//   RouteGenerator._internal();
//   static RouteGenerator get instance => _routeGenerator;
//
//   static Route<dynamic>? generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case Routes.changePasswordScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const ChangePasswordScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const ChangePasswordScreen(),
//             );
//
//       case Routes.loginAndSecurity:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const LoginAndSecurityScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const LoginAndSecurityScreen(),
//             );
//
//       case Routes.contactUsScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const ContactUsScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => const ContactUsScreen());
//
//       case Routes.customSuccessfullScreen:
//         final arg = settings.arguments as Map;
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: CustomSuccessfullScreen(
//                 title: arg["title"],
//                 subTitle: arg["subTitle"],
//                 ontap: arg["onTap"],
//                 buttonName: arg["buttonName"],
//               ),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder:
//                   (context) => CustomSuccessfullScreen(
//                     title: arg["title"],
//                     subTitle: arg["subTitle"],
//                     ontap: arg["onTap"],
//                     buttonName: arg["buttonName"],
//                   ),
//             );
//
//       case Routes.mobileEditScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const EditMobileNumberScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const EditMobileNumberScreen(),
//             );
//
//       case Routes.newSettingScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const SettingScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => const SettingScreen());
//
//       case Routes.emailEditScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const EditEmailScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => const EditEmailScreen());
//
//       case Routes.leaderboardScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const LeaderboardScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const LeaderboardScreen(),
//             );
//
//       case Routes.personalInformation:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const PersonalInformationScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const PersonalInformationScreen(),
//             );
//
//       case Routes.notificationScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const NotificationScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const NotificationScreen(),
//             );
//
//       case Routes.notificationSettingsScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const NotificationSettingsScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const NotificationSettingsScreen(),
//             );
//
//       case Routes.changePasswordOtpScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const ChangePasswrodOtpScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const ChangePasswrodOtpScreen(),
//             );
//
//       case Routes.deleteAccountScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const DeleteAccountScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const DeleteAccountScreen(),
//             );
//
//       case Routes.faqScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const FaqScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => const FaqScreen());
//
//       case Routes.deleteAccountOtpScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const DeleteAccountOtpScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const DeleteAccountOtpScreen(),
//             );
//
//       case Routes.settingScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const SettingScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => const SettingScreen());
//
//       case Routes.onBoardingScreen7:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const OnBoardingScreen7(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const OnBoardingScreen7(),
//             );
//
//       case Routes.onBoardingScreen9:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const OnBoardingScreen9(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const OnBoardingScreen9(),
//             );
//
//       case Routes.onBoardingScreen8:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const OnBoardingScreen8(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const OnBoardingScreen8(),
//             );
//
//       case Routes.onBoardingScreen6:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const OnBoardingScreen6(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const OnBoardingScreen6(),
//             );
//
//       case Routes.onBoardingScreen5:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const OnBoardingScreen5(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const OnBoardingScreen5(),
//             );
//
//       case Routes.editProductScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const EditProductScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const EditProductScreen(),
//             );
//
//       case Routes.productSizeScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const ProductSizeScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const ProductSizeScreen(),
//             );
//
//       case Routes.sellerItemScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: SellerItemScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => SellerItemScreen());
//
//       case Routes.buyItemsScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: BuyItemsScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => BuyItemsScreen());
//
//       case Routes.activityHomeScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: ActivityHomeScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => ActivityHomeScreen());
//
//       case Routes.sellerDetailScreen:
//         final args = settings.arguments as Map;
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: SellerItemDetailsScreen(tag: args["tag"]),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => SellerItemDetailsScreen(tag: args["tag"]),
//             );
//
//       case Routes.buyerItemDetailScreen:
//         final args = settings.arguments as Map;
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: BuyerItemDetailsScreen(tag: args["tag"]),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => BuyerItemDetailsScreen(tag: args["tag"]),
//             );
//
//       case Routes.searchScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(widget: SearchScreen(), settings: settings)
//             : CupertinoPageRoute(builder: (context) => SearchScreen());
//
//       case Routes.searchResultScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: SearchResultScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => SearchResultScreen());
//
//       case Routes.filterSearchScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: FilterSearchScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => FilterSearchScreen());
//
//       case Routes.categoryScreen1:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: CategoryScreen1(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => CategoryScreen1());
//
//       case Routes.categoryScreen2:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: CategoryScreen2(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => CategoryScreen2());
//
//       case Routes.categoryScreen3:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: CategoryScreen3(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => CategoryScreen3());
//
//       case Routes.myBagScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(widget: MyBagScreen(), settings: settings)
//             : CupertinoPageRoute(builder: (context) => MyBagScreen());
//
//       case Routes.checkoutScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: CheckoutScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => CheckoutScreen());
//
//       case Routes.orderDetailsScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: OrderDetailsScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => OrderDetailsScreen());
//
//       case Routes.categorySelectScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: CategorySelectScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => CategorySelectScreen());
//
//       case Routes.subCategorySelectScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: SubCategoryScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => SubCategoryScreen());
//
//       case Routes.gameScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(widget: GameScreen(), settings: settings)
//             : CupertinoPageRoute(builder: (context) => GameScreen());
//
//       case Routes.gameAddsScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: GameAddsScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => GameAddsScreen());
//
//       case Routes.congratulationScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: CongratulationScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => CongratulationScreen());
//
//       case Routes.authScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(widget: AuthScreen(), settings: settings)
//             : CupertinoPageRoute(builder: (context) => AuthScreen());
//
//       case Routes.signupScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(widget: SignUpScreen(), settings: settings)
//             : CupertinoPageRoute(builder: (context) => SignUpScreen());
//
//       case Routes.activateYourAccountScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: ActivateYourAccountScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => ActivateYourAccountScreen(),
//             );
//
//       case Routes.loginScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(widget: LoginScreen(), settings: settings)
//             : CupertinoPageRoute(builder: (context) => LoginScreen());
//
//       case Routes.navigationScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const BottomNavBar(selectIndex: 0),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const BottomNavBar(selectIndex: 0),
//             );
//
//       case Routes.forgotPasswordScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: ForgotPasswordScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => ForgotPasswordScreen());
//
//       case Routes.otpScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(widget: OtpScreen(), settings: settings)
//             : CupertinoPageRoute(builder: (context) => OtpScreen());
//
//       case Routes.resetPasswordScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: ResetPasswordScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => ResetPasswordScreen());
//
//       case Routes.passwordChangedConfirmationScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: PasswordChangedConfirmationScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => PasswordChangedConfirmationScreen(),
//             );
//
//       case Routes.passwordChangedErrorScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: PasswordChangedErrorScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => PasswordChangedErrorScreen(),
//             );
//
//       case Routes.coinManagementScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: CoinManagementScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => CoinManagementScreen());
//
//       case Routes.subscriptionScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: SubscriptionScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => SubscriptionScreen());
//
//       case Routes.onBoardingScreen1:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: OnBoardingScreen1(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => OnBoardingScreen1());
//
//       case Routes.onBoardingScreen2:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: OnBoardingScreen2(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => OnBoardingScreen2());
//
//       case Routes.onBoardingScreen3:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: OnBoardingScreen3(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => OnBoardingScreen3());
//
//       case Routes.onBoardingScreen3A:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: OnBoardingScreen3A(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => OnBoardingScreen3A());
//
//       case Routes.onBoardingScreen4:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: OnBoardingScreen4(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(builder: (context) => OnBoardingScreen4());
//
//       case Routes.communityRulesScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const CommunityRulesScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const CommunityRulesScreen(),
//             );
//
//       case Routes.editProfileCScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const EditProfileCScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const EditProfileCScreen(),
//             );
//
//       case Routes.subscriptionSettingScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const SubscriptionSettingScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const SubscriptionSettingScreen(),
//             );
//
//       case Routes.loginSecurityScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const LoginSecurityScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const LoginSecurityScreen(),
//             );
//
//       case Routes.privacySharingScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const PrivacySharingScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const PrivacySharingScreen(),
//             );
//
//       case Routes.giveusFeedbackScreen:
//         return Platform.isAndroid
//             ? _FadedTransitionRoute(
//               widget: const GiveFeedbackReportConcernScreen(),
//               settings: settings,
//             )
//             : CupertinoPageRoute(
//               builder: (context) => const GiveFeedbackReportConcernScreen(),
//             );
//
//       default:
//         return null;
//     }
//   }
// }
//
// class _FadedTransitionRoute extends PageRouteBuilder {
//   final Widget widget;
//   @override
//   final RouteSettings settings;
//
//   _FadedTransitionRoute({required this.widget, required this.settings})
//     : super(
//         settings: settings,
//         reverseTransitionDuration: const Duration(milliseconds: 1),
//         pageBuilder: (
//           BuildContext context,
//           Animation<double> animation,
//           Animation<double> secondaryAnimation,
//         ) {
//           return widget;
//         },
//         transitionDuration: const Duration(milliseconds: 1),
//         transitionsBuilder: (
//           BuildContext context,
//           Animation<double> animation,
//           Animation<double> secondaryAnimation,
//           Widget child,
//         ) {
//           return FadeTransition(
//             opacity: CurvedAnimation(parent: animation, curve: Curves.ease),
//             child: child,
//           );
//         },
//       );
// }
