import 'package:el_arbol/common_wigdets/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/app_assets/assets_icons.dart';
import '../constants/app_colors.dart';
import '../featuers/customers/home/presentation/home_screen.dart';
import '../featuers/customers/home/presentation/shop_map_screen.dart';
import '../featuers/customers/home/presentation/leftover_pack_screen.dart';
import '../featuers/customers/home/presentation/customer_orders_screen.dart';
import '../featuers/customers/home/presentation/customer_profile_screen.dart';
import '../featuers/customers/orders/presentation/customer_cart_screen.dart';
import '../featuers/customers/message/messages_screen.dart';
import '../featuers/customers/profile/profile.dart';
import '../featuers/customers/wallet/tenant_wallet_screen.dart';

import '../featuers/employee_self_service/presentation/employee_dashboard_screen.dart';
import '../featuers/employee_self_service/presentation/staff_chat_screen.dart';
import '../featuers/employee_self_service/presentation/price_list_screen.dart';
import '../featuers/wholesale_b2b/presentation/wholesale_catalog_screen.dart';
import '../featuers/wholesale_b2b/presentation/wholesale_orders_screen.dart';

class CustomNavigation extends StatefulWidget {
  final UserRole? role;
  final int selectedIndex;


  const CustomNavigation({super.key, this.role,
    this.selectedIndex = 0,
  });

  @override
  State<CustomNavigation> createState() => _CustomNavigationState();
}

class _CustomNavigationState extends State<CustomNavigation> {
  final RxInt _selectedIndex = 0.obs;



  late final Map<UserRole, List<dynamic>> roleIcons = {
    UserRole.customer: [
      AssetsIcons.homeIcons,
      Icons.storefront_rounded,
      AssetsIcons.shoppingIcons,
      Icons.receipt_long_rounded,
      AssetsIcons.usernavIcons,
    ],
    UserRole.wholesale: [
      AssetsIcons.homeIcons,
      AssetsIcons.messagenavIcons,
      Icons.receipt_long_rounded,
      AssetsIcons.usernavIcons,
    ],
    UserRole.employeeSelfService: [
      AssetsIcons.homeIcons,
      AssetsIcons.messagenavIcons,
      Icons.price_change_outlined,
      AssetsIcons.usernavIcons,
    ],
    UserRole.staff: [
      AssetsIcons.homeIcons,
      AssetsIcons.messagenavIcons,
      Icons.price_change_outlined,
      AssetsIcons.usernavIcons,
    ],
  };

  late final Map<UserRole, List<String>> roleLabels = {
    UserRole.customer: [
      "Shop",
      "Stores",
      "Cart",
      "Orders",
      "Profile",
    ],
    UserRole.wholesale: [
      "Market",
      "Messages",
      "Orders",
      "Profile",
    ],
    UserRole.employeeSelfService: [
      "Dashboard",
      "Messages",
      "Prices",
      "Profile",
    ],
    UserRole.staff: [
      "Dashboard",
      "Messages",
      "Prices",
      "Profile",
    ],
  };

  late final Map<UserRole, List<Widget>> roleScreens = {
    UserRole.customer: [
      const HomeScreen(),
      const ShopMapScreen(),
      CustomerCartScreen(cartItems: RxList<Map<String, dynamic>>([])),
      const CustomerOrdersScreen(),
      const CustomerProfileScreen(),
    ],
    UserRole.wholesale: [
      const WholesaleCatalogScreen(),
      const MessagesScreen(isWholesale: true),
      const WholesaleOrdersScreen(),
      const ProfileScreen(role: UserRole.wholesale),
    ],
    UserRole.employeeSelfService: [
      const EmployeeDashboardScreen(),
      const StaffChatScreen(),
      const PriceListScreen(),
      const ProfileScreen(role: UserRole.employeeSelfService),
    ],
    UserRole.staff: [
      const EmployeeDashboardScreen(),
      const StaffChatScreen(),
      const PriceListScreen(),
      const ProfileScreen(role: UserRole.staff),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedIndex.value = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role ?? UserRole.customer;

    final icons = roleIcons[role] ?? roleIcons[UserRole.customer]!;
    final labels = roleLabels[role] ?? roleLabels[UserRole.customer]!;
    final screens = roleScreens[role] ?? roleScreens[UserRole.customer]!;

    if (_selectedIndex.value >= screens.length) {
      _selectedIndex.value = 0;
    }

    return Obx(() => WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout, color: Colors.blue, size: 30),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Exit App",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Are you sure you want to exit?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("No"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Yes"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );

        return shouldExit ?? false;
      },
        child:Scaffold(
      body: screens[_selectedIndex.value],
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (index) {
              final isSelected = _selectedIndex.value == index;
              final iconItem = icons[index];

              return InkWell(
                onTap: () => _selectedIndex.value = index,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (iconItem is IconData)
                        Icon(
                          iconItem,
                          size: 24.sp,
                          color: isSelected
                              ? const Color(0xFF00694C)
                              : AppColors.c87878A,
                        )
                      else
                        Image.asset(
                          iconItem.toString(),
                          width: 24.w,
                          height: 24.h,
                          color: isSelected
                              ? const Color(0xFF00694C)
                              : AppColors.c87878A,
                        ),
                      SizedBox(height: 3.h),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF00694C)
                              : AppColors.c87878A,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    )
    )
    );
  }
}
