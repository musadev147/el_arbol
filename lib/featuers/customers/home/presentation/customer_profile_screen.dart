import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../../route/app_pages.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:el_arbol/featuers/customers/profile/data/rx.dart';

import 'package:el_arbol/featuers/customers/tickets/presentation/customer_tickets_screen.dart' as el_arbol;
import 'package:el_arbol/featuers/customers/addresses/presentation/customer_addresses_screen.dart' as el_arbol_addr;
import 'package:el_arbol/featuers/customers/orders/presentation/customer_orders_screen.dart' as el_arbol_order;
import 'package:el_arbol/featuers/customers/wishlist/presentation/customer_wishlist_screen.dart' as el_arbol_wish;
import 'package:el_arbol/featuers/customers/notifications/presentation/customer_notifications_screen.dart' as el_arbol_notif;
import 'leftover_pack_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  // Profile Info state
  String _userName = 'Loading...';
  String _userEmail = '';
  String _userPhone = '';
  String _userGender = 'Male';
  DateTime _userDob = DateTime(1990, 1, 1);
  String? _profileImageUrl;

  late CustomerProfileRx _rx;
  final CustomerChangePasswordRx _changePasswordRx = CustomerChangePasswordRx(empty: null, dataFetcher: BehaviorSubject<void>());

  @override
  void initState() {
    super.initState();
    _rx = CustomerProfileRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
    _rx.fetchProfile();

    _rx.valueStreamData.listen((data) {
      if (data != null && mounted) {
        setState(() {
          // Parse user data
          final first = data['firstName'] ?? '';
          final last = data['lastName'] ?? '';
          _userName = data['fullName'] ?? '$first $last'.trim();
          if (_userName.isEmpty) _userName = 'Customer';
          _userEmail = data['email'] ?? '';
          
          _userGender = data['gender'] ?? _userGender;
          if (data['dob'] != null) {
            try {
              _userDob = DateTime.parse(data['dob'].toString());
            } catch (_) {}
          }

          if (data['profile'] != null && data['profile'] is Map) {
            final p = data['profile'];
            _userPhone = p['phone'] ?? _userPhone;
            _profileImageUrl = p['resolvedAvatar'] ?? p['avatar'] ?? _profileImageUrl;
            if (_profileImageUrl != null && _profileImageUrl!.isEmpty) {
              _profileImageUrl = null;
            }
            if (p['gender'] != null) _userGender = p['gender'];
            if (p['dob'] != null) {
              try {
                _userDob = DateTime.parse(p['dob'].toString());
              } catch (_) {}
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _rx.dispose();
    _changePasswordRx.dispose();
    super.dispose();
  }
  
  // Addresses state
  final List<String> _addresses = [
    'Calle de Alcalá 42, Madrid, ES',
    'Avenida de la Constitución 15, Sevilla, ES',
  ];

  // Saved Cards state
  final List<Map<String, String>> _savedCards = [
    {'brand': 'Visa', 'last4': '4242', 'expiry': '12/29'},
    {'brand': 'Mastercard', 'last4': '8890', 'expiry': '05/28'},
  ];

  // Notification switches
  bool _notifyOrderUpdates = true;
  bool _notifyPromos = true;
  bool _notifyPriceDrops = false;
  bool _notifyLeftovers = true;

  void _changeProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final success = await _rx.updateAvatar(File(pickedFile.path));
      if (success) {
        Fluttertoast.showToast(msg: 'Profile photo updated!');
      }
    }
  }

  void _addAddress() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Add Saved Address'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new address details',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _addresses.add(controller.text);
                  });
                  Fluttertoast.showToast(msg: 'Address added successfully!');
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addPaymentCard() {
    final formKey = GlobalKey<FormState>();
    final cardHolderController = TextEditingController();
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20.h,
                left: 20.w,
                right: 20.w,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Add New Payment Card',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    SizedBox(height: 12.h),

                    // Cardholder Name
                    const Text('Cardholder Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: cardHolderController,
                      validator: (v) => v!.isEmpty ? 'Please enter cardholder name' : null,
                      decoration: InputDecoration(
                        hintText: 'Jane Doe',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Card Number
                    const Text('Card Number', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: cardNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      validator: (v) => v!.length < 16 ? 'Enter valid 16-digit card number' : null,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '4242 4242 4242 4242',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Expiration & CVV
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Expiry Date (MM/YY)', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 6.h),
                              TextFormField(
                                controller: expiryController,
                                keyboardType: TextInputType.datetime,
                                maxLength: 5,
                                validator: (v) => !v!.contains('/') ? 'Use MM/YY format' : null,
                                decoration: InputDecoration(
                                  hintText: '12/29',
                                  counterText: '',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CVV', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 6.h),
                              TextFormField(
                                controller: cvvController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 3,
                                validator: (v) => v!.length < 3 ? 'Invalid CVV' : null,
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '•••',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Save card
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final number = cardNumberController.text;
                            final brand = number.startsWith('4') ? 'Visa' : 'Mastercard';
                            final last4 = number.substring(number.length - 4);
                            
                            setState(() {
                              _savedCards.add({
                                'brand': brand,
                                'last4': last4,
                                'expiry': expiryController.text,
                              });
                            });
                            
                            Fluttertoast.showToast(msg: 'Stripe Card Saved Successfully!');
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00694C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: const Text('Link Secure Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editProfileDetails() {
    final nameController = TextEditingController(text: _userName);
    final phoneController = TextEditingController(text: _userPhone);
    String selectedGender = _userGender;
    DateTime tempDob = _userDob;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20.h,
                left: 20.w,
                right: 20.w,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Edit Personal Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  SizedBox(height: 12.h),

                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter full name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6.h),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempDob,
                        firstDate: DateTime(1920),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setModalState(() {
                          tempDob = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMMM yyyy').format(tempDob)),
                          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedGender = val;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 24.h),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        final names = nameController.text.trim().split(' ');
                        final firstName = names.isNotEmpty ? names.first : '';
                        final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
                        final success = await _rx.updateProfile({
                          "firstName": firstName,
                          "lastName": lastName,
                          "phone": phoneController.text,
                          "gender": selectedGender,
                          "dob": DateFormat('yyyy-MM-dd').format(tempDob),
                        });
                        if (success) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00694C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _changePassword() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text != confirmController.text) {
                  Fluttertoast.showToast(msg: 'New passwords do not match.');
                  return;
                }
                if (newPasswordController.text.length < 6) {
                  Fluttertoast.showToast(msg: 'Password must be at least 6 characters.');
                  return;
                }
                final success = await _changePasswordRx.changePassword(
                  oldPasswordController.text,
                  newPasswordController.text,
                );
                if (success) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'El Árbol Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text(
                'We respect your privacy and protect your personal details. '
                'All transaction card inputs are processed securely via mock Stripe integrations. '
                'Your location information is strictly used to measure distance filters to nearest stores on the finder map. '
                'We do not sell your grocery ordering habits to advertising agencies.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Click & Collect orders must be collected within 24 hours of confirmation.\n'
            '2. Leftover packs are limited-quantity deals and are pickup-only. No refunds are available after reservation.\n'
            '3. Card details are processed securely and stored locally for checkout convenience.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Q: How much does home delivery cost?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
              Text('A: A standard delivery fee of €3.90 is applied to all delivery orders.', style: TextStyle(fontSize: 11.sp)),
              const Divider(),
              Text('Q: What is Click & Collect?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
              Text('A: Order online, select the nearest store, and collect in person. Zero delivery fees!', style: TextStyle(fontSize: 11.sp)),
              const Divider(),
              Text('Q: What are leftover packs?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
              Text('A: To reduce food waste, shops offer surplus organic food at €5. Packs must be picked up in person.', style: TextStyle(fontSize: 11.sp)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Info
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _changeProfileImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 36.r,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                          child: _profileImageUrl == null
                              ? Icon(Icons.person, color: primaryColor, size: 36.r)
                              : null,
                        ),
                        Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF151E13),
                          ),
                        ),
                        Text(
                          _userEmail,
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.cake, size: 12.r, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat('dd MMM yyyy').format(_userDob),
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: primaryColor),
                    onPressed: _editProfileDetails,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Account Settings
            Text(
              'Account Settings',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: primaryColor),
                    title: const Text('My Addresses'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Get.to(() => const el_arbol_addr.CustomerAddressesScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_border, color: primaryColor),
                    title: const Text('My Wishlist'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Get.to(() => const el_arbol_wish.CustomerWishlistScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined, color: primaryColor),
                    title: const Text('My Orders'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Get.to(() => const el_arbol_order.CustomerOrdersScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.support_agent, color: primaryColor),
                    title: const Text('Support Tickets'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Get.to(() => const el_arbol.CustomerSupportTicketsScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.food_bank_outlined, color: primaryColor),
                    title: const Text('Surplus Leftover Packs'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Get.to(() => const LeftoverPackScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_none, color: primaryColor),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Get.to(() => const el_arbol_notif.CustomerNotificationsScreen()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Security Settings
            Text(
              'Security & Login',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: primaryColor),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: _changePassword,
              ),
            ),
            SizedBox(height: 20.h),


            // Legal & Information section
            Text(
              'Information & Policies',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: primaryColor),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _showPrivacyPolicy,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.gavel, color: primaryColor),
                    title: const Text('Terms & Conditions'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _showTermsAndConditions,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_center_outlined, color: primaryColor),
                    title: const Text('FAQ & Help Guide'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _showFAQ,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),


            // Log Out & Delete Account
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.offAllNamed(Routes.ROLE_SELECTION);
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                          content: const Text('Are you sure you want to permanently delete your El Árbol account? This cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Get.offAllNamed(Routes.ROLE_SELECTION);
                                Fluttertoast.showToast(msg: 'Account deleted.');
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Delete Permanently'),
                            )
                          ],
                        ),
                      );
                    },
                    child: const Text('Delete Account', style: TextStyle(color: Colors.grey)),
                  ),
                )
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
