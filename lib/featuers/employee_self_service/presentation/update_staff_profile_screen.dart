import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/common_button.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../data/rx.dart';

class UpdateStaffProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String? initialPhoto;

  const UpdateStaffProfileScreen({
    super.key,
    required this.initialName,
    required this.initialPhone,
    this.initialPhoto,
  });

  @override
  State<UpdateStaffProfileScreen> createState() => _UpdateStaffProfileScreenState();
}

class _UpdateStaffProfileScreenState extends State<UpdateStaffProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  File? _selectedImage;
  late UpdateStaffProfileRx _updateRx;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _updateRx = UpdateStaffProfileRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _updateRx.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Updating profile...');
      final success = await _updateRx.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        photoPath: _selectedImage?.path,
      );
      EasyLoading.dismiss();

      if (success) {
        Get.back(result: true); // Return true so the dashboard can refresh
        AppToast.success("Profile updated successfully!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: const Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture Selector
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100.r,
                        height: 100.r,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : (widget.initialPhoto != null && widget.initialPhoto!.isNotEmpty)
                                ? Image.network(widget.initialPhoto!, fit: BoxFit.cover)
                                : Icon(Icons.person, size: 50.r, color: primaryColor.withOpacity(0.5)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 16.r),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // Name Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Full Name',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF151E13)),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _nameController,
                  hintText: 'e.g. Jane Doe',
                  borderRadius: 8.r,
                  fillColor: const Color(0xFFECF7E4),
                  borderColor: primaryColor.withOpacity(0.2),
                  focusBorderColor: primaryColor,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Phone Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Phone Number',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF151E13)),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _phoneController,
                  hintText: 'e.g. +0987654321',
                  keyboardType: TextInputType.phone,
                  borderRadius: 8.r,
                  fillColor: const Color(0xFFECF7E4),
                  borderColor: primaryColor.withOpacity(0.2),
                  focusBorderColor: primaryColor,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Phone number is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                SizedBox(height: 40.h),

                // Save Button
                CommonButton(
                  text: 'Save Changes',
                  backgroundColor: primaryColor,
                  borderRadius: 8.r,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
