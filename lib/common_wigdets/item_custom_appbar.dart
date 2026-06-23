// // ignore_for_file: deprecated_member_use
//
// import 'package:badges/badges.dart' as badges;
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:el_arbol/common_wigdets/profile_menu.dart';
// import 'package:el_arbol/constants/app_assets/assets_icons.dart';
// import 'package:el_arbol/constants/text_font_style.dart';
// import 'package:el_arbol/helpers/ui_helpers.dart';
// import 'package:svg_flutter/svg.dart';
//
// class ItemCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   const ItemCustomAppBar({super.key, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       title: Row(
//         children: [
//           SvgPicture.asset(AssetsIcons.purpleLogo),
//           UIHelper.horizontalSpaceSmall,
//           Padding(
//             padding: EdgeInsets.only(top: 6.h),
//             child: Text(title,
//               style: TextFontStyle.textStyle18Poppins500c222222.copyWith(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w600,
//               height: 1.22)),
//           ),
//         ],
//       ),
//       actions: [
//         SvgPicture.asset(AssetsIcons.trophy, color: Colors.black),
//
//         UIHelper.horizontalSpace(12.widget),
//         Padding(
//           padding: EdgeInsets.symmetric(vertical: 14.h),
//           child: badges.Badge(
//             showBadge: true,
//             badgeStyle: badges.BadgeStyle(badgeColor: Color(0xffFF8717)),
//             badgeAnimation: badges.BadgeAnimation.rotation(
//               animationDuration: Duration(seconds: 2),
//               colorChangeAnimationDuration: Duration(seconds: 1),
//               loopAnimation: false,
//               curve: Curves.fastOutSlowIn,
//               colorChangeAnimationCurve: Curves.easeInCubic,
//             ),
//             badgeContent: Text('3'),
//             child: SvgPicture.asset(AssetsIcons.gallery, color: Colors.black),
//           ),
//         ),
//
//         UIHelper.horizontalSpace(12.widget),
//         InkWell(
//           onTap: () {
//             showProfilePopup(context);
//           },
//           child: SvgPicture.asset(AssetsIcons.menu, color: Colors.black),
//         ),
//         UIHelper.horizontalSpace(12.widget),
//       ],
//     );
//   }
//
//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight); // Default height for AppBar
// }
