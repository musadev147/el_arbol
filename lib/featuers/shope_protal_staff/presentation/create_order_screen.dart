import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'order_models.dart';
import 'order_state.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  int _currentPage = 1; // 1 for Fruits & Vegetables, 2 for Grocery
  String _orderType = 'Retail'; // 'Retail' or 'Wholesale'

  // F&V Order Quantities Map: category -> list of product inputs
  final Map<String, List<FVProductInput>> fvOrderData = {
    'Apples & Pears': [
      FVProductInput(name: 'Gala Apples'),
      FVProductInput(name: 'Golden Delicious'),
      FVProductInput(name: 'Conference Pears'),
    ],
    'Citrus': [
      FVProductInput(name: 'Navel Oranges'),
      FVProductInput(name: 'Lemons'),
      FVProductInput(name: 'Limes'),
      FVProductInput(name: 'Mandarins'),
    ],
    'Melons': [
      FVProductInput(name: 'Watermelon'),
      FVProductInput(name: 'Cantaloupe'),
    ],
    'Tropical': [
      FVProductInput(name: 'Bananas'),
      FVProductInput(name: 'Pineapples'),
      FVProductInput(name: 'Mangoes'),
    ],
    'Winter/Summer Fruits': [
      FVProductInput(name: 'Peaches'),
      FVProductInput(name: 'Plums'),
    ],
    'Forest Fruits': [
      FVProductInput(name: 'Strawberries'),
      FVProductInput(name: 'Blueberries'),
      FVProductInput(name: 'Raspberries'),
    ],
    'Garlic & Onions': [
      FVProductInput(name: 'Red Onions'),
      FVProductInput(name: 'White Garlic'),
    ],
    'Lettuce': [
      FVProductInput(name: 'Romaine Lettuce'),
      FVProductInput(name: 'Iceberg'),
    ],
    'Peppers': [
      FVProductInput(name: 'Red Bell Peppers'),
      FVProductInput(name: 'Green Peppers'),
    ],
    'Tomatoes': [
      FVProductInput(name: 'Cherry Tomatoes'),
      FVProductInput(name: 'Vine Tomatoes'),
    ],
    'Herbs': [
      FVProductInput(name: 'Basil'),
      FVProductInput(name: 'Cilantro'),
      FVProductInput(name: 'Parsley'),
    ],
    'Vegetables': [
      FVProductInput(name: 'Carrots'),
      FVProductInput(name: 'Zucchini'),
      FVProductInput(name: 'Eggplant'),
    ],
  };

  // Grocery Items List
  final List<GroceryProductInput> groceryOrderData = [
    GroceryProductInput(category: 'Nuts'),
    GroceryProductInput(category: 'Spices'),
    GroceryProductInput(category: 'Preserves'),
    GroceryProductInput(category: 'Frozen'),
    GroceryProductInput(category: 'Drinks'),
    GroceryProductInput(category: 'Legumes'),
    GroceryProductInput(category: 'Pasta'),
    GroceryProductInput(category: 'Teas'),
    GroceryProductInput(category: 'Others'),
  ];

  @override
  void initState() {
    super.initState();
    // Sort all products alphabetically inside their categories
    fvOrderData.forEach((category, products) {
      products.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _addGroceryItem() {
    setState(() {
      groceryOrderData.add(GroceryProductInput(category: 'Others'));
    });
  }

  void _submitOrder() {
    // Save to the active orders state
    final order = StaffOrder(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: DateTime.now(),
      type: _orderType,
      fvItems: fvOrderData.entries
          .expand((e) => e.value)
          .where((p) => p.classAQty > 0 || p.classBQty > 0)
          .toList(),
      groceryItems: groceryOrderData
          .where((p) => p.name.isNotEmpty && p.quantity > 0)
          .toList(),
      status: 'Pending Warehouse Approval',
    );

    OrderState.addOrder(order);
    Get.back();
    Get.snackbar(
      'Order Submitted',
      'Order ${order.id} was created successfully.',
      backgroundColor: const Color(0xFF00694C),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'Create Order',
          style: TextStyle(
            color: const Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w, top: 10.h, bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: _orderType,
              underline: const SizedBox(),
              items: ['Retail', 'Wholesale'].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _orderType = val;
                  });
                }
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Page Indicator Steps
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                children: [
                  _buildStepIndicator(1, 'Fruits & Vegetables', _currentPage == 1),
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: _currentPage == 2 ? primaryColor : Colors.grey.shade300,
                    ),
                  ),
                  _buildStepIndicator(2, 'Groceries', _currentPage == 2),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _currentPage == 1 ? _buildFVPage() : _buildGroceryPage(),
            ),

            // Bottom Navigation Actions
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage == 2)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentPage = 1),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Back to F&V',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage == 2) SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage == 1
                          ? () => setState(() => _currentPage = 2)
                          : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 1 ? 'Next: Groceries' : 'Submit Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNum, String title, bool isActive) {
    const Color primaryColor = Color(0xFF00694C);
    return Row(
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primaryColor : Colors.grey.shade300,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNum',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF151E13) : const Color(0xFF6D7A73),
          ),
        ),
      ],
    );
  }

  Widget _buildFVPage() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: fvOrderData.keys.map((category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Text(
                category,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00694C),
                ),
              ),
            ),
            ...fvOrderData[category]!.map((product) {
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF151E13),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        // Class A Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Class A',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 36.h,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                                          hintText: 'Qty',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          product.classAQty = double.tryParse(val) ?? 0.0;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Container(
                                    height: 36.h,
                                    width: 45.w,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: DropdownButton<String>(
                                      value: product.classAUnit,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      icon: const Icon(Icons.arrow_drop_down, size: 14),
                                      items: ['kg', 'box', 'pcs'].map((u) {
                                        return DropdownMenuItem(
                                          value: u,
                                          child: Text(u, style: TextStyle(fontSize: 10.sp)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            product.classAUnit = val;
                                          });
                                        }
                                      },
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Class B Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Class B',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 36.h,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                                          hintText: 'Qty',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          product.classBQty = double.tryParse(val) ?? 0.0;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Container(
                                    height: 36.h,
                                    width: 45.w,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: DropdownButton<String>(
                                      value: product.classBUnit,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      icon: const Icon(Icons.arrow_drop_down, size: 14),
                                      items: ['kg', 'box', 'pcs'].map((u) {
                                        return DropdownMenuItem(
                                          value: u,
                                          child: Text(u, style: TextStyle(fontSize: 10.sp)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            product.classBUnit = val;
                                          });
                                        }
                                      },
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGroceryPage() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: groceryOrderData.length,
            itemBuilder: (context, index) {
              final item = groceryOrderData[index];
              return Container(
                margin: EdgeInsets.only(top: 12.h),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: item.category,
                          underline: const SizedBox(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00694C),
                          ),
                          items: [
                            'Nuts',
                            'Spices',
                            'Preserves',
                            'Frozen',
                            'Drinks',
                            'Legumes',
                            'Pasta',
                            'Teas',
                            'Others'
                          ].map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                item.category = val;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              groceryOrderData.removeAt(index);
                            });
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 40.h,
                            child: TextField(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                                hintText: 'Product Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              onChanged: (val) {
                                item.name = val;
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: SizedBox(
                            height: 40.h,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                                hintText: 'Qty',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              onChanged: (val) {
                                item.quantity = double.tryParse(val) ?? 0.0;
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          height: 40.h,
                          width: 68.w,
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: item.unit,
                              icon: const Icon(Icons.arrow_drop_down, size: 16),
                              items: ['kg', 'box', 'pcs', 'pack'].map((u) {
                                return DropdownMenuItem(
                                  value: u,
                                  child: Text(u, style: TextStyle(fontSize: 11.sp)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    item.unit = val;
                                  });
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        hintText: 'Freehand details / special specifications',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      maxLines: 2,
                      onChanged: (val) {
                        item.details = val;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.r),
          child: TextButton.icon(
            onPressed: _addGroceryItem,
            icon: const Icon(Icons.add, color: Color(0xFF00694C)),
            label: const Text(
              'Add Custom Grocery Item',
              style: TextStyle(
                color: Color(0xFF00694C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
