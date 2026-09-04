import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppLoading extends StatelessWidget {
  final String? message;
  final bool isCenter;

  const CustomAppLoading({
    super.key,
    this.message,
    this.isCenter = true,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 36.r,
          height: 36.r,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        if (message != null && message!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            message!,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isCenter) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: content,
        ),
      );
    }
    return content;
  }
}
