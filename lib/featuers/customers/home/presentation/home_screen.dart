import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'product_details_screen.dart';
import 'data/rx.dart';
import 'model/get_product_model.dart';
import 'model/get_category_model.dart';
import '../../wishlist/presentation/data/rx.dart';
import 'model/post_wishlist_model.dart' show PostCreateWishlistModel;
import '../../../../route/app_pages.dart';
import '../../orders/data/customer_orders_rx.dart';
import '../../addresses/data/customer_addresses_rx.dart';
import '../../orders/presentation/customer_cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _selectedSubcategory = 'All';
  String _searchQuery = '';
  bool _onlyOnSale = false;

  // Cart state
  final RxList<Map<String, dynamic>> _cartItems = <Map<String, dynamic>>[].obs;

  final List<String> _categories = ['All'];

  final Map<String, List<String>> _subcategories = {
    'All': ['All'],
  };

  // Products list fallback (shown instantly while loading from API in background)
  final List<Map<String, dynamic>> _allProducts = [
    {
      'id': 'mock-1',
      'name': 'Organic Heirloom Tomatoes',
      'origin': 'Andalusia, ES',
      'price': 4.20,
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
      'description': 'These heirloom tomatoes are grown using biodynamic methods in Andalusia, Spain.',
      'category': 'Vegetables',
      'subcategory': 'All',
      'promo': true,
      'onSale': false,
      'originalPrice': 4.20,
    },
    {
      'id': 'mock-2',
      'name': 'Sweet Organic Strawberries',
      'origin': 'Huelva, ES',
      'price': 5.50,
      'imageUrl': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&auto=format&fit=crop',
      'description': 'Juicy, hand-picked organic strawberries from Huelva.',
      'category': 'Fruits',
      'subcategory': 'All',
      'promo': false,
      'onSale': true,
      'originalPrice': 6.50,
    },
    {
      'id': 'mock-3',
      'name': 'Fresh Haas Avocados',
      'origin': 'Michoacán, MX',
      'price': 3.20,
      'imageUrl': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500&auto=format&fit=crop',
      'description': 'Sourced directly from the mountains of Michoacán, Haas avocados.',
      'category': 'Fruits',
      'subcategory': 'All',
      'promo': false,
      'onSale': false,
      'originalPrice': 3.20,
    },
    {
      'id': 'mock-4',
      'name': 'Fresh Goat Cheese',
      'origin': 'Loire Valley, FR',
      'price': 6.80,
      'imageUrl': 'https://images.unsplash.com/photo-1524351199679-46cddf530c04?w=500&auto=format&fit=crop',
      'description': 'A creamy, traditional French chèvre made using raw goat milk.',
      'category': 'Fresh Cheese',
      'subcategory': 'All',
      'promo': false,
      'onSale': false,
      'originalPrice': 6.80,
    }
  ];

  late final GetProductRx _getProductRx;
  late final GetCategoryRx _getCategoryRx;
  late final WishlistRx _wishlistRx;
  late final CustomerShippingMethodsRx _shippingMethodsRx;
  late final CustomerShippingCalculatorRx _shippingCalculatorRx;
  late final CustomerCouponRx _couponRx;
  late final CustomerCreateOrderRx _createOrderRx;
  late final CustomerPaymentConfirmationRx _paymentConfirmationRx;
  late final CustomerAddressesRx _addressesRx;
  List<Results> _apiProducts = [];
  List<Category> _apiCategories = [];
  StreamSubscription? _productSubscription;
  StreamSubscription? _categorySubscription;
  bool _hasNetworkError = false;

  @override
  void initState() {
    super.initState();
    _getProductRx = GetProductRx(
      empty: GetProductModel(),
      dataFetcher: BehaviorSubject<GetProductModel>(),
    );
    _getCategoryRx = GetCategoryRx(
      empty: GetCategoryModel(),
      dataFetcher: BehaviorSubject<GetCategoryModel>(),
    );
    _wishlistRx = Get.put(
      WishlistRx(
        empty: [],
        dataFetcher: BehaviorSubject<List<PostCreateWishlistModel>>.seeded([]),
      ),
      permanent: true,
    );

    _productSubscription = _getProductRx.valueStreamData.listen((data) {
      if (data is GetProductModel && data.results != null) {
        setState(() {
          _apiProducts = data.results!;
          _hasNetworkError = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _hasNetworkError = true;
      });
    });

    _categorySubscription = _getCategoryRx.valueStreamData.listen((data) {
      if (data is GetCategoryModel && data.results != null) {
        setState(() {
          _apiCategories = data.results!;
          _hasNetworkError = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _hasNetworkError = true;
      });
    });

    _getProductRx.fetchProducts();
    _getCategoryRx.fetchCategories();
    _wishlistRx.fetchWishlist();
    
    _shippingMethodsRx = CustomerShippingMethodsRx(
      empty: [],
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _shippingCalculatorRx = CustomerShippingCalculatorRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _couponRx = CustomerCouponRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _createOrderRx = CustomerCreateOrderRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _paymentConfirmationRx = CustomerPaymentConfirmationRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _addressesRx = CustomerAddressesRx(
      empty: [],
      dataFetcher: BehaviorSubject<List<dynamic>>(),
    );
    _addressesRx.fetchAddresses();
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    _categorySubscription?.cancel();
    _getProductRx.dispose();
    _getCategoryRx.dispose();
    _shippingMethodsRx.dispose();
    _shippingCalculatorRx.dispose();
    _couponRx.dispose();
    _createOrderRx.dispose();
    _paymentConfirmationRx.dispose();
    _addressesRx.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _mappedApiProducts {
    return _apiProducts.map((p) {
      final double originalPrice = double.tryParse(p.price ?? '') ?? 0.0;
      final double discountPrice = double.tryParse(p.discountPrice ?? '') ?? 0.0;
      final double finalPrice = (discountPrice > 0) ? discountPrice : originalPrice;
      final bool onSale = discountPrice > 0;

      return {
        'id': p.id ?? '',
        'name': p.name ?? '',
        'origin': p.origin ?? 'Unknown',
        'price': finalPrice,
        'imageUrl': p.thumbnailUrl ?? 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
        'description': p.description ?? '',
        'category': p.category?.name ?? 'All',
        'subcategory': p.subCategory?.name ?? 'All',
        'promo': p.badge != null && p.badge!.isNotEmpty,
        'onSale': onSale,
        'originalPrice': originalPrice,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final sourceList = _mappedApiProducts.isNotEmpty ? _mappedApiProducts : _allProducts;
    List<Map<String, dynamic>> list = List.from(sourceList);

    // Filter by category
    if (_selectedCategory != 'All') {
      list = list.where((p) => p['category'] == _selectedCategory).toList();
    }

    // Filter by subcategory
    if (_selectedSubcategory != 'All') {
      list = list.where((p) => p['subcategory'] == _selectedSubcategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => p['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Filter by on sale
    if (_onlyOnSale) {
      list = list.where((p) => p['onSale'] == true).toList();
    }

    // Sort: Promo products always appear first
    list.sort((a, b) {
      final aPromo = a['promo'] == true ? 1 : 0;
      final bPromo = b['promo'] == true ? 1 : 0;
      return bPromo.compareTo(aPromo);
    });

    return list;
  }

  List<String> get _dynamicCategories {
    if (_apiCategories.isEmpty) return _categories;
    final List<String> list = ['All'];
    list.addAll(_apiCategories.map<String>((c) => c.name ?? '').where((name) => name.isNotEmpty));
    return list;
  }

  Map<String, List<String>> get _dynamicSubcategories {
    if (_apiCategories.isEmpty) return _subcategories;
    final Map<String, List<String>> map = {'All': ['All']};
    for (var cat in _apiCategories) {
      final name = cat.name ?? '';
      if (name.isNotEmpty) {
        final List<String> subs = ['All'];
        if (cat.subcategories != null) {
          subs.addAll(cat.subcategories!.map<String>((s) => s.name ?? '').where((s) => s.isNotEmpty));
        }
        map[name] = subs;
      }
    }
    return map;
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: const Color(0xFF00694C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: const Color(0xFF00694C),
                size: 80.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Connection',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF151E13),
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Please check your internet connection or try again later. We couldn\'t load the store database.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6D7A73),
                height: 1.4,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasNetworkError = false;
                  });
                  _getProductRx.fetchProducts();
                  _getCategoryRx.fetchCategories();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00694C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> prod) {
    final index = _cartItems.indexWhere((item) => item['product']['name'] == prod['name']);
    if (index >= 0) {
      _cartItems[index]['quantity']++;
      _cartItems.refresh();
    } else {
      _cartItems.add({'product': prod, 'quantity': 1});
    }
    Fluttertoast.showToast(
      msg: "${prod['name']} added to cart!",
      backgroundColor: const Color(0xFF00694C),
      textColor: Colors.white,
    );
  }

  void _openCartBottomSheet() {
    _shippingMethodsRx.fetchShippingMethods();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        String checkoutType = 'Collect'; // 'Collect' or 'Delivery'
        String selectedStore = 'El Árbol Centro';
        bool checkingOut = false;
        
        final nameController = TextEditingController(text: 'John Doe');
        final emailController = TextEditingController(text: 'john@example.com');
        final phoneController = TextEditingController(text: '+34622334455');
        
        final streetController = TextEditingController(text: '123 Main Street');
        final cityController = TextEditingController(text: 'Madrid');
        final postcodeController = TextEditingController(text: '28001');
        
        final couponController = TextEditingController();
        
        final cardNumberController = TextEditingController(text: '4111222233334444');
        final cardExpiryController = TextEditingController(text: '12/28');
        final cardCvvController = TextEditingController(text: '123');
        
        Map<String, dynamic>? selectedAddress;
        Map<String, dynamic>? selectedShippingMethod;
        
        String selectedDeliverySlot = 'Morning (9 AM - 12 PM)';
        DateTime deliveryDate = DateTime.now().add(const Duration(days: 1));
        
        String paymentMethod = 'cash'; // 'cash' or 'card'
        
        String appliedCouponCode = '';
        double discountAmount = 0.0;
        double deliveryFee = 0.0;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            double subtotal = 0;
            for (var item in _cartItems) {
              subtotal += (item['product']['price'] as double) * (item['quantity'] as int);
            }
            
            // Recalculate shipping if needed
            Future<void> updateShippingFee() async {
              if (checkoutType == 'Delivery' && selectedShippingMethod != null) {
                final postcode = selectedAddress != null ? (selectedAddress!['postcode'] ?? selectedAddress!['zip_code'] ?? '') : postcodeController.text;
                if (postcode.isNotEmpty) {
                  final calcResult = await _shippingCalculatorRx.calculateShipping({
                    "shipping_method_id": selectedShippingMethod!['id'] ?? selectedShippingMethod!['shipping_method_id'],
                    "postcode": postcode,
                    "items": _cartItems.map((item) => {
                      "product": item['product']['id'],
                      "quantity": item['quantity'],
                    }).toList(),
                  });
                  if (calcResult != null && calcResult is Map) {
                    setModalState(() {
                      deliveryFee = double.tryParse(calcResult['shipping_cost']?.toString() ?? '0.0') ?? 0.0;
                    });
                  }
                }
              } else {
                setModalState(() {
                  deliveryFee = 0.0;
                });
              }
            }
            
            double total = (subtotal + deliveryFee - discountAmount);
            if (total < 0) total = 0;

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Checkout Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Obx(() => Text(
                                '${_cartItems.length} items',
                                style: TextStyle(color: Colors.grey.shade600),
                              )),
                        ],
                      ),
                      const Divider(),
                      
                      // Items List (collapsible or short summary)
                      Obx(() {
                        if (_cartItems.isEmpty) {
                          return SizedBox(
                            height: 100.h,
                            child: const Center(
                              child: Text('Your basket is empty.'),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            final prod = item['product'];
                            final qty = item['quantity'];
    
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.network(
                                      prod['imageUrl'],
                                      width: 40.w,
                                      height: 40.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prod['name'],
                                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '€${(prod['price'] as double).toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                        onPressed: () {
                                          setModalState(() {
                                            if (qty > 1) {
                                              _cartItems[index]['quantity']--;
                                              _cartItems.refresh();
                                            } else {
                                              _cartItems.removeAt(index);
                                            }
                                          });
                                        },
                                      ),
                                      Text('$qty'),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00694C)),
                                        onPressed: () {
                                          setModalState(() {
                                            _cartItems[index]['quantity']++;
                                            _cartItems.refresh();
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      }),
                      
                      const Divider(),
                      
                      // Customer Information
                      Text(
                        'Customer Information',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                      ),
                      
                      const Divider(),
                      
                      // Fulfillment Method selection
                      Text(
                        'Fulfillment Method',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Click & Collect')),
                              selected: checkoutType == 'Collect',
                              selectedColor: const Color(0xFF00694C),
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(color: checkoutType == 'Collect' ? Colors.white : Colors.black),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() {
                                    checkoutType = 'Collect';
                                  });
                                  updateShippingFee();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Home Delivery')),
                              selected: checkoutType == 'Delivery',
                              selectedColor: const Color(0xFF00694C),
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(color: checkoutType == 'Delivery' ? Colors.white : Colors.black),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() {
                                    checkoutType = 'Delivery';
                                  });
                                  updateShippingFee();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
    
                      if (checkoutType == 'Collect') ...[
                        Text('Select Pickup Store', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                        DropdownButton<String>(
                          value: selectedStore,
                          isExpanded: true,
                          underline: Container(height: 1, color: Colors.grey),
                          items: ['El Árbol Centro', 'El Árbol Nervión', 'El Árbol Triana']
                              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedStore = val;
                              });
                            }
                          },
                        ),
                      ] else ...[
                        // Addresses StreamBuilder
                        Text('Delivery Address', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                        StreamBuilder<dynamic>(
                          stream: _addressesRx.valueStreamData,
                          builder: (context, snapshot) {
                            final List<dynamic> addresses = snapshot.data is List ? snapshot.data as List : [];
                            if (addresses.isEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Enter address manually:', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                                  TextFormField(
                                    controller: streetController,
                                    decoration: const InputDecoration(labelText: 'Street Address'),
                                    onChanged: (val) => updateShippingFee(),
                                  ),
                                  TextFormField(
                                    controller: cityController,
                                    decoration: const InputDecoration(labelText: 'City'),
                                    onChanged: (val) => updateShippingFee(),
                                  ),
                                  TextFormField(
                                    controller: postcodeController,
                                    decoration: const InputDecoration(labelText: 'Postcode'),
                                    onChanged: (val) => updateShippingFee(),
                                  ),
                                ],
                              );
                            }
                            
                            if (selectedAddress == null && addresses.isNotEmpty) {
                              selectedAddress = Map<String, dynamic>.from(addresses.first);
                            }
                            
                            return DropdownButton<Map<String, dynamic>>(
                              value: selectedAddress,
                              isExpanded: true,
                              underline: Container(height: 1, color: Colors.grey),
                              items: addresses.map<DropdownMenuItem<Map<String, dynamic>>>((addr) {
                                final title = addr['title'] ?? 'Address';
                                final street = addr['street'] ?? addr['address'] ?? '';
                                final city = addr['city'] ?? '';
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: Map<String, dynamic>.from(addr),
                                  child: Text('$title ($street, $city)'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedAddress = val;
                                  });
                                  updateShippingFee();
                                }
                              },
                            );
                          },
                        ),
                        
                        SizedBox(height: 12.h),
                        // Shipping Methods StreamBuilder
                        Text('Shipping Method', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                        StreamBuilder(
                          stream: _shippingMethodsRx.valueStreamData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            List<dynamic> methods = [];
                            if (snapshot.data is List) {
                              methods = snapshot.data as List;
                            } else if (snapshot.data is Map && (snapshot.data as Map).containsKey('results')) {
                              methods = (snapshot.data as Map)['results'];
                            }
                            
                            if (methods.isEmpty) {
                              return const Text('No shipping methods available.');
                            }
                            
                            if (selectedShippingMethod == null && methods.isNotEmpty) {
                              selectedShippingMethod = Map<String, dynamic>.from(methods.first);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                updateShippingFee();
                              });
                            }
                            
                            return DropdownButton<Map<String, dynamic>>(
                              value: selectedShippingMethod,
                              isExpanded: true,
                              underline: Container(height: 1, color: Colors.grey),
                              items: methods.map<DropdownMenuItem<Map<String, dynamic>>>((m) {
                                final name = m['name'] ?? 'Shipping';
                                final rate = m['cost'] ?? m['rate'] ?? '0.0';
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: Map<String, dynamic>.from(m),
                                  child: Text('$name (€$rate)'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedShippingMethod = val;
                                  });
                                  updateShippingFee();
                                }
                              },
                            );
                          },
                        ),
                      ],
                      
                      const Divider(),
                      
                      // Delivery Schedule
                      Text(
                        'Delivery Date & Time Slot',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: deliveryDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    deliveryDate = picked;
                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text('${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}'),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedDeliverySlot,
                              isExpanded: true,
                              items: ['Morning (9 AM - 12 PM)', 'Afternoon (1 PM - 4 PM)', 'Evening (5 PM - 8 PM)']
                                  .map((slot) => DropdownMenuItem(value: slot, child: Text(slot, style: TextStyle(fontSize: 12.sp))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedDeliverySlot = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(),
                      
                      // Coupon Application
                      Text(
                        'Coupon Code',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: couponController,
                              decoration: const InputDecoration(
                                hintText: 'Enter coupon (e.g. SAVE40)',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton(
                            onPressed: () async {
                              if (couponController.text.isEmpty) return;
                              final couponResult = await _couponRx.validateCoupon(couponController.text);
                              if (couponResult != null && couponResult is Map) {
                                setModalState(() {
                                  appliedCouponCode = couponController.text;
                                  discountAmount = double.tryParse(couponResult['discount']?.toString() ?? '0.0') ?? 0.0;
                                  if (discountAmount == 0.0) {
                                    // Fallback percentage or flat if not directly present as 'discount'
                                    discountAmount = (subtotal * 0.40); // e.g. SAVE40 gives 40% discount
                                  }
                                });
                                Fluttertoast.showToast(msg: "Coupon Applied successfully!");
                              } else {
                                Fluttertoast.showToast(msg: "Invalid or Expired Coupon");
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
                            child: const Text('Apply', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      if (appliedCouponCode.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text('Applied Coupon: $appliedCouponCode (€${discountAmount.toStringAsFixed(2)} saved)', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                      
                      const Divider(),
                      
                      // Payment Method
                      Text(
                        'Payment Method',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Cash on Delivery')),
                              selected: paymentMethod == 'cash',
                              selectedColor: const Color(0xFF00694C),
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(color: paymentMethod == 'cash' ? Colors.white : Colors.black),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() {
                                    paymentMethod = 'cash';
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Credit/Debit Card')),
                              selected: paymentMethod == 'card',
                              selectedColor: const Color(0xFF00694C),
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(color: paymentMethod == 'card' ? Colors.white : Colors.black),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() {
                                    paymentMethod = 'card';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      if (paymentMethod == 'card') ...[
                        SizedBox(height: 12.h),
                        Text('Credit Card Details', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: cardNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Card Number', prefixIcon: Icon(Icons.credit_card)),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: cardExpiryController,
                                decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: TextFormField(
                                controller: cardCvvController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'CVV'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const Divider(),
                      
                      // Billing Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('€${subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      if (checkoutType == 'Delivery')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery Fee'),
                            Text('€${deliveryFee.toStringAsFixed(2)}'),
                          ],
                        ),
                      if (discountAmount > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discount', style: TextStyle(color: Colors.green)),
                            Text('-€${discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total to Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('€${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800, fontSize: 16.sp)),
                        ],
                      ),
                      SizedBox(height: 24.h),
    
                      // Order Checkout Actions
                      if (_cartItems.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () async {
                              setModalState(() {
                                checkingOut = true;
                              });
                              
                              final orderPayload = {
                                "customer_name": nameController.text,
                                "customer_email": emailController.text,
                                "customer_phone": phoneController.text,
                                "street_address": checkoutType == 'Delivery' ? (selectedAddress != null ? (selectedAddress!['street'] ?? selectedAddress!['address'] ?? '') : streetController.text) : 'Pickup at store',
                                "city": checkoutType == 'Delivery' ? (selectedAddress != null ? selectedAddress!['city'] : cityController.text) : selectedStore,
                                "postcode": checkoutType == 'Delivery' ? (selectedAddress != null ? (selectedAddress!['postcode'] ?? selectedAddress!['zip_code'] ?? '') : postcodeController.text) : '0000',
                                "payment_method": paymentMethod,
                                "coupon_code": appliedCouponCode,
                                "delivery_date": deliveryDate.toIso8601String().split('T').first,
                                "delivery_slot_label": selectedDeliverySlot,
                                "items": _cartItems.map((item) => {
                                  "item_type": "product",
                                  "product": item['product']['id'],
                                  "quantity": item['quantity'],
                                }).toList(),
                              };
                              
                              if (paymentMethod == 'card') {
                                orderPayload.addAll({
                                  "card_number": cardNumberController.text,
                                  "card_expiry": cardExpiryController.text,
                                  "card_cvv": cardCvvController.text,
                                });
                              }
                              
                              final createSuccess = await _createOrderRx.createOrder(orderPayload);
                              if (createSuccess) {
                                final createdOrderData = _createOrderRx.valueStreamData.value;
                                if (createdOrderData != null && createdOrderData is Map) {
                                  final orderId = createdOrderData['id']?.toString() ?? createdOrderData['order_id']?.toString();
                                  if (orderId != null) {
                                    // Submit order
                                    final submitSuccess = await _createOrderRx.submitOrder({"order_id": orderId});
                                    if (submitSuccess) {
                                      // Confirm payment
                                      if (paymentMethod == 'card') {
                                        await _paymentConfirmationRx.confirmPayment({
                                          "order_id": orderId,
                                          "transaction_id": "ST_MOCK_${DateTime.now().millisecondsSinceEpoch}",
                                          "status": "succeeded",
                                        });
                                      }
                                      
                                      Navigator.pop(context);
                                      
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                          title: const Text('Order Placed!'),
                                          content: Text('Your order #$orderId has been placed successfully.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text('OK'),
                                            )
                                          ],
                                        ),
                                      );
                                      
                                      setState(() {
                                        _cartItems.clear();
                                      });
                                      return;
                                    }
                                  }
                                }
                              }
                              
                              setModalState(() {
                                checkingOut = false;
                              });
                              Fluttertoast.showToast(msg: "Failed to place order. Please try again.");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00694C),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Text(
                              paymentMethod == 'cash' ? 'Place Order (Cash on Delivery)' : 'Pay €${total.toStringAsFixed(2)} via Stripe',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);
    final products = _filteredProducts;

    if (_hasNetworkError) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAF8),
        body: SafeArea(child: _buildErrorView()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'El Árbol',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF151E13)),
            onPressed: () => Get.toNamed(Routes.WISHLIST),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket, color: Color(0xFF151E13)),
                onPressed: () => Get.to(() => CustomerCartScreen(cartItems: _cartItems)),
              ),
              Obx(() {
                if (_cartItems.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '${_cartItems.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Flash sale toggle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search products...',
                                border: InputBorder.none,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Flash Deal Filter Toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _onlyOnSale = !_onlyOnSale;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: _onlyOnSale ? const Color(0xFFE25B3D) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(
                        Icons.flash_on,
                        color: _onlyOnSale ? Colors.white : const Color(0xFFE25B3D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Promos Banner Slider (only shows when not actively filtering by category or sale)
            if (_selectedCategory == 'All' && !_onlyOnSale && _searchQuery.isEmpty)
              const PromoSlider(),

            // Categories horizontal list
            SizedBox(height: 10.h),
            SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _dynamicCategories.length,
                itemBuilder: (context, index) {
                  final cat = _dynamicCategories[index];
                  final isSelected = _selectedCategory == cat;

                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                            _selectedSubcategory = 'All'; // reset subcategory on parent change
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            // Subcategories horizontal list (if category is not 'All')
            if (_selectedCategory != 'All' && _dynamicSubcategories[_selectedCategory] != null) ...[
              SizedBox(height: 6.h),
              SizedBox(
                height: 35.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: _dynamicSubcategories[_selectedCategory]!.length,
                  itemBuilder: (context, index) {
                    final sub = _dynamicSubcategories[_selectedCategory]![index];
                    final isSelected = _selectedSubcategory == sub;

                    return Container(
                      margin: EdgeInsets.only(right: 6.w),
                      child: ChoiceChip(
                        label: Text(
                          sub,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontSize: 11.sp,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.grey.shade700,
                        backgroundColor: Colors.grey.shade100,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSubcategory = sub;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],

            // Products Grid
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('No products found matching your filters.'))
                  : GridView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final prod = products[index];
                        return _buildProductCard(
                          context,
                          prod,
                          primaryColor,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> prod,
    Color primaryColor,
  ) {
    final bool onSale = prod['onSale'] == true;
    final bool isPromo = prod['promo'] == true;

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailsScreen(
              id: prod['id']?.toString(),
              name: prod['name'],
              origin: prod['origin'],
              price: '€${(prod['price'] as double).toStringAsFixed(2)}',
              imageUrl: prod['imageUrl'],
              description: prod['description'],
              category: prod['category'],
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
            )
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: CachedNetworkImage(
                      imageUrl: prod['imageUrl'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(Icons.grass, color: primaryColor, size: 36.r),
                      ),
                    ),
                  ),
                  if (onSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE25B3D),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Text(
                          'SALE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isPromo)
                    Positioned(
                      top: onSale ? 32 : 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Text(
                          'PROMO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Wishlist heart toggle button
                  if (prod['id'] != null && prod['id'].toString().isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: StreamBuilder<List<PostCreateWishlistModel>>(
                        stream: _wishlistRx.valueStreamData,
                        builder: (context, snapshot) {
                          final isWish = _wishlistRx.isWishlisted(prod['id'].toString());

                          return GestureDetector(
                            onTap: () {
                              if (isWish) {
                                _wishlistRx.removeItem(prod['id'].toString());
                              } else {
                                _wishlistRx.addItem(prod['id'].toString());
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isWish ? Icons.favorite : Icons.favorite_border_rounded,
                                color: isWish ? Colors.red : Colors.grey,
                                size: 18.r,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Description info
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod['name'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: const Color(0xFF151E13),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'from ${prod['origin']}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF6D7A73),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (onSale && prod['originalPrice'] != null)
                            Text(
                              '€${(prod['originalPrice'] as double).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '€${(prod['price'] as double).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(prod),
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_shopping_cart,
                            color: primaryColor,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromoSlider extends StatefulWidget {
  const PromoSlider({super.key});

  @override
  State<PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<PromoSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> promoBanners = [
    {
      'title': 'Fresh Fruits & Veggies',
      'discount': '20% OFF',
      'sub': '100% Organic, direct from Huelva farms.',
      'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&auto=format&fit=crop',
    },
    {
      'title': 'Artisan Cheese Festival',
      'discount': 'Special Offer',
      'sub': 'Premium Loire Valley goat cheese selection.',
      'imageUrl': 'https://images.unsplash.com/photo-1552767059-ce182ead6c1b?w=800&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < promoBanners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemCount: promoBanners.length,
            itemBuilder: (context, index) {
              final banner = promoBanners[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(banner['imageUrl']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00694C),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          banner['discount']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        banner['title']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        banner['sub']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            promoBanners.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentPage == index ? 16.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFF00694C) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
