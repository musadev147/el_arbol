import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:el_arbol/common_wigdets/user_role.dart';
import 'package:el_arbol/route/app_pages.dart';

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
                  onPressed: () {
                    setState(() {
                      _businessName = nameController.text;
                      _contactPerson = contactController.text;
                      _contactPhone = phoneController.text;
                    });
                    Fluttertoast.showToast(msg: 'Business details updated!');
                    Navigator.pop(context);
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
              onPressed: () {
                if (newPasswordController.text != confirmController.text) {
                  Fluttertoast.showToast(msg: 'New passwords do not match.');
                  return;
                }
                Fluttertoast.showToast(msg: 'Password updated successfully!');
                Navigator.pop(context);
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

  void _changeProfileImage() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        final avatars = [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop',
        ];
        return Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Profile Photo',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: avatars.map((url) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _profileImageUrl = url;
                    });
                    Fluttertoast.showToast(msg: 'Profile photo updated!');
                    Navigator.pop(ctx);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                )).toList(),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _profileImageUrl = null;
                    });
                    Fluttertoast.showToast(msg: 'Reset to default avatar.');
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.refresh, color: Colors.grey),
                  label: const Text('Reset Default', style: TextStyle(color: Colors.grey)),
                ),
              )
            ],
          ),
        );
      },
    );
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
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              _personalPhone = phoneController.text;
                              _personalGender = selectedGender;
                              _personalDob = selectedDob;
                            });
                            Fluttertoast.showToast(msg: 'Personal details updated!');
                            Navigator.pop(ctx);
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
                      if (currentRole == UserRole.wholesale)
                        IconButton(
                          icon: const Icon(Icons.edit, color: primaryColor),
                          onPressed: _editB2bDetails,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

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
