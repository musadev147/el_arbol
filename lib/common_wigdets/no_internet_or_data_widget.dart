import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class NoInternetOrDataWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String buttonText;
  final double? lottieSize;
  final bool isFullPage;

  const NoInternetOrDataWidget({
    super.key,
    this.title = 'No Internet Connection',
    this.message = 'Please check your internet connection and try again.',
    this.onRetry,
    this.buttonText = 'Try Again',
    this.lottieSize,
    this.isFullPage = true,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/no_internet.json',
            width: lottieSize ?? (isFullPage ? 200.r : 150.r),
            height: lottieSize ?? (isFullPage ? 200.r : 150.r),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.wifi_off_rounded,
                size: lottieSize ?? 72.r,
                color: Colors.grey.shade400,
              );
            },
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF151E13),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (isFullPage) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: content,
        ),
      );
    }
    return Center(child: content);
  }
}
