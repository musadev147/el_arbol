import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_assets/assets_image.dart';

class CustomBackground extends StatelessWidget {
  final Widget? child;
  final String? backgroundImage;
  final double? imageWidth;
  final double? top;
  final double? left;
  final double opacity;

  const CustomBackground({
    super.key,
    this.child,
    this.backgroundImage,
    this.imageWidth,
    this.top,
    this.left,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: top ?? -40.h,
          left: left ?? -40.w,
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              backgroundImage ?? AssetsImages.cicrleappImages, // default asset
              width: imageWidth ?? 300.w,
              fit: BoxFit.contain,
            ),
          ),
        ),

        if (child != null) child!,
      ],
    );
  }
}
