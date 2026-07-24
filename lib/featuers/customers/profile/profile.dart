import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:el_arbol/common_wigdets/user_role.dart';
import 'package:el_arbol/route/app_pages.dart';
import 'package:el_arbol/featuers/employee_self_service/presentation/update_staff_profile_screen.dart';
import 'dart:io';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:el_arbol/featuers/customers/tickets/presentation/customer_tickets_screen.dart' as el_arbol;
import 'package:el_arbol/featuers/customers/addresses/presentation/customer_addresses_screen.dart' as el_arbol_addr;
import 'package:el_arbol/featuers/customers/orders/presentation/customer_orders_screen.dart' as el_arbol_order;
import 'package:el_arbol/featuers/customers/wishlist/presentation/customer_wishlist_screen.dart' as el_arbol_wish;
import 'package:el_arbol/featuers/customers/notifications/presentation/customer_notifications_screen.dart' as el_arbol_notif;
import '../../wholesale_b2b/data/wholesale_api.dart';
import 'data/rx.dart';

class ProfileScreen extends StatefulWidget {
  final UserRole? role;
  const ProfileScreen({super.key, this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _businessName = 'Valencia Food Group S.L.';
  String _cif = 'B-90812345';
  String _contactPerson = 'Mario Silva';
  String _businessEmail = 'purchasing@valenciafood.com';
  String _contactPhone = '+34 961 234 567';
  String? _profileImageUrl;

  // Personal details state variables
  String _personalPhone = '+34 622 334 455';
  String _personalGender = 'Male';
  DateTime _personalDob = DateTime(1988, 10, 12);

  // Addresses state
  final List<String> _addresses = [
    'Warehouse Row A, Valencia, ES',
    'Calle Mayor 8, Madrid, ES',
  ];

  // Saved Cards state
  final List<Map<String, String>> _savedCards = [
    {'brand': 'Visa Business', 'last4': '9090', 'expiry': '10/28'},
  ];

  // Employee details
  final String _employeeName = 'Sofia Rossi';
  final String _employeeEmail = 'sofia.rossi@elarbol.com';

  // Wholesale B2B specific
  late WholesaleProfileRx _wholesaleProfileRx;

  // Customer specific
  late CustomerProfileRx _customerProfileRx;
  final CustomerChangePasswordRx _changePasswordRx = CustomerChangePasswordRx(empty: null, dataFetcher: BehaviorSubject<void>());

  @override
  void initState() {
    super.initState();
    if (widget.role == UserRole.wholesale) {
      _wholesaleProfileRx = WholesaleProfileRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
      _wholesaleProfileRx.fetchProfile();
      
      _wholesaleProfileRx.valueStreamData.listen((data) {
        if (data != null && mounted) {
          setState(() {
            _businessName = data['business_name'] ?? _businessName;
            _cif = data['cif'] ?? _cif;
            _contactPerson = data['contact_person'] ?? _contactPerson;
            _businessEmail = data['email'] ?? _businessEmail;
            _contactPhone = data['contact_phone'] ?? _contactPhone;
            _profileImageUrl = data['avatar'] ?? _profileImageUrl;
          });
        }
      });
    } else if (widget.role == UserRole.customer) {
      _customerProfileRx = CustomerProfileRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
      _customerProfileRx.fetchProfile();

      _customerProfileRx.valueStreamData.listen((data) {
        if (data != null && mounted) {
          setState(() {
            _personalPhone = data['phone'] ?? _personalPhone;
            _personalGender = data['gender'] ?? _personalGender;
            if (data['dob'] != null) {
              try {
                _personalDob = DateTime.parse(data['dob']);
              } catch (_) {}
            }
            _profileImageUrl = data['avatar'] ?? _profileImageUrl;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.role == UserRole.wholesale) {
      _wholesaleProfileRx.dispose();
    } else if (widget.role == UserRole.customer) {
      _customerProfileRx.dispose();
      _changePasswordRx.dispose();
    }
    super.dispose();
  }

  void _editB2bDetails() {
    final nameController = TextEditingController(text: _businessName);
    final contactController = TextEditingController(text: _contactPerson);
    final phoneController = TextEditingController(text: _contactPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
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
                'Edit Business Details',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              SizedBox(height: 12.h),

              const Text('Registered Business Name', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6.h),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
              SizedBox(height: 16.h),

              const Text('Contact Person Name', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6.h),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
              SizedBox(height: 16.h),

              const Text('Contact Phone', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6.h),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.role == UserRole.wholesale) {
                      final success = await _wholesaleProfileRx.updateProfile({
                        "business_name": nameController.text,
                        "contact_person": contactController.text,
                        "contact_phone": phoneController.text,
                      });
                      if (success) {
                        Fluttertoast.showToast(msg: 'Business details updated successfully!');
                        Navigator.pop(context);
                      }
                    } else {
                      setState(() {
                        _businessName = nameController.text;
                        _contactPerson = contactController.text;
                        _contactPhone = phoneController.text;
                      });
                      Fluttertoast.showToast(msg: 'Business details updated successfully!');
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
                
                final role = widget.role ?? UserRole.customer;
                if (role == UserRole.wholesale) {
                  try {
                    await WholesaleApi.instance.changePassword(
                      oldPasswordController.text,
                      newPasswordController.text,
                    );
                    Fluttertoast.showToast(msg: 'Password updated successfully!');
                    Navigator.pop(context);
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'Failed to update password');
                  }
                } else if (role == UserRole.customer) {
                  final success = await _changePasswordRx.changePassword(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                  if (success) Navigator.pop(context);
                } else {
                  // Fallback for other roles or mock
                  Fluttertoast.showToast(msg: 'Password updated successfully!');
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

  void _addAddress() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Add Shipping Warehouse Address'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter warehouse details'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _addresses.add(controller.text);
                  });
                  Fluttertoast.showToast(msg: 'Warehouse address added.');
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
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
                Text('Link B2B Corporate Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                const Divider(),
                TextFormField(
                  controller: cardHolderController,
                  validator: (v) => v!.isEmpty ? 'Enter holder name' : null,
                  decoration: const InputDecoration(labelText: 'Cardholder Name'),
                ),
                TextFormField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (v) => v!.length < 16 ? 'Invalid Card Number' : null,
                  decoration: const InputDecoration(labelText: 'Card Number', counterText: ''),
                ),
                TextFormField(
                  controller: expiryController,
                  validator: (v) => !v!.contains('/') ? 'MM/YY' : null,
                  decoration: const InputDecoration(
                    labelText: 'Expiry (MM/YY)',
                    hintText: '12/28',
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final number = cardNumberController.text;
                        final brand = number.startsWith('4') ? 'Visa Business' : 'Mastercard Corporate';
                        final last4 = number.substring(number.length - 4);
                        setState(() {
                          _savedCards.add({
                            'brand': brand,
                            'last4': last4,
                            'expiry': expiryController.text,
                          });
                        });
                        Fluttertoast.showToast(msg: 'Corporate card linked successfully!');
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
                    child: const Text('Add Card', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showB2bFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Wholesale FAQ'),
        content: const SingleChildScrollView(
          child: Text(
            'Q: How are wholesale orders invoiced?\n'
            'A: Invoices are sent via business email upon warehouse shipment.\n\n'
            'Q: Can I adjust payment amounts?\n'
            'A: Yes. Admin reviews adjustments and issues partial refunds, which show up in your net invoices.'
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'El Árbol B2B & Wholesale Privacy Policy:\n\n'
            '1. We securely protect corporate registration details.\n'
            '2. Invoicing, payment card structures, and CIF data are encrypted locally and handled via secure Stripe sessions.\n'
            '3. Sourced store locations from Find Shop on Map are processed to calculate distances for delivery optimization.'
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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
            '1. Wholesale orders must comply with bulk catalog purchasing agreements.\n'
            '2. Any adjustments or refund issues are governed by store manager verification.\n'
            '3. Access CIF registration approval requires active Spain retail tax credential files.'
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _logout() {
    Get.offAllNamed(Routes.ROLE_SELECTION);
  }

  Future<void> _changeProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      if (widget.role == UserRole.customer) {
        final success = await _customerProfileRx.updateAvatar(File(image.path));
        if (success) {
          // Success handled by Rx toast
        }
      } else {
        // Mock fallback
        setState(() {
          _profileImageUrl = null;
        });
        Fluttertoast.showToast(msg: 'Avatar mocked upload successful');
      }
    }
  }

  void _editPersonalInfo() {
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController(text: _personalPhone);
    String selectedGender = _personalGender;
    DateTime selectedDob = _personalDob;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) {
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
                    Text('Edit Personal Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    const Divider(),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Personal Phone'),
                      validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedGender = val);
                      },
                    ),
                    SizedBox(height: 12.h),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date of Birth'),
                      subtitle: Text('${selectedDob.day}/${selectedDob.month}/${selectedDob.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDob,
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setModalState(() => selectedDob = date);
                        }
                      },
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (widget.role == UserRole.customer) {
                              final success = await _customerProfileRx.updateProfile({
                                'phone': phoneController.text,
                                'gender': selectedGender,
                                'dob': selectedDob.toIso8601String().split('T').first,
                              });
                              if (success) {
                                Navigator.pop(ctx);
                              }
                            } else {
                              setState(() {
                                _personalPhone = phoneController.text;
                                _personalGender = selectedGender;
                                _personalDob = selectedDob;
                              });
                              Fluttertoast.showToast(msg: 'Personal details updated!');
                              Navigator.pop(ctx);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
                        child: const Text('Save Details', style: TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    final currentRole = widget.role ?? UserRole.wholesale;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          currentRole == UserRole.wholesale ? 'B2B Client Profile' : 'Staff Profile',
          style: TextStyle(
            color: const Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (currentRole == UserRole.wholesale) {
                            _changeProfileImage();
                          } else {
                            Get.to(() => UpdateStaffProfileScreen(
                              initialName: _employeeName,
                              initialPhone: _personalPhone,
                              initialPhoto: _profileImageUrl,
                            ));
                          }
                        },
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
                                  ? Icon(
                                      currentRole == UserRole.wholesale
                                          ? Icons.business_center
                                          : Icons.badge,
                                      color: primaryColor,
                                      size: 36.r,
                                    )
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
                              currentRole == UserRole.wholesale ? _businessName : _employeeName,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF151E13),
                              ),
                            ),
                            Text(
                              currentRole == UserRole.wholesale ? _businessEmail : _employeeEmail,
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                            ),
                            if (currentRole == UserRole.wholesale) ...[
                              SizedBox(height: 4.h),
                              Text(
                                'CIF: $_cif  •  Contact: $_contactPerson',
                                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (currentRole == UserRole.wholesale || currentRole == UserRole.staff || currentRole == UserRole.employeeSelfService)
                        IconButton(
                          icon: const Icon(Icons.edit, color: primaryColor),
                          onPressed: () {
                            if (currentRole == UserRole.wholesale) {
                              _editB2bDetails();
                            } else {
                              Get.to(() => UpdateStaffProfileScreen(
                                initialName: _employeeName,
                                initialPhone: _personalPhone,
                                initialPhoto: _profileImageUrl,
                              ));
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              if (currentRole != UserRole.staff && currentRole != UserRole.employeeSelfService) ...[
                // Personal Details Card
                Text(
                  'Personal Information',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Material(
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: Colors.grey.shade100),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CONTACT PHONE', style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4.h),
                                Text(_personalPhone, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('GENDER', style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4.h),
                                Text(_personalGender, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DATE OF BIRTH', style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4.h),
                                Text('${_personalDob.day}/${_personalDob.month}/${_personalDob.year}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: primaryColor, size: 20),
                              onPressed: _editPersonalInfo,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],

              if (currentRole == UserRole.wholesale) ...[
                // B2B Wholesale sections
                Text(
                  'B2B Settings & Invoicing',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.bold),
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
                        leading: const Icon(Icons.notifications_outlined, color: primaryColor),
                        title: const Text('Notifications'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => Get.toNamed(Routes.WHOLESALE_NOTIFICATIONS_SCREEN),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.assessment_outlined, color: primaryColor),
                        title: const Text('Daily Reports'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => Get.toNamed(Routes.WHOLESALE_DAILY_REPORTS_SCREEN),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.support_agent, color: primaryColor),
                        title: const Text('Support Tickets'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => Get.toNamed(Routes.WHOLESALE_SUPPORT_TICKETS_SCREEN),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline, color: primaryColor),
                        title: const Text('Change Account Password'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: _changePassword,
                      ),
                      const Divider(height: 1),
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
                        title: const Text('Wholesale Pricing FAQ'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: _showB2bFAQ,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Saved Warehouse Addresses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registered Warehouses', style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _addAddress,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(foregroundColor: primaryColor),
                    ),
                  ],
                ),
                Material(
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: Colors.grey.shade100),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: _addresses.isEmpty
                        ? const Center(child: Text('No warehouse locations linked.'))
                        : Column(
                            children: _addresses.map((address) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.location_on, color: primaryColor),
                                title: Text(address, style: TextStyle(fontSize: 12.sp)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _addresses.remove(address);
                                    });
                                    Fluttertoast.showToast(msg: 'Warehouse location removed.');
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Corporate Billing Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Corporate Billing Cards', style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _addPaymentCard,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(foregroundColor: primaryColor),
                    ),
                  ],
                ),
                Material(
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: Colors.grey.shade100),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: _savedCards.isEmpty
                        ? const Center(child: Text('No linked B2B payment cards.'))
                        : Column(
                            children: _savedCards.map((card) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.credit_card, color: Colors.blue),
                                title: Text('${card['brand']} ending in ${card['last4']}'),
                                subtitle: Text('Expires ${card['expiry']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _savedCards.remove(card);
                                    });
                                    Fluttertoast.showToast(msg: 'Corporate card removed.');
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ] else if (currentRole == UserRole.customer) ...[
                Text(
                  'Account Settings',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.bold),
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
                        leading: const Icon(Icons.notifications_none, color: primaryColor),
                        title: const Text('Notifications'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => Get.to(() => const el_arbol_notif.CustomerNotificationsScreen()),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline, color: primaryColor),
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: _changePassword,
                      ),
                      const Divider(height: 1),
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
                    ],
                  ),
                ),
              ] else ...[
                // Shop Staff / Employee portal information
                Text('Staff Operational Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.bold)),
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
                        leading: const Icon(Icons.store, color: primaryColor),
                        title: const Text('Assigned Shop ID'),
                        trailing: Text(currentRole == UserRole.shopPortal ? 'SHOP-VALENCIA-04' : 'MEM-8902', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),

                      const Divider(height: 1),
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
                    ],
                  ),
                ),
              ],
              SizedBox(height: 32.h),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Log Out from Portal', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
