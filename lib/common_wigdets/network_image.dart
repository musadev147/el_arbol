import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/constants/app_assets/assets_image.dart';

import 'app_shimmer.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({super.key});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: '',
      placeholder:
          (context, url) =>
              AppShimmer.box(height: 148.h, width: 148.w, borderRadius: BorderRadius.circular(8.r)),
      errorWidget:
          (context, url, error) =>
              Image.asset(AssetsImages.editProductImage1, fit: BoxFit.fill),
      height: 148.h,
      width: 148.w,
      fit: BoxFit.fill,
    );
  }
}
