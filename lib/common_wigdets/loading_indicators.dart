import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget loadingIndicatorCircle({
  required BuildContext context,
  Color? color,
  double? size,
}) {
  double loaderSize = 200;
  return DotLottieLoader.fromAsset('Assets.lottie.appLoading',
      frameBuilder: (BuildContext ctx, DotLottie? dotlottie) {
    if (dotlottie != null) {
      return Center(
        child: Container(
          child: Lottie.memory(dotlottie.animations.values.single,
              height: loaderSize, width: loaderSize),
        ),
      );
    } else {
      return Container();
    }
  });
}

Widget shimmer({
  String? name,
  required BuildContext context,
  Color? color,
  double? size,
}) {
  return Center(
    child: Container(
      color: color,
      // child: Lottie.asset(name ?? Assets.lottie.imageShimmer,
      //     fit: BoxFit.cover,
      //     width: size ?? double.infinity,
      //     height: size ?? 150),
    ),
  );
}
