import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/common_button.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../provider/singnup_provider.dart';
import '../../../../route/app_pages.dart';
import 'package:rxdart/rxdart.dart';
import 'data/rx.dart';
import 'model/post_register_model.dart';

class RegisterScreen extends StatefulWidget {
  final String? role;
  const RegisterScreen({super.key, this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _postcodeController = TextEditingController();
  String _selectedBusinessType = 'restaurant';
  String _selectedMonthlyVolume = '1000_3000';

  final List<Map<String, String>> _businessTypeOptions = const [
    {'value': 'restaurant', 'label': 'Restaurant'},
    {'value': 'food_retail', 'label': 'Food Retail / Grocery'},
    {'value': 'hotel', 'label': 'Hotel / Lodging'},
    {'value': 'catering', 'label': 'Catering'},
    {'value': 'other', 'label': 'Other Business'},
  ];

  final List<Map<String, String>> _monthlyVolumeOptions = const [
    {'value': 'under_1000', 'label': 'Under €1,000 / month'},
    {'value': '1000_3000', 'label': '€1,000 - €3,000 / month'},
    {'value': '3000_7000', 'label': '€3,000 - €7,000 / month'},
    {'value': '7000_10000', 'label': '€7,000 - €10,000 / month'},
    {'value': '10000_plus', 'label': 'Over €10,000 / month'},
  ];

  late final PostRegisterRx _postRegisterRx;

  @override
  void initState() {
    super.initState();
    _postRegisterRx = PostRegisterRx(
      empty: PostRegisterModel(),
      dataFetcher: BehaviorSubject<PostRegisterModel>(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _contactNameController.dispose();
    _tradeLicenseController.dispose();
    _postcodeController.dispose();
    _postRegisterRx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrandColor = Color(0xFF00694C);

    final isWholesale = widget.role == 'wholesale' || widget.role == 'wholesales';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isWholesale ? 'Create a wholesale B2B account.' : 'Create an account.',
                  style: TextFontStyle.textStyle12Poppins400494953.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF6D7A73),
                  ),
                ),
                SizedBox(height: 24.h),

                if (isWholesale) ...[
                  // Business Name
                  Text(
                    'Business Name',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  CustomTextFormField(
                    controller: _businessNameController,
                    hintText: 'e.g. Valencia Food Group S.L.',
                    borderRadius: 8.r,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter business name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Contact Name
                  Text(
                    'Contact Name',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  CustomTextFormField(
                    controller: _contactNameController,
                    hintText: 'e.g. Mario Silva',
                    borderRadius: 8.r,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter contact name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Trade License
                  Text('Trade License Number', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF151E13))),
                  SizedBox(height: 6.h),
                  CustomTextFormField(
                    controller: _tradeLicenseController,
                    hintText: 'e.g. TL-12345/2023',
                    borderRadius: 8.r,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter trade license number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Postcode
                  Text('Postcode', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF151E13))),
                  SizedBox(height: 6.h),
                  CustomTextFormField(
                    controller: _postcodeController,
                    hintText: 'e.g. 1212',
                    borderRadius: 8.r,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter postcode';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Business Type Dropdown
                  Text('Business Type', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF151E13))),
                  SizedBox(height: 6.h),
                  DropdownButtonFormField<String>(
                    value: _selectedBusinessType,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: Color(0xFF00694C)),
                      ),
                    ),
                    items: _businessTypeOptions.map((opt) {
                      return DropdownMenuItem(
                        value: opt['value'],
                        child: Text(opt['label']!, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF151E13))),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedBusinessType = val);
                      }
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Monthly Volume Dropdown
                  Text(
                    'Monthly Volume',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  DropdownButtonFormField<String>(
                    value: _selectedMonthlyVolume,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: Color(0xFF00694C)),
                      ),
                    ),
                    items: _monthlyVolumeOptions.map((opt) {
                      return DropdownMenuItem(
                        value: opt['value'],
                        child: Text(
                          opt['label']!,
                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF151E13)),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedMonthlyVolume = val);
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                ],

                // Full Name (Only for non-wholesale)
                if (!isWholesale) ...[
                  Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF151E13),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  CustomTextFormField(
                    controller: _nameController,
                    hintText: 'Jane Doe',
                    borderRadius: 8.r,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                ],

                // Email Address
                Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _emailController,
                  hintText: 'jane@example.com',
                  keyboardType: TextInputType.emailAddress,
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Phone Number
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _phoneController,
                  hintText: '+34 600 000 000',
                  keyboardType: TextInputType.phone,
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password Field
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  isPassword: true,
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Confirm Password Field
                Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  hintText: '••••••••',
                  isPassword: true,
                  borderRadius: 8.r,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Sign Up Button
                CommonButton(
                  text: 'Sign Up',
                  backgroundColor: primaryBrandColor,
                  borderRadius: 8.r,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final provider = Provider.of<SignupProvider>(context, listen: false);
                      provider.setFullName(_nameController.text);
                      provider.setEmail(_emailController.text);
                      provider.setPhone(_phoneController.text);
                      provider.setPassword(_passwordController.text);
                      provider.setPasswordConfirm(_confirmPasswordController.text);
                      
                      _postRegisterRx.registerFunc(
                        name: isWholesale ? _contactNameController.text : _nameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text,
                        password: _passwordController.text,
                        passwordConfirm: _confirmPasswordController.text,
                        role: widget.role ?? 'customer',
                        businessName: isWholesale ? _businessNameController.text : null,
                        contactName: isWholesale ? _contactNameController.text : null,
                        tradeLicenseNumber: isWholesale ? _tradeLicenseController.text : null,
                        postcode: isWholesale ? _postcodeController.text : null,
                        businessType: isWholesale ? _selectedBusinessType : null,
                        monthlyVolume: isWholesale ? _selectedMonthlyVolume : null,
                      );
                    }
                  },
                ),
                SizedBox(height: 24.h),

                // Log In Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.offNamed(Routes.LOGIN, arguments: widget.role);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: const Color(0xFF6D7A73),
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              color: primaryBrandColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
