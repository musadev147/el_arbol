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
import 'package:el_arbol/featuers/employee_self_service/data/rx.dart';
import 'package:el_arbol/featuers/employee_self_service/model/staff_dashboard_model.dart';
import 'dart:io';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:el_arbol/featuers/customers/tickets/presentation/customer_tickets_screen.dart' as el_arbol;
import 'package:el_arbol/featuers/customers/addresses/presentation/customer_addresses_screen.dart' as el_arbol_addr;
import 'package:el_arbol/featuers/customers/orders/presentation/customer_orders_screen.dart' as el_arbol_order;
import 'package:el_arbol/featuers/wholesale_b2b/presentation/wholesale_orders_screen.dart';
import 'package:el_arbol/featuers/employee_self_service/presentation/staff_order_history_screen.dart';
import 'package:el_arbol/featuers/customers/wishlist/presentation/customer_wishlist_screen.dart' as el_arbol_wish;
import 'package:el_arbol/featuers/customers/notifications/presentation/customer_notifications_screen.dart' as el_arbol_notif;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import 'package:el_arbol/featuers/employee_self_service/presentation/staff_chat_screen.dart';
import '../../wholesale_b2b/data/wholesale_api.dart';
import 'data/rx.dart';

import 'package:el_arbol/featuers/customers/notifications/data/customer_notifications_rx.dart';

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
  File? _localProfileImage;

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
  String _employeeName = 'Sofia Rossi';
  String _employeeEmail = 'sofia.rossi@elarbol.com';
  String _memberId = 'MEM-8902';

  // Wholesale B2B specific
  late WholesaleProfileRx _wholesaleProfileRx;

  // Customer specific
  late CustomerProfileRx _customerProfileRx;
  final CustomerChangePasswordRx _changePasswordRx = CustomerChangePasswordRx(empty: null, dataFetcher: BehaviorSubject<void>());
  final CustomerNotificationsRx _notificationsRx = CustomerNotificationsRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());

  // Staff specific
  late UpdateStaffProfileRx _staffProfileRx;

  @override
  void initState() {
    super.initState();
    _notificationsRx.fetchNotifications();
    if (widget.role == UserRole.wholesale) {
      _wholesaleProfileRx = WholesaleProfileRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
      _wholesaleProfileRx.fetchProfile();
      
      _wholesaleProfileRx.valueStreamData.listen((data) {
        if (data != null && mounted) {
          final profileData = (data['data'] is Map) 
              ? data['data'] 
              : (data['user'] is Map ? data['user'] : data);

          setState(() {
            _businessName = profileData['business_name'] ?? profileData['company_name'] ?? _businessName;
            _cif = profileData['trade_license_number'] ?? profileData['tax_id'] ?? profileData['cif'] ?? _cif;
            _contactPerson = profileData['contact_name'] ?? profileData['contact_person'] ?? _contactPerson;
            _businessEmail = profileData['email'] ?? _businessEmail;
            _contactPhone = profileData['phone'] ?? profileData['contact_phone'] ?? _contactPhone;
            _personalPhone = profileData['phone'] ?? _personalPhone;

            final rawImage = profileData['profile_image_url'] ?? 
                             profileData['profile_image'] ?? 
                             profileData['image'] ?? 
                             profileData['avatar'] ?? 
                             profileData['photo'];

            if (rawImage != null && rawImage.toString().trim().isNotEmpty) {
              String avatar = rawImage.toString().trim();
              if (!avatar.startsWith('http://') && !avatar.startsWith('https://')) {
                const base = 'https://apielarbol.icommerce.com.bd';
                if (avatar.startsWith('/')) {
                  avatar = '$base$avatar';
                } else {
                  avatar = '$base/$avatar';
                }
              }
              _profileImageUrl = avatar;
            }
          });
        }
      });
    } else if (widget.role == UserRole.customer) {
      _customerProfileRx = CustomerProfileRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
      _customerProfileRx.fetchProfile();

      _customerProfileRx.valueStreamData.listen((data) {
        if (data != null && mounted) {
          final profileData = (data['data'] is Map) 
              ? data['data'] 
              : (data['user'] is Map ? data['user'] : data);

          setState(() {
            _personalPhone = profileData['phone'] ?? _personalPhone;
            _personalGender = profileData['gender'] ?? _personalGender;
            if (profileData['dob'] != null) {
              try {
                _personalDob = DateTime.parse(profileData['dob'].toString());
              } catch (_) {}
            }
            final rawImage = profileData['resolvedAvatar'] ?? 
                             profileData['avatar'] ?? 
                             profileData['image'] ?? 
                             profileData['profile_image'] ?? 
                             profileData['profile_image_url'] ?? 
                             profileData['photo'];

            if (rawImage != null && rawImage.toString().trim().isNotEmpty) {
              String avatar = rawImage.toString().trim();
              if (!avatar.startsWith('http://') && !avatar.startsWith('https://')) {
                const base = 'https://apielarbol.icommerce.com.bd';
                if (avatar.startsWith('/')) {
                  avatar = '$base$avatar';
                } else {
                  avatar = '$base/$avatar';
                }
              }
              _profileImageUrl = avatar;
            }
          });
        }
      });
    } else {
      _staffProfileRx = UpdateStaffProfileRx(empty: null, dataFetcher: BehaviorSubject<dynamic>());
      _staffProfileRx.fetchStaffProfile();

      _staffProfileRx.valueStreamData.listen((data) {
        if (data != null && mounted) {
          setState(() {
            _employeeName = data['name'] ?? _employeeName;
            _employeeEmail = data['email'] ?? _employeeEmail;
            _personalPhone = data['phone'] ?? _personalPhone;
            _memberId = data['staff_id'] ?? _memberId;
            if (data['photo'] != null) {
              String avatar = data['photo'];
              if (!avatar.startsWith('http://') && !avatar.startsWith('https://')) {
                const base = 'https://apielarbol.icommerce.com.bd';
                if (avatar.startsWith('/')) {
                  avatar = '$base$avatar';
                } else {
                  avatar = '$base/$avatar';
                }
              }
              _profileImageUrl = avatar;
            } else {
              _profileImageUrl = null;
            }
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
    } else {
      _staffProfileRx.dispose();
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

              Row(
                children: [
                  const Text('Registered Business Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 6.w),
                  Icon(Icons.lock_outline, size: 14.r, color: Colors.grey.shade600),
                ],
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: nameController,
                enabled: false,
                readOnly: true,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  suffixIcon: Icon(Icons.lock, size: 18.r, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  helperText: 'Business Name is locked for compliance purposes.',
                  helperStyle: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
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
                        "business_name": nameController.text.trim(),
                        "contact_name": contactController.text.trim(),
                        "contact_person": contactController.text.trim(),
                        "phone": phoneController.text.trim(),
                        "contact_phone": phoneController.text.trim(),
                      });
                      if (success) {
                        Fluttertoast.showToast(msg: 'Business details updated successfully!');
                        Navigator.pop(context);
                      }
                    } else {
                      setState(() {
                        _businessName = nameController.text.trim();
                        _contactPerson = contactController.text.trim();
                        _contactPhone = phoneController.text.trim();
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
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Profile Photo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF00694C)),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (image != null) {
                    setState(() {
                      _localProfileImage = File(image.path);
                    });
                    if (widget.role == UserRole.customer) {
                      await _customerProfileRx.updateAvatar(File(image.path));
                    } else if (widget.role == UserRole.wholesale) {
                      await _wholesaleProfileRx.updateAvatar(File(image.path));
                    } else if (widget.role == UserRole.staff || widget.role == UserRole.employeeSelfService) {
                      EasyLoading.show(status: 'Updating photo...');
                      final success = await _staffProfileRx.updateProfile(
                        name: _employeeName.isNotEmpty ? _employeeName : 'Staff',
                        phone: _personalPhone,
                        photoPath: image.path,
                      );
                      EasyLoading.dismiss();
                      if (success) {
                        AppToast.success('Profile photo updated successfully!');
                        _staffProfileRx.fetchStaffProfile();
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF00694C)),
                title: const Text('Take Photo (Camera)'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                  if (image != null) {
                    setState(() {
                      _localProfileImage = File(image.path);
                    });
                    if (widget.role == UserRole.customer) {
                      await _customerProfileRx.updateAvatar(File(image.path));
                    } else if (widget.role == UserRole.wholesale) {
                      await _wholesaleProfileRx.updateAvatar(File(image.path));
                    } else if (widget.role == UserRole.staff || widget.role == UserRole.employeeSelfService) {
                      EasyLoading.show(status: 'Updating photo...');
                      final success = await _staffProfileRx.updateProfile(
                        name: _employeeName.isNotEmpty ? _employeeName : 'Staff',
                        phone: _personalPhone,
                        photoPath: image.path,
                      );
                      EasyLoading.dismiss();
                      if (success) {
                        AppToast.success('Profile photo updated successfully!');
                        _staffProfileRx.fetchStaffProfile();
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editPersonalInfo() {
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController(text: _personalPhone);
    String selectedGender = _personalGender;

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
                              });
                              if (success) {
                                Navigator.pop(ctx);
                              }
                            } else {
                              setState(() {
                                _personalPhone = phoneController.text;
                                _personalGender = selectedGender;
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
          if (currentRole != UserRole.wholesale)
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
                          if (currentRole == UserRole.wholesale || currentRole == UserRole.customer) {
                            _changeProfileImage();
                          } else {
                            Get.to(() => UpdateStaffProfileScreen(
                              initialName: _employeeName,
                              initialPhone: _personalPhone,
                              initialPhoto: _profileImageUrl,
                            ))?.then((val) {
                              if (val == true) {
                                _staffProfileRx.fetchStaffProfile();
                              }
                            });
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 72.r,
                              height: 72.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor.withOpacity(0.1),
                              ),
                              child: ClipOval(
                                child: _localProfileImage != null
                                    ? Image.file(_localProfileImage!, fit: BoxFit.cover, width: 72.r, height: 72.r)
                                    : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: _profileImageUrl!,
                                            fit: BoxFit.cover,
                                            width: 72.r,
                                            height: 72.r,
                                            memCacheWidth: 200,
                                            memCacheHeight: 200,
                                            fadeInDuration: const Duration(milliseconds: 100),
                                            fadeOutDuration: const Duration(milliseconds: 100),
                                            placeholder: (context, url) => const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Icon(
                                              currentRole == UserRole.wholesale
                                                  ? Icons.business_center
                                                  : (currentRole == UserRole.customer ? Icons.person : Icons.badge),
                                              color: primaryColor,
                                              size: 36.r,
                                            ),
                                          )
                                        : Icon(
                                            currentRole == UserRole.wholesale
                                                ? Icons.business_center
                                                : (currentRole == UserRole.customer ? Icons.person : Icons.badge),
                                            color: primaryColor,
                                            size: 36.r,
                                          ),
                              ),
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
                              ))?.then((val) {
                                if (val == true) {
                                  _staffProfileRx.fetchStaffProfile();
                                }
                              });
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              if (currentRole == UserRole.customer) ...[
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('GENDER', style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4.h),
                                Text(_personalGender, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
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
                        leading: const Icon(Icons.lock_outline, color: primaryColor),
                        title: const Text('Change Account Password'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: _changePassword,
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
                        onTap: () {
                          final currentRole = widget.role;
                          if (currentRole == UserRole.wholesale) {
                            Get.to(() => const WholesaleOrdersScreen());
                          } else if (currentRole == UserRole.staff || currentRole == UserRole.employeeSelfService) {
                            Get.to(() => const StaffOrderHistoryScreen());
                          } else {
                            Get.to(() => const el_arbol_order.CustomerOrdersScreen());
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.support_agent, color: primaryColor),
                        title: Text(
                          (widget.role == UserRole.staff || widget.role == UserRole.employeeSelfService)
                              ? 'Support Chat'
                              : 'Support Tickets',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          final currentRole = widget.role;
                          if (currentRole == UserRole.staff || currentRole == UserRole.employeeSelfService) {
                            Get.to(() => const StaffChatScreen());
                          } else if (currentRole == UserRole.wholesale) {
                            Get.toNamed(Routes.WHOLESALE_SUPPORT_TICKETS_SCREEN);
                          } else {
                            Get.to(() => const el_arbol.CustomerSupportTicketsScreen());
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_none, color: primaryColor),
                        title: const Text('Notifications'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StreamBuilder<List<dynamic>>(
                              stream: _notificationsRx.valueStreamData,
                              builder: (context, snapshot) {
                                final notifs = snapshot.data ?? [];
                                if (notifs.isEmpty) return const SizedBox.shrink();
                                return Container(
                                  margin: EdgeInsets.only(right: 8.w),
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '${notifs.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                        onTap: () async {
                          await Get.to(() => const el_arbol_notif.CustomerNotificationsScreen());
                          _notificationsRx.fetchNotifications();
                        },
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
                        leading: const Icon(Icons.badge_outlined, color: primaryColor),
                        title: const Text('Member ID'),
                        trailing: Text(_memberId, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                child: currentRole == UserRole.wholesale
                    ? OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: const Text('Log Out from Portal', style: TextStyle(color: Colors.red)),
                      )
                    : OutlinedButton.icon(
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
