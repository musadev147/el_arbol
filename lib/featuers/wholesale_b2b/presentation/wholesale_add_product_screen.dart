import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../common_wigdets/common_button.dart';
import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../customers/home/presentation/data/rx.dart';
import '../../customers/home/presentation/model/get_category_model.dart';
import '../../customers/orders/data/customer_orders_api.dart';
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
  final _originController = TextEditingController(text: 'Spain Sourced');
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _minimumPurchaseController = TextEditingController(text: '5');
  final _stockController = TextEditingController(text: '50');
  final _imageUrlController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  int _selectedShopId = 1;
  List<Map<String, dynamic>> _availableShops = [];
  bool _isLoadingShops = false;
  String _selectedUnit = 'kg';
  bool _isActive = true;
  bool _isAutoSlugEnabled = true;

  final List<String> _availableUnits = [
    'kg',
    'Piece',
    'Box',
    'Crate',
    'Pallet',
    'Bag',
    'Liter',
    'Ton',
    'Pack'
  ];

  late final WholesaleCreateProductRx _createProductRx;
  late final GetCategoryRx _categoryRx;

  @override
  void initState() {
    super.initState();
    _createProductRx = WholesaleCreateProductRx(
      empty: null,
      dataFetcher: BehaviorSubject<void>(),
    );

    _categoryRx = GetCategoryRx(
      empty: GetCategoryModel(),
      dataFetcher: BehaviorSubject<GetCategoryModel>(),
    );
    _categoryRx.fetchCategories();
    _fetchStores();

    _nameController.addListener(_onNameChanged);
  }

  Future<void> _fetchStores() async {
    setState(() => _isLoadingShops = true);
    try {
      final stores = await CustomerOrdersApi.instance.getStores();
      if (mounted) {
        if (stores is List && stores.isNotEmpty) {
          setState(() {
            _availableShops = stores.map((s) => Map<String, dynamic>.from(s as Map)).toList();
            if (_availableShops.isNotEmpty) {
              _selectedShopId = _availableShops.first['id'] as int? ?? 1;
            }
          });
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingShops = false);
    }
  }

  void _onNameChanged() {
    if (_isAutoSlugEnabled) {
      final name = _nameController.text.trim();
      final slug = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      _slugController.text = slug;
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _slugController.dispose();
    _originController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _wholesalePriceController.dispose();
    _minimumPurchaseController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _createProductRx.dispose();
    _categoryRx.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (_) {}
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Product Image',
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
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF00694C)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null) {
        AppToast.error("Please select a Category");
        return;
      }
      if (_selectedSubCategoryId == null) {
        AppToast.error("Please select a Sub Category");
        return;
      }

      final regularPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final wholesalePrice = double.tryParse(_wholesalePriceController.text.trim()) ?? 0.0;
      final discountPrice = double.tryParse(_discountPriceController.text.trim()) ?? 0.0;
      final minPurchase = int.tryParse(_minimumPurchaseController.text.trim()) ?? 1;
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final shopId = _selectedShopId > 0 ? _selectedShopId : 1;
      String slug = _slugController.text.trim();
      if (slug.isEmpty) {
        slug = _nameController.text.trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-+|-+$'), '');
      }

      final Map<String, dynamic> body = {
        "name": _nameController.text.trim(),
        "slug": slug,
        "description": _descriptionController.text.trim(),
        "origin": _originController.text.trim(),
        "price": regularPrice,
        "discount_price": discountPrice > 0 ? discountPrice : regularPrice,
        "wholesale_price": wholesalePrice,
        "wholesale_unit": _selectedUnit,
        "unit": _selectedUnit,
        "minimum_purchase": minPurchase,
        "stock": stock,
        "is_active": _isActive,
        "shop": shopId,
      };

      if (_selectedCategoryId != null) {
        body["category"] = _selectedCategoryId;
      }
      if (_selectedSubCategoryId != null) {
        body["sub_category"] = _selectedSubCategoryId;
      }

      dynamic payload;
      if (_selectedImage != null) {
        final fileName = _selectedImage!.path.split('/').last;
        final formDataMap = Map<String, dynamic>.from(body);
        formDataMap["image"] = await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: fileName,
        );
        payload = FormData.fromMap(formDataMap);
      } else {
        if (_imageUrlController.text.trim().isNotEmpty) {
          body["thumbnail_url"] = _imageUrlController.text.trim();
        }
        payload = body;
      }

      bool success = await _createProductRx.createProduct(payload);
      if (success) {
        Get.back(result: true);
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF00694C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: const Color(0xFF00694C), size: 18.r),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF151E13),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'Add Wholesale Product',
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Basic Product Info
                _buildSectionCard(
                  title: 'Basic Product Information',
                  icon: Icons.inventory_2_outlined,
                  children: [
                    CustomTextFormField(
                      controller: _nameController,
                      labelText: 'Product Name *',
                      hintText: 'e.g. Valencia Organic Oranges',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Product name is required' : null,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _slugController,
                            labelText: 'URL Slug *',
                            hintText: 'e.g. valencia-organic-oranges',
                            onChanged: (_) {
                              setState(() {
                                _isAutoSlugEnabled = false;
                              });
                            },
                            validator: (v) => v == null || v.trim().isEmpty ? 'Slug is required' : null,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        IconButton(
                          tooltip: 'Add unique suffix',
                          icon: const Icon(Icons.tag, color: primaryColor),
                          onPressed: () {
                            final base = _slugController.text.trim().replaceAll(RegExp(r'-\d+$'), '');
                            final suffix = (DateTime.now().millisecondsSinceEpoch % 10000).toString();
                            _slugController.text = base.isNotEmpty ? '$base-$suffix' : 'item-$suffix';
                            setState(() => _isAutoSlugEnabled = false);
                          },
                        ),
                        if (!_isAutoSlugEnabled) ...[
                          IconButton(
                            tooltip: 'Reset auto slug',
                            icon: const Icon(Icons.autorenew, color: primaryColor),
                            onPressed: () {
                              setState(() {
                                _isAutoSlugEnabled = true;
                              });
                              _onNameChanged();
                            },
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Category & Subcategory Dropdowns from API
                    Text(
                      'Category *',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6.h),
                    StreamBuilder<dynamic>(
                      stream: _categoryRx.valueStreamData,
                      builder: (context, snapshot) {
                        final GetCategoryModel? model = snapshot.data;
                        final categories = model?.results ?? [];

                        final selectedCat = categories.firstWhereOrNull((c) => c.id == _selectedCategoryId);
                        final subcategories = selectedCat?.subcategories ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10.r),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  hint: Text(
                                    categories.isEmpty ? 'Loading categories...' : 'Select Category',
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                                  ),
                                  value: _selectedCategoryId,
                                  items: categories.map((cat) {
                                    return DropdownMenuItem<int>(
                                      value: cat.id,
                                      child: Text(cat.name ?? '', style: TextStyle(fontSize: 13.sp)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCategoryId = val;
                                      final newCat = categories.firstWhereOrNull((c) => c.id == val);
                                      if (newCat != null && (newCat.subcategories?.isNotEmpty ?? false)) {
                                        _selectedSubCategoryId = newCat.subcategories!.first.id;
                                      } else {
                                        _selectedSubCategoryId = null;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            if (subcategories.isNotEmpty) ...[
                              SizedBox(height: 12.h),
                              Text(
                                'Sub Category',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Select Sub Category',
                                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                                    ),
                                    value: _selectedSubCategoryId,
                                    items: subcategories.map((sub) {
                                      return DropdownMenuItem<int>(
                                        value: sub.id,
                                        child: Text(sub.name ?? '', style: TextStyle(fontSize: 13.sp)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedSubCategoryId = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 12.h),
                    CustomTextFormField(
                      controller: _originController,
                      labelText: 'Sourcing & Origin',
                      hintText: 'e.g. Valencia Organic Farm, Spain',
                    ),
                    SizedBox(height: 12.h),
                    CustomTextFormField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      hintText: 'Enter wholesale specifications, quality grades, packing...',
                      maxLine: 3,
                    ),
                  ],
                ),

                // 2. B2B Wholesale Pricing
                _buildSectionCard(
                  title: 'B2B Wholesale & Pricing',
                  icon: Icons.monetization_on_outlined,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: primaryColor, size: 20),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Wholesale pricing will be shown to verified B2B buyers when ordering the minimum purchase quantity.',
                              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF1B5E20), height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CustomTextFormField(
                            controller: _wholesalePriceController,
                            labelText: 'Wholesale Price (€) *',
                            hintText: 'e.g. 1.80',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unit *',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedUnit,
                                    items: _availableUnits.map((u) {
                                      return DropdownMenuItem<String>(
                                        value: u,
                                        child: Text(u, style: TextStyle(fontSize: 13.sp)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedUnit = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _minimumPurchaseController,
                            labelText: 'Min Purchase (Qty) *',
                            hintText: 'e.g. 5',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomTextFormField(
                            controller: _priceController,
                            labelText: 'Regular Price (€) *',
                            hintText: 'e.g. 2.50',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _discountPriceController,
                            labelText: 'Discount Price (€)',
                            hintText: 'e.g. 2.20',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomTextFormField(
                            controller: _stockController,
                            labelText: 'Available Stock *',
                            hintText: 'e.g. 100',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 3. Warehouse & Inventory
                _buildSectionCard(
                  title: 'Warehouse & Status',
                  icon: Icons.storefront_outlined,
                  children: [
                    Text(
                      'Shop / Fulfillment Warehouse *',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10.r),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          hint: Text(
                            _isLoadingShops ? 'Loading shops...' : 'Select Shop',
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                          ),
                          value: _availableShops.any((s) => s['id'] == _selectedShopId)
                              ? _selectedShopId
                              : (_availableShops.isNotEmpty ? (_availableShops.first['id'] as int? ?? 1) : 1),
                          items: _availableShops.isNotEmpty
                              ? _availableShops.map((shop) {
                                  final id = shop['id'] as int? ?? 1;
                                  final name = shop['name']?.toString() ?? 'Shop #$id';
                                  final city = shop['city']?.toString() ?? '';
                                  final label = city.isNotEmpty ? '$name ($city)' : name;
                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text(label, style: TextStyle(fontSize: 13.sp)),
                                  );
                                }).toList()
                              : [
                                  const DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text('United Group (ID: 1)', style: TextStyle(fontSize: 13)),
                                  ),
                                  const DropdownMenuItem<int>(
                                    value: 2,
                                    child: Text('Shopno (ID: 2)', style: TextStyle(fontSize: 13)),
                                  ),
                                ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedShopId = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Active in Wholesale Catalog',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Enable to immediately list this item in the B2B catalog.',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                        value: _isActive,
                        activeColor: primaryColor,
                        onChanged: (val) {
                          setState(() {
                            _isActive = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // 4. Product Media
                _buildSectionCard(
                  title: 'Product Image & Media',
                  icon: Icons.photo_camera_outlined,
                  children: [
                    if (_selectedImage != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              _selectedImage!,
                              height: 180.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8.r,
                            right: 8.r,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              radius: 16.r,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                    ] else ...[
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: DottedBorder(
                          color: primaryColor.withValues(alpha: 0.5),
                          strokeWidth: 1.5,
                          dashPattern: const [6, 4],
                          borderType: BorderType.RRect,
                          radius: Radius.circular(12.r),
                          child: Container(
                            height: 120.h,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 36.r, color: primaryColor),
                                SizedBox(height: 8.h),
                                Text(
                                  'Tap to upload product photo',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'PNG, JPG up to 10MB',
                                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    CustomTextFormField(
                      controller: _imageUrlController,
                      labelText: 'Or enter Image URL (optional)',
                      hintText: 'https://example.com/product.jpg',
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    text: 'Publish Wholesale Product',
                    onPressed: _submitProduct,
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
