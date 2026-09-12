import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_shimmer.dart';

enum CustomLoadingType {
  list,
  grid,
  card,
  detail,
  chat,
}

class CustomAppLoading extends StatelessWidget {
  final String? message;
  final bool isCenter;
  final CustomLoadingType type;
  final int itemCount;

  const CustomAppLoading({
    super.key,
    this.message,
    this.isCenter = false,
    this.type = CustomLoadingType.list,
    this.itemCount = 6,
  });

  const CustomAppLoading.list({
    super.key,
    this.message,
    this.itemCount = 6,
    this.isCenter = false,
  }) : type = CustomLoadingType.list;

  const CustomAppLoading.grid({
    super.key,
    this.message,
    this.itemCount = 6,
    this.isCenter = false,
  }) : type = CustomLoadingType.grid;

  const CustomAppLoading.card({
    super.key,
    this.message,
    this.itemCount = 4,
    this.isCenter = false,
  }) : type = CustomLoadingType.card;

  const CustomAppLoading.detail({
    super.key,
    this.message,
    this.isCenter = false,
  })  : type = CustomLoadingType.detail,
        itemCount = 1;

  const CustomAppLoading.chat({
    super.key,
    this.message,
    this.itemCount = 6,
    this.isCenter = false,
  }) : type = CustomLoadingType.chat;

  @override
  Widget build(BuildContext context) {
    Widget shimmerContent;
    switch (type) {
      case CustomLoadingType.grid:
        shimmerContent = AppShimmer.grid(count: itemCount);
        break;
      case CustomLoadingType.card:
        shimmerContent = AppShimmer.card(count: itemCount);
        break;
      case CustomLoadingType.detail:
        shimmerContent = AppShimmer.detail();
        break;
      case CustomLoadingType.chat:
        shimmerContent = AppShimmer.chat(count: itemCount);
        break;
      case CustomLoadingType.list:
        shimmerContent = AppShimmer.list(count: itemCount);
        break;
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null && message!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00694C).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF00694C).withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12.r,
                        height: 12.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00694C)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        message!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF00694C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        Flexible(child: shimmerContent),
      ],
    );

    if (isCenter) {
      return Center(child: content);
    }
    return content;
  }
}
