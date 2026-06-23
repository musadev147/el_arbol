import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import 'package:el_arbol/featuers/placeholders.dart';
import '../networks/api_acess.dart';

class PropertyStack extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final double? iconSize;
  final EdgeInsetsGeometry? margin;
  final BoxShadow? shadow;
  final int propertyId;

  const PropertyStack({
    super.key,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
    this.margin,
    this.shadow,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(top: 40.h, left: 16.w, right: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTap ?? () => Get.back(),
            child: Container(
              height: size ?? 48.w,
              width: size ?? 48.w,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  shadow ??
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: iconSize ?? 20.sp,
                color: iconColor ?? AppColors.c1C1C28,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "share") {
                final String shareText =
                    "Check this property 🏠\nProperty ID: $propertyId";
                Share.share(shareText);
              } else if (value == "edit") {
                Get.to(
                  () =>
                      AddNewPropertyStep1(propertyId: propertyId, isEdit: true),
                );
              } else if (value == "delete") {
                final confirm = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: const Text(
                      "Are you sure you want to delete this property?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final success = await deletePropertyRx.propertyDelete(
                    id: propertyId,
                  );

                  if (success) {
                    Get.back();
                  }
                }
              } else if (value == "create_agent") {
                Get.to(() => CreateNewTenantScreen(initialTab: 0,));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "share",
                child: Row(
                  children: const [
                    Icon(Icons.share, size: 18, color: Colors.cyan),
                    SizedBox(width: 8),
                    Text("Share"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "edit",
                child: Row(
                  children: const [
                    Icon(Icons.edit, size: 18, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "delete",
                child: Row(
                  children: const [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Delete"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "create_agent",
                child: Row(
                  children: const [
                    Icon(Icons.person_add, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Create Agent"),
                  ],
                ),
              ),
            ],
            child: Container(
              height: size ?? 48.w,
              width: size ?? 48.w,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  shadow ??
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                ],
              ),
              child: Icon(
                Icons.more_vert,
                size: iconSize ?? 20.sp,
                color: iconColor ?? AppColors.c1C1C28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
