import 'dart:async';
import 'package:el_arbol/common_wigdets/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/app_assets/assets_icons.dart';
import '../constants/app_colors.dart';
import '../featuers/customers/home/presentation/home_screen.dart';
import '../featuers/customers/home/presentation/shop_map_screen.dart';
import '../featuers/customers/home/presentation/customer_orders_screen.dart';
import '../featuers/customers/home/presentation/customer_profile_screen.dart';
import '../featuers/customers/orders/presentation/customer_cart_screen.dart';
import '../featuers/customers/orders/data/customer_orders_rx.dart';
import '../featuers/customers/profile/profile.dart';

import '../featuers/employee_self_service/presentation/employee_dashboard_screen.dart';
import '../featuers/employee_self_service/presentation/staff_chat_screen.dart';
import '../featuers/employee_self_service/presentation/price_list_screen.dart';
import '../featuers/employee_self_service/data/rx.dart';
import '../featuers/employee_self_service/model/staff_chat_model.dart';
import '../helpers/support_ticket_unread_manager.dart';
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
      Icons.storefront_rounded,
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
      "Store",
      "Orders",
      "Profile",
    ],
    UserRole.employeeSelfService: [
      "Staff Dashboard",
      "Messages",
      "Prices",
      "Profile",
    ],
    UserRole.staff: [
      "Staff Dashboard",
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
      const ShopMapScreen(),
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

  Timer? _staffChatPollingTimer;

  @override
  void initState() {
    super.initState();
    _selectedIndex.value = widget.selectedIndex;
    if (widget.role == null || widget.role == UserRole.customer) {
      CustomerCartRx.instance.fetchBasket();
    }
    if (widget.role == UserRole.employeeSelfService || widget.role == UserRole.staff) {
      StaffChatRx.instance.fetchChatMessages(silent: true);
      _staffChatPollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (mounted) {
          StaffChatRx.instance.fetchChatMessages(silent: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _staffChatPollingTimer?.cancel();
    super.dispose();
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
                onTap: () {
                  _selectedIndex.value = index;
                  if ((role == UserRole.employeeSelfService || role == UserRole.staff) && index == 1) {
                    StaffChatRx.instance.markAllAsRead();
                  }
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          final Widget iconWidget = (iconItem is IconData)
                              ? Icon(
                                  iconItem,
                                  size: 26.sp,
                                  color: isSelected
                                      ? const Color(0xFF00694C)
                                      : AppColors.c87878A,
                                )
                              : Image.asset(
                                  iconItem.toString(),
                                  width: 26.w,
                                  height: 26.h,
                                  color: isSelected
                                      ? const Color(0xFF00694C)
                                      : AppColors.c87878A,
                                );

                          // Customer Cart badge on tab 2
                          if (role == UserRole.customer && index == 2) {
                            return StreamBuilder(
                              stream: CustomerCartRx.instance.valueStreamData,
                              builder: (context, snapshot) {
                                final count = CustomerCartRx.instance.itemCount;
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    iconWidget,
                                    if (count > 0)
                                      Positioned(
                                        right: -6,
                                        top: -4,
                                        child: Container(
                                          padding: EdgeInsets.all(3.r),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentOrange,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.accentOrange.withValues(alpha: 0.4),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                                          child: Center(
                                            child: Text(
                                              '$count',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          }

                          // Staff Chat Messages unread count badge on tab 1
                          if ((role == UserRole.employeeSelfService || role == UserRole.staff) && index == 1) {
                            return Obx(() {
                              final unreadCount = StaffChatRx.instance.unreadCountRx.value;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  iconWidget,
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -8,
                                      top: -4,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentOrange,
                                          borderRadius: BorderRadius.circular(10.r),
                                          border: Border.all(color: Colors.white, width: 1.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.accentOrange.withValues(alpha: 0.4),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                                        child: Center(
                                          child: Text(
                                            unreadCount > 99 ? '99+' : '$unreadCount',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            });
                          }

                          // Support Ticket unread replies badge on Profile tab for Customer & Wholesale
                          if ((role == UserRole.customer || role == UserRole.wholesale) &&
                              index == labels.length - 1) {
                            return Obx(() {
                              final unreadCount = role == UserRole.wholesale
                                  ? SupportTicketUnreadManager.instance.wholesaleUnreadCountRx.value
                                  : SupportTicketUnreadManager.instance.customerUnreadCountRx.value;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  iconWidget,
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -8,
                                      top: -4,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentOrange,
                                          borderRadius: BorderRadius.circular(10.r),
                                          border: Border.all(color: Colors.white, width: 1.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.accentOrange.withValues(alpha: 0.4),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                                        child: Center(
                                          child: Text(
                                            unreadCount > 99 ? '99+' : '$unreadCount',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            });
                          }

                          return iconWidget;
                        },
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
