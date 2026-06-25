import 'package:el_arbol/common_wigdets/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/app_assets/assets_icons.dart';
import '../constants/app_colors.dart';
import '../featuers/customers/home/presentation/home_screen.dart';
import '../featuers/customers/message/messages_screen.dart';
import '../featuers/customers/profile/profile.dart';
import '../featuers/customers/wallet/tenant_wallet_screen.dart';

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



  late final Map<UserRole, List<String>> roleIcons = {
    UserRole.wholesale: [
      AssetsIcons.homeIcons,
      AssetsIcons.messagenavIcons,
      AssetsIcons.propertyIcons,
      AssetsIcons.usernavIcons,
    ],
    UserRole.shopPortal: [
      AssetsIcons.homeIcons,
      AssetsIcons.messagenavIcons,
      AssetsIcons.propertyIcons,
      AssetsIcons.usernavIcons,
    ],
    UserRole.employeeSelfService: [
      AssetsIcons.homeIcons,
      AssetsIcons.messagenavIcons,
      AssetsIcons.propertyIcons,
      AssetsIcons.usernavIcons,
    ],
  };

  late final Map<UserRole, List<String>> roleLabels = {
    UserRole.wholesale: [
      "Market",
      "Messages",
      "Orders",
      "Profile",
    ],
    UserRole.shopPortal: [
      "Inventory",
      "Orders",
      "Terminal",
      "Profile",
    ],
    UserRole.employeeSelfService: [
      "Dashboard",
      "Messages",
      "Payslips",
      "Profile",
    ],
  };

  late final Map<UserRole, List<Widget>> roleScreens = {
    UserRole.wholesale: [
      HomeScreen(),
      MessagesScreen(),
      TenantWallet(),
      ProfileScreen(),
    ],
    UserRole.shopPortal: [
      HomeScreen(),
      MessagesScreen(),
      TenantWallet(),
      ProfileScreen(),
    ],
    UserRole.employeeSelfService: [
      HomeScreen(),
      MessagesScreen(),
      TenantWallet(),
      ProfileScreen(),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedIndex.value = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role ?? UserRole.wholesale;

    final icons = roleIcons[role]!;
    final labels = roleLabels[role]!;
    final screens = roleScreens[role]!;

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
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final isSelected = _selectedIndex.value == index;

            return GestureDetector(
              onTap: () => _selectedIndex.value = index,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    icons[index],
                    width: 26.w,
                    height: 26.h,
                    color: isSelected
                        ? const Color(0xFF00694C)
                        : AppColors.c87878A,
                  ),
                  if (isSelected)
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00694C),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    )
    )
    );
  }
}
