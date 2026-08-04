import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../common_wigdets/common_button.dart';
import '../../../../common_wigdets/custom_textfiled.dart';
import '../data/wholesale_rx.dart';

class WholesaleAddProductScreen extends StatefulWidget {
  const WholesaleAddProductScreen({super.key});

  @override
  State<WholesaleAddProductScreen> createState() => _WholesaleAddProductScreenState();
}

class _WholesaleAddProductScreenState extends State<WholesaleAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _minimumPurchaseController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();
  final _shopIdController = TextEditingController();

  late final WholesaleCreateProductRx _createProductRx;

  @override
  void initState() {
    super.initState();
    _createProductRx = WholesaleCreateProductRx(
      empty: null,
      dataFetcher: BehaviorSubject<void>(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _wholesalePriceController.dispose();
    _minimumPurchaseController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _shopIdController.dispose();
    super.dispose();
  }

  void _submitProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      final payload = {
        "name": _nameController.text.trim(),
        "slug": _slugController.text.trim(),
        "description": _descriptionController.text.trim(),
        "price": double.tryParse(_priceController.text.trim()) ?? 0.0,
        "discount_price": double.tryParse(_discountPriceController.text.trim()) ?? 0.0,
        "wholesale_price": double.tryParse(_wholesalePriceController.text.trim()) ?? 0.0,
        "minimum_purchase": int.tryParse(_minimumPurchaseController.text.trim()) ?? 1,
        "stock": int.tryParse(_stockController.text.trim()) ?? 0,
        "is_active": true,
        "unit": _unitController.text.trim(),
        "shop": int.tryParse(_shopIdController.text.trim()) ?? 1, 
      };

      bool success = await _createProductRx.createProduct(payload);
      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'Add New Product',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF151E13)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormField(
                  controller: _nameController,
                  labelText: 'Product Name',
                  hintText: 'e.g. Samsung Galaxy S24',
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextFormField(
                  controller: _slugController,
                  labelText: 'Slug (URL friendly)',
                  hintText: 'e.g. samsung-galaxy-s24',
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextFormField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Enter product details...',
                  maxLine: 3,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _priceController,
                        labelText: 'Regular Price',
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextFormField(
                        controller: _discountPriceController,
                        labelText: 'Discount Price',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _wholesalePriceController,
                        labelText: 'Wholesale Price',
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextFormField(
                        controller: _minimumPurchaseController,
                        labelText: 'Min Purchase',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _stockController,
                        labelText: 'Stock',
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextFormField(
                        controller: _unitController,
                        labelText: 'Unit (e.g. Piece)',
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                CustomTextFormField(
                  controller: _shopIdController,
                  labelText: 'Shop ID',
                  hintText: 'e.g. 1',
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    text: 'Create Product',
                    onPressed: _submitProduct,
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
}





