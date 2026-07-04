import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WholesaleRegistrationScreen extends StatefulWidget {
  const WholesaleRegistrationScreen({super.key});

  @override
  State<WholesaleRegistrationScreen> createState() => _WholesaleRegistrationScreenState();
}

class _WholesaleRegistrationScreenState extends State<WholesaleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _businessType = 'Restaurant';

  @override
  void dispose() {
    _businessNameController.dispose();
    _taxIdController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00694C)),
              SizedBox(width: 8.w),
              const Text('Application Submitted'),
            ],
          ),
          content: const Text(
            'Your Wholesale ID access request has been sent. Management will review your business credentials and CIF/Tax ID within 24-48 hours. You will receive an email notification once approved.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Get.back(); // Go back to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00694C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: const Text('Return to Login', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'Wholesale Registration',
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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply for Wholesale Access',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Submit your company tax ID and details to unlock wholesale bulk catalog pricing.',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6D7A73), height: 1.3),
                ),
                SizedBox(height: 24.h),

                // Form Fields
                _buildFieldLabel('Registered Business Name'),
                TextFormField(
                  controller: _businessNameController,
                  decoration: _buildInputDecoration('e.g. Valencia Food Group S.L.'),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter business name' : null,
                ),
                SizedBox(height: 14.h),

                _buildFieldLabel('Tax ID / CIF / NIF'),
                TextFormField(
                  controller: _taxIdController,
                  decoration: _buildInputDecoration('e.g. B-12345678'),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter Tax ID / CIF' : null,
                ),
                SizedBox(height: 14.h),

                _buildFieldLabel('Business Type'),
                DropdownButtonFormField<String>(
                  value: _businessType,
                  decoration: _buildInputDecoration('Select business type'),
                  items: ['Restaurant', 'Bar', 'Catering', 'Hotel / Lodging', 'Local Grocery Retailer', 'Other'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _businessType = val;
                      });
                    }
                  },
                ),
                SizedBox(height: 14.h),

                _buildFieldLabel('Contact Person Name'),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: _buildInputDecoration('e.g. Mario Silva'),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter contact person name' : null,
                ),
                SizedBox(height: 14.h),

                _buildFieldLabel('Business Contact Email'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('e.g. purchasing@valenciafood.com'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter email';
                    if (!GetUtils.isEmail(val)) return 'Please enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 14.h),

                _buildFieldLabel('Contact Phone Number'),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration('e.g. +34 961 234 567'),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter phone number' : null,
                ),
                SizedBox(height: 28.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Wholesale ID Request',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF151E13),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
      fillColor: Colors.white,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFF00694C)),
      ),
    );
  }
}
