import 'dart:async';
import 'package:el_arbol/common_wigdets/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/app_assets/assets_icons.dart';
import '../constants/app_colors.dart';
import '../featuers/customers/home/presentation/home_screen.dart';
import '../featuers/customers/home/presentation/shop_map_screen.dart';
import '../featuers/customers/orders/presentation/customer_orders_screen.dart';
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
import '../featuers/customers/tickets/data/customer_tickets_rx.dart';
import '../featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:rxdart/rxdart.dart';
import '../helpers/di.dart';

import '../featuers/customers/tickets/presentation/customer_chat_screen.dart';
import '../featuers/wholesale_b2b/presentation/wholesale_chat_screen.dart';

class CustomNavigation extends StatefulWidget {
  final int initialIndex;
  final UserRole role;

  const CustomNavigation({
    super.key,
    this.initialIndex = 0,
    this.role = UserRole.customer,
  });

  @override
  State<CustomNavigation> createState() => _CustomNavigationState();
}

class _CustomNavigationState extends State<CustomNavigation> {
  late final RxInt _selectedIndex;
  late UserRole role;
  CustomerCartRx? _cartRx;
  Timer? _chatPollingTimer;

  late final Map<UserRole, List<dynamic>> roleIcons = {
    UserRole.customer: [
      AssetsIcons.homeIcons,
      Icons.storefront_rounded,
      Icons.receipt_long_rounded,
      AssetsIcons.messagenavIcons,
      AssetsIcons.usernavIcons,
    ],
    UserRole.wholesale: [
      AssetsIcons.homeIcons,
      Icons.receipt_long_rounded,
      AssetsIcons.messagenavIcons,
      AssetsIcons.usernavIcons,
    ],
    UserRole.employeeSelfService: [
      AssetsIcons.homeIcons,
      Icons.price_change_outlined,
      AssetsIcons.messagenavIcons,
      AssetsIcons.usernavIcons,
    ],
    UserRole.staff: [
      AssetsIcons.homeIcons,
      Icons.price_change_outlined,
      AssetsIcons.messagenavIcons,
      AssetsIcons.usernavIcons,
    ],
  };

  late final Map<UserRole, List<String>> roleLabels = {
    UserRole.customer: [
      "Shop",
      "Stores",
      "Orders",
      "Messages",
      "Profile",
    ],
    UserRole.wholesale: [
      "Market",
      "Orders",
      "Messages",
      "Profile",
    ],
    UserRole.employeeSelfService: [
      "Staff Dashboard",
      "Prices",
      "Messages",
      "Profile",
    ],
    UserRole.staff: [
      "Staff Dashboard",
      "Prices",
      "Messages",
      "Profile",
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.obs;
    final savedRoleStr = appData.read('user_role')?.toString();
    if (widget.role != UserRole.customer) {
      role = widget.role;
    } else if (savedRoleStr != null && savedRoleStr.isNotEmpty) {
      role = UserRole.fromString(savedRoleStr);
    } else {
      role = widget.role;
    }

    if (role == UserRole.customer || role == UserRole.staff || role == UserRole.employeeSelfService) {
      _cartRx = CustomerCartRx.instance;
      _cartRx?.fetchBasket();
    }

    // Initial fetch for tickets & chats
    if (role == UserRole.customer) {
      CustomerTicketsRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>()).fetchTickets();
    } else if (role == UserRole.wholesale) {
      WholesaleTicketsRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>()).fetchTickets();
    } else if (role == UserRole.staff || role == UserRole.employeeSelfService) {
      StaffChatRx.instance.fetchChatMessages(silent: true);
    }

    // Set up periodic polling for real-time unread messages & notifications across all roles
    _chatPollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        if (role == UserRole.staff || role == UserRole.employeeSelfService) {
          StaffChatRx.instance.fetchChatMessages(silent: true);
        } else if (role == UserRole.customer) {
          CustomerTicketsRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>()).fetchTickets();
        } else if (role == UserRole.wholesale) {
          WholesaleTicketsRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>()).fetchTickets();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      setState(() {
        role = widget.role;
      });
    }
  }

  @override
  void dispose() {
    _chatPollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [];

    switch (role) {
      case UserRole.customer:
        screens = [
          const HomeScreen(),
          const ShopMapScreen(),
          const CustomerOrdersScreen(),
          const CustomerChatScreen(),
          const CustomerProfileScreen(),
        ];
        break;
      case UserRole.wholesale:
        screens = [
          const WholesaleCatalogScreen(),
          const WholesaleOrdersScreen(),
          const WholesaleChatScreen(),
          const ProfileScreen(role: UserRole.wholesale),
        ];
        break;
      case UserRole.staff:
      case UserRole.employeeSelfService:
        screens = [
          const EmployeeDashboardScreen(),
          const PriceListScreen(),
          const StaffChatScreen(),
          const ProfileScreen(role: UserRole.staff),
        ];
        break;
    }

    if (_selectedIndex.value >= screens.length) {
      _selectedIndex.value = 0;
    }

    final icons = roleIcons[role] ?? roleIcons[UserRole.customer]!;
    final labels = roleLabels[role] ?? roleLabels[UserRole.customer]!;

    return Obx(() => WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00694C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded, color: Color(0xFF00694C), size: 32),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      "Exit App",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF151E13),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "Are you sure you want to exit El Árbol?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "No",
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00694C),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
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
      child: Scaffold(
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
                  if (labels[index] == "Messages") {
                    if (role == UserRole.employeeSelfService || role == UserRole.staff) {
                      StaffChatRx.instance.markAllAsRead();
                    }
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

                          // Messages tab unread count badge for Staff, Customer, and Wholesale
                          if (labels[index] == "Messages") {
                            return Obx(() {
                              int unreadCount = 0;
                              if (role == UserRole.employeeSelfService || role == UserRole.staff) {
                                unreadCount = StaffChatRx.instance.unreadCountRx.value;
                              } else if (role == UserRole.wholesale) {
                                unreadCount = SupportTicketUnreadManager.instance.wholesaleUnreadCountRx.value;
                              } else if (role == UserRole.customer) {
                                unreadCount = SupportTicketUnreadManager.instance.customerUnreadCountRx.value;
                              }

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
