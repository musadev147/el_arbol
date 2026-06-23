import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:el_arbol/common_wigdets/custom_theme.dart';
import 'package:svg_flutter/svg.dart';

class CustomImageView extends StatelessWidget {
  const CustomImageView({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.placeHolder = '',
    this.alignment,
    this.onTap,
    this.margin,
    this.radius,
    this.border,
    this.iconSize,
  });

  final Object? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final String placeHolder;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<CustomThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final isDark = themeProvider.isDarkMode;
    return alignment != null
        ? Align(
      alignment: alignment!,
      child: _buildWidget(),
    )
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      key: key,
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: _buildCircleImage(),
      ),
    );
  }

  _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: _buildImageWithBorder(),
      );
    } else {
      return _buildImageWithBorder();
    }
  }

  _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildImageView() {
    //  IconData check
    if (imagePath is IconData) {
      return Icon(
        imagePath as IconData, // IconData hisebe type cast kora holo
        color: color,
        size: iconSize ?? height ?? width,
      );
    }

    final imagePathString = imagePath as String?; // Baki logic er jonyo String? hisebe cast kora holo

    if (imagePathString != null) {
      switch (imagePathString.imageType) {
      // ImageType case gulo
        case ImageType.svg:
          return SizedBox(
            key: key,
            height: height,
            width: width,
            child: SvgPicture.asset(
              imagePathString,
              height: height,
              width: width,
              fit: fit ?? BoxFit.contain,
              colorFilter: color != null
                  ? ColorFilter.mode(
                  color ?? Colors.transparent, BlendMode.srcIn)
                  : null,
            ),
          );
        case ImageType.file:
          return Image.file(
            File(imagePathString),
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
          );
        case ImageType.network:
          return CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            imageUrl: imagePathString,
            color: color,
            placeholder: (context, url) => SizedBox(
              height: 30.h,
              width: 30.w,
              child: LinearProgressIndicator(
                color: Colors.grey.shade200,
                backgroundColor: Colors.grey.shade100,
              ),
            ),
            errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade50,
                child: Image.asset("assets/images/placeholder_image.png",
                    fit: BoxFit.cover)),
          );
        case ImageType.lottie:
          return Lottie.asset(
            imagePathString,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            repeat: false,
            animate: true,
          );
        case ImageType.png:
        default:
          return Image.asset(
            imagePathString,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                  color: Colors.grey.shade50,
                  child: Image.asset("assets/images/placeholder_image.png",
                      fit: BoxFit.cover));
            },
          );
      }
    }
    return const SizedBox();
  }
}


extension ImageTypeExtension on String {
  ImageType get imageType {
    final lower = toLowerCase();
    if (startsWith('http://') || startsWith('https://')) {
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('file://') || File(this).existsSync()) {
      return ImageType.file;
    } else if (endsWith('.json')) {
      return ImageType.lottie;
    } else if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return ImageType.png;
    }
    return ImageType.unknown;
  }
}

enum ImageType { svg, png, network, file, lottie, unknown }