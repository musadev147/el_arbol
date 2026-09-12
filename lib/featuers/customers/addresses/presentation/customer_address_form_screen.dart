import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/customer_addresses_rx.dart';

class CustomerAddressFormScreen extends StatefulWidget {
  final CustomerAddressesRx rx;
  final Map<String, dynamic>? address;

  const CustomerAddressFormScreen({
    super.key,
    required this.rx,
    this.address,
  });

  @override
  State<CustomerAddressFormScreen> createState() => _CustomerAddressFormScreenState();
}

class _CustomerAddressFormScreenState extends State<CustomerAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _titleController.text = widget.address!['title'] ?? '';
      _addressController.text = widget.address!['street'] ?? widget.address!['address'] ?? '';
      _cityController.text = widget.address!['city'] ?? '';
      _zipController.text = widget.address!['postcode'] ?? widget.address!['zip_code'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "title": _titleController.text,
        "street": _addressController.text,
        "city": _cityController.text,
        "postcode": _zipController.text,
      };

      bool success = false;
      if (widget.address == null) {
        success = await widget.rx.createAddress(data);
      } else {
        final id = widget.address!['id'].toString();
        success = await widget.rx.updateAddress(id, data);
      }

      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    final isEdit = widget.address != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Address' : 'New Address', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 16.h),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. Home, Office)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16.h),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _zipController,
                      decoration: const InputDecoration(
                        labelText: 'Zip / Postal Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: _submit,
                  child: const Text('Save Address', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
