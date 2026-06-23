import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:el_arbol/constants/app_assets/assets_lottie.dart';
import '../common_wigdets/loading_indicators.dart';
import 'navigation_service.dart';

extension Loader on Future {
  Future<dynamic> waitingForLogin() async {
    showDialog(
      context: NavigationService.context,
      barrierColor: Colors.transparent,
      builder: (context) => loadingIndicatorCircle(context: context),
    );

    try {
      // Wait for the original future to complete
      dynamic result = await this;

      return result;
    } finally {
      // Close the loading dialog
      // NavigationService.navigateToUntilReplacement(Routes.navigationScreen);
    }
  }

  Future<dynamic> waitingForFuture() async {
    showDialog(
      context: NavigationService.context,
      barrierColor: Colors.transparent,
      builder: (context) => loadingIndicatorCircle(context: context),
    );

    try {
      // Wait for the original future to complete
      dynamic result = await this;

      return result;
    } finally {
      // Close the loading dialog
      NavigationService.goBack;
    }
  }

  Future<dynamic> waitingResponse() async {
    showDialog(
      context: NavigationService.context,
      barrierColor: Colors.transparent,
      builder: (context) => const SizedBox.shrink(),
    );

    try {
      // Wait for the original future to complete
      dynamic result = await this;

      return result;
    } finally {
      // Close the loading dialog
      NavigationService.goBack;
    }
  }

  Future<dynamic> waitingAddToCart() async {
    showDialog(
      context: NavigationService.context,
      builder:
          (context) => Center(
            child: shimmer(context: context, name: AssetsLotties.dataEmpty),
          ),
    );

    try {
      // Wait for the original future to complete
      dynamic result = await this;

      return result;
    } finally {
      // Close the loading dialog
      NavigationService.goBack;
    }
  }

  Future<dynamic> waitingRemoveFromCart() async {
    showDialog(
      // barrierDismissible: false,
      // ignore: deprecated_member_use
      // barrierColor: AppColors.cF4F4F4.withOpacity(.8),
      context: NavigationService.context,
      builder:
          (context) => Center(
            child: shimmer(
              context: context,
              name: AssetsLotties.dataEmpty,
              size: 120,
            ),
          ),
    );

    try {
      // Wait for the original future to complete
      dynamic result = await this;

      return result;
    } finally {
      // Close the loading dialog
      NavigationService.goBack;
    }
  }

  Future<dynamic> waitingForFutureWithoutBg() async {
    showDialog(
      context: NavigationService.context,
      builder: (context) => loadingIndicatorCircle(context: context),
    );

    try {
      // Wait for the original future to complete
      dynamic result = await this;
      return result;
    } finally {
      // Close the loading dialog
      NavigationService.goBack;
    }
  }

  Future<void> waitingForFuturewithTime() async {
    try {
      showDialog(
        context: NavigationService.context,
        barrierColor: Colors.black,
        builder: (context) => loadingIndicatorCircle(context: context),
      );
      bool result = await this;
      NavigationService.goBack;
      if (result) {
        showDialog(
          context: NavigationService.context,
          builder:
              (context) => shimmer(
                context: NavigationService.context,
                name: AssetsLotties.dataEmpty,
                size: 120,
              ),
        );
        await Future.delayed(const Duration(milliseconds: 800), () {
          NavigationService.goBack;
        });
      }
    } catch (e) {
      NavigationService.goBack;
      log(e.toString());
    }
  }

  Future<void> waitingForSuccessShow() async {
    try {
      bool result = await this;
      if (result) {
        showDialog(
          context: NavigationService.context,
          builder:
              (context) => shimmer(
                context: NavigationService.context,
                name: AssetsLotties.dataEmpty,
                size: 120,
              ),
        );
        await Future.delayed(const Duration(milliseconds: 800), () {
          NavigationService.goBack;
        });
      }
    } catch (e) {
      NavigationService.goBack;
      log(e.toString());
    }
  }

  Future<bool> customeThen() async {
    bool retunValue = await then(
      (value) async {
        showDialog(
          context: NavigationService.context,
          builder:
              (context) => shimmer(
                context: NavigationService.context,
                name: AssetsLotties.dataEmpty,
                size: 120,
              ),
        );
        await Future.delayed(const Duration(milliseconds: 800), () {
          NavigationService.goBack;
        });
        // DefaultResponse defaultResponse = value as DefaultResponse;
        // ScaffoldMessenger.of(NavigationService.context).showSnackBar(
        //   SnackBar(
        //     content: Text(defaultResponse.message!),
        //   ),
        // );
        return true;
      },
      onError: (value) {
        // Failure failureresponse = value as Failure;
        // ScaffoldMessenger.of(NavigationService.context).showSnackBar(
        //   SnackBar(
        //     content: Text(failureresponse.responseMessage),
        //   ),
        // );
        return false;
      },
    );
    return retunValue;
  }

  // Future<bool> loginCustomeThen() async {
  //   return await then(
  //     (value) async {
  //       // Check if login is successful
  //       if (value is LoginResponse &&
  //           value.code == 200 &&
  //           value.status == true) {
  //         // Show success dialog
  //         showDialog(
  //           context: NavigationService.context,
  //           builder: (context) => shimmer(
  //               context: NavigationService.context,
  //               name: Assets.lottie.success,
  //               size: 120.sp),
  //         );
  //         await Future.delayed(const Duration(milliseconds: 800), () {
  //           NavigationService.goBack();
  //         });
  //         ScaffoldMessenger.of(NavigationService.context).showSnackBar(
  //           SnackBar(
  //             content: Text(value.message ?? "Login successful"),
  //           ),
  //         );
  //         return true; // Successful login
  //       } else {
  //         // Handle failed login attempt
  //         ToastUtil.showLongToast("Login failed. Please try again.");
  //         return false; // Unsuccessful login
  //       }
  //     },
  //     onError: (error) {
  //       // Log error and show failure message
  //       log('Login error: $error');
  //       ToastUtil.showLongToast("Login failed. Please try again.");
  //       return false; // Unsuccessful login
  //     },
  //   );
  // }
}
