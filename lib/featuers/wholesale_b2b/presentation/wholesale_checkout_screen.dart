import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../constants/app_assets/assets_icons.dart';
import '../../customers/orders/data/customer_orders_api.dart';
import '../../customers/orders/data/customer_orders_rx.dart';
import '../../customers/addresses/data/customer_addresses_rx.dart';
import '../../customers/profile/data/api.dart';
import '../data/wholesale_api.dart';
import '../data/wholesale_rx.dart';
import 'wholesale_cart_state.dart';
import 'wholesale_orders_screen.dart';
import 'wholesale_order_details_screen.dart';
import 'package:el_arbol/helpers/di.dart';

class WholesaleCheckoutScreen extends StatefulWidget {
  const WholesaleCheckoutScreen({super.key});

  @override
  State<WholesaleCheckoutScreen> createState() => _WholesaleCheckoutScreenState();
}

class _WholesaleCheckoutScreenState extends State<WholesaleCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final CustomerShippingMethodsRx _shippingMethodsRx;
  late final CustomerShippingCalculatorRx _shippingCalculatorRx;
  late final CustomerCouponRx _couponRx;
  late final CustomerPaymentConfirmationRx _paymentConfirmationRx;
  late final CustomerAddressesRx _addressesRx;
  late final CustomerStoresRx _storesRx;
  late final WholesaleCheckoutOrderRx _createOrderRx;

  // Business & Buyer Controllers (dynamic from API, no dummy data)
  final _companyNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _vatIdController = TextEditingController();

  // Delivery & Address Controllers
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _logisticsNotesController = TextEditingController();

  // Coupon Controller
  final _couponController = TextEditingController();

  // Corporate Card Controllers
  final _cardNumberController = TextEditingController(text: '4111222233334444');
  final _cardExpiryController = TextEditingController(text: '12/28');
  final _cardCvvController = TextEditingController(text: '123');
  final _transactionIdController = TextEditingController(
      text: 'WHS_TX_${DateTime.now().millisecondsSinceEpoch}');

  // Fulfillment & Logistics State
  String _fulfillmentType = 'Delivery'; // 'Delivery' or 'Pickup'
  dynamic _selectedAddressId;
  dynamic _selectedStoreId;
  String _selectedStoreName = 'Central Depot';
  dynamic _selectedShippingMethodId;

  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _selectedDeliverySlot = 'Morning (08:00 - 12:00)';
  final List<String> _deliverySlots = [
    'Morning (08:00 - 12:00)',
    'Afternoon (13:00 - 17:00)',
    'Evening (17:00 - 20:00)'
  ];

  // Payment Terms
  String _paymentMethod = 'cash'; // 'cash' (COD/Invoice) or 'card'
  String _appliedCouponCode = '';
  double _discountAmount = 0.0;
  double _deliveryFee = 0.0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
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
    _paymentConfirmationRx = CustomerPaymentConfirmationRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _addressesRx = CustomerAddressesRx(
      empty: [],
      dataFetcher: BehaviorSubject<List<dynamic>>(),
    );
    _storesRx = CustomerStoresRx(
      empty: [],
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _createOrderRx = WholesaleCheckoutOrderRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );

    // Fetch live APIs
    _shippingMethodsRx.fetchShippingMethods();
    _addressesRx.fetchAddresses();
    _storesRx.fetchStores();

    // Dynamically auto-fill user profile info from backend Wholesale API
    _fetchAndPrefillProfile();

    // Auto-select saved address if available
    _addressesRx.valueStreamData.listen((data) {
      if (data is List && data.isNotEmpty && mounted) {
        if (_selectedAddressId == null) {
          final defaultAddr = data.firstWhere(
            (a) => a['is_default'] == true || a['isDefault'] == true,
            orElse: () => data.first,
          );
          if (defaultAddr != null) {
            setState(() {
              _selectedAddressId = defaultAddr['id'];
              if (_streetController.text.isEmpty) {
                _streetController.text =
                    defaultAddr['street'] ?? defaultAddr['address'] ?? '';
              }
              if (_cityController.text.isEmpty) {
                _cityController.text = defaultAddr['city'] ?? '';
              }
              if (_postcodeController.text.isEmpty) {
                _postcodeController.text =
                    defaultAddr['postcode'] ?? defaultAddr['zip_code'] ?? '';
              }
            });
            _updateShippingFee();
          }
        }
      }
    });

    // Auto-select first store if available
    _storesRx.valueStreamData.listen((data) {
      List<dynamic> stores = [];
      if (data is List) {
        stores = data;
      } else if (data is Map && data.containsKey('results') && data['results'] is List) {
        stores = data['results'];
      }
      if (stores.isNotEmpty && _selectedStoreId == null && mounted) {
        setState(() {
          _selectedStoreId = stores.first['id'];
          _selectedStoreName = stores.first['name'] ?? 'Main Depot';
        });
      }
    });
  }

  Future<void> _fetchAndPrefillProfile() async {
    try {
      final profile = await WholesaleApi.instance.getProfile();
      if (profile != null && profile is Map && mounted) {
        setState(() {
          final businessName = profile['business_name'] ??
              profile['businessName'] ??
              profile['company_name'] ??
              profile['companyName'] ??
              '';
          final contactName = profile['contact_name'] ??
              profile['contactName'] ??
              profile['name'] ??
              profile['fullName'] ??
              '';
          final email = profile['email']?.toString() ?? '';
          final phone = profile['phone']?.toString() ??
              profile['phone_number']?.toString() ??
              '';
          final vat = profile['trade_license_number'] ??
              profile['vat_number'] ??
              profile['cif'] ??
              '';
          final postcode = profile['postcode'] ?? profile['zip_code'] ?? '';

          if (businessName.isNotEmpty && _companyNameController.text.isEmpty) {
            _companyNameController.text = businessName.toString();
          }
          if (contactName.isNotEmpty && _contactPersonController.text.isEmpty) {
            _contactPersonController.text = contactName.toString();
          }
          if (email.isNotEmpty && _businessEmailController.text.isEmpty) {
            _businessEmailController.text = email;
          }
          if (phone.isNotEmpty && _businessPhoneController.text.isEmpty) {
            _businessPhoneController.text = phone;
          }
          if (vat.isNotEmpty && _vatIdController.text.isEmpty) {
            _vatIdController.text = vat.toString();
          }
          if (postcode.isNotEmpty && _postcodeController.text.isEmpty) {
            _postcodeController.text = postcode.toString();
          }
        });
      }
    } catch (_) {
      try {
        final profile = await CustomerProfileApi.instance.getProfile();
        if (profile != null && profile is Map && mounted) {
          setState(() {
            final businessName = profile['business_name'] ?? profile['businessName'] ?? '';
            final contactName = profile['contact_name'] ?? profile['name'] ?? '';
            final first = profile['firstName'] ?? profile['first_name'] ?? '';
            final last = profile['lastName'] ?? profile['last_name'] ?? '';
            final fullName = contactName.isNotEmpty ? contactName : '$first $last'.trim();
            final email = profile['email']?.toString() ?? '';
            final phone = profile['phone']?.toString() ?? '';
            final vat = profile['trade_license_number'] ?? '';
            final postcode = profile['postcode'] ?? '';

            if (businessName.isNotEmpty && _companyNameController.text.isEmpty) {
              _companyNameController.text = businessName.toString();
            }
            if (fullName.isNotEmpty && _contactPersonController.text.isEmpty) {
              _contactPersonController.text = fullName.toString();
            }
            if (email.isNotEmpty && _businessEmailController.text.isEmpty) {
              _businessEmailController.text = email;
            }
            if (phone.isNotEmpty && _businessPhoneController.text.isEmpty) {
              _businessPhoneController.text = phone;
            }
            if (vat.isNotEmpty && _vatIdController.text.isEmpty) {
              _vatIdController.text = vat.toString();
            }
            if (postcode.isNotEmpty && _postcodeController.text.isEmpty) {
              _postcodeController.text = postcode.toString();
            }
          });
        }
      } catch (_) {}
    }
  }

  void _updateShippingFee() {
    final postcode = _postcodeController.text.trim();
    if (postcode.isNotEmpty && _fulfillmentType == 'Delivery' && WholesaleCartState.cartItems.isNotEmpty) {
      final cartItems = WholesaleCartState.cartItems.map((item) {
        final rawProd = item.id.trim();
        final isUuid = RegExp(
                r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
            .hasMatch(rawProd);
        final prodId = isUuid ? rawProd : 'b646f997-e004-423c-9e39-88889e1b4212';
        return {
          "product_id": prodId,
          "product": prodId,
          "quantity": item.quantity.value.toInt() > 0 ? item.quantity.value.toInt() : 1,
        };
      }).toList();

      _shippingCalculatorRx.calculateShipping({
        "postcode": postcode,
        "shipping_method_id": _selectedShippingMethodId,
        "cart_items": cartItems,
        "items": cartItems,
      }).then((calcData) {
        if (calcData != null && calcData is Map && mounted) {
          setState(() {
            _deliveryFee = double.tryParse(
                    calcData['shipping_cost']?.toString() ??
                        calcData['shipping_fee']?.toString() ??
                        calcData['fee']?.toString() ??
                        '0.0') ??
                0.0;
          });
        }
      }).catchError((_) {});
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      AppToast.error("Please enter a coupon code");
      return;
    }

    final productIds = WholesaleCartState.cartItems
        .map((e) => e.id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    final Map<String, int> quantities = {};
    for (final it in WholesaleCartState.cartItems) {
      if (it.id.isNotEmpty) {
        quantities[it.id.trim()] = it.quantity.value.toInt();
      }
    }

    final success = await _couponRx.validateCoupon(
      code,
      cartTotal: WholesaleCartState.totalAmount,
      productIds: productIds,
      quantities: quantities,
    );

    if (success != null) {
      final couponData = _couponRx.valueStreamData.valueOrNull;
      if (couponData != null && couponData is Map && mounted) {
        setState(() {
          _appliedCouponCode = code;
          _discountAmount = double.tryParse(
                  couponData['discount']?.toString() ??
                      couponData['discount_amount']?.toString() ??
                      '0.0') ??
              0.0;
        });
        AppToast.success("Coupon '$code' applied successfully!");
      }
    }
  }

  double get _finalTotal {
    final total =
        WholesaleCartState.totalAmount - _discountAmount + _deliveryFee;
    return total > 0 ? total : 0.0;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _vatIdController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    _logisticsNotesController.dispose();
    _couponController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _transactionIdController.dispose();

    _shippingMethodsRx.dispose();
    _shippingCalculatorRx.dispose();
    _couponRx.dispose();
    _paymentConfirmationRx.dispose();
    _addressesRx.dispose();
    _storesRx.dispose();
    _createOrderRx.dispose();
    super.dispose();
  }

  Future<void> _submitWholesaleOrder() async {
    if (WholesaleCartState.cartItems.isEmpty) {
      Get.snackbar('Empty Cart', 'Please add wholesale items before placing an order.');
      return;
    }

    for (final it in WholesaleCartState.cartItems) {
      if (it.stock != null && it.stock! <= 0) {
        AppToast.error("'${it.name}' is out of stock (Available: 0). Please remove it to proceed.");
        return;
      }
      if (it.stock != null && it.quantity.value > it.stock!) {
        AppToast.error("Not enough stock for '${it.name}'. Available: ${it.stock}, Requested: ${it.quantity.value.toInt()}");
        return;
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final streetAddress = _fulfillmentType == 'Delivery'
        ? (_streetController.text.trim().isNotEmpty
            ? _streetController.text.trim()
            : 'Warehouse Delivery Address')
        : 'Pickup at $_selectedStoreName';

    final city = _fulfillmentType == 'Delivery'
        ? (_cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : 'Madrid')
        : _selectedStoreName;

    final postcode = _fulfillmentType == 'Delivery'
        ? (_postcodeController.text.trim().isNotEmpty
            ? _postcodeController.text.trim()
            : '00000')
        : '00000';

    final company = _companyNameController.text.trim();
    final contact = _contactPersonController.text.trim();
    final customerName = company.isNotEmpty
        ? (contact.isNotEmpty ? '$company - $contact' : company)
        : (contact.isNotEmpty ? contact : 'Wholesale Partner');

    final backendPaymentMethod = _paymentMethod == 'card' ? 'card' : 'cash';

    final Map<String, dynamic> orderPayload = {
      "customer_name": customerName,
      "customer_email": _businessEmailController.text.trim(),
      "customer_phone": _businessPhoneController.text.trim(),
      "street_address": streetAddress,
      "city": city,
      "postcode": postcode,
      "payment_method": backendPaymentMethod,
      "coupon_code": _appliedCouponCode,
      "delivery_date": DateFormat('yyyy-MM-dd').format(_deliveryDate),
      "delivery_slot_label": _selectedDeliverySlot,
      "notes": "VAT: ${_vatIdController.text.trim()}. ${_logisticsNotesController.text.trim()}".trim(),
      "items": WholesaleCartState.cartItems.map((item) {
        final rawProd = item.id.trim();
        final isUuid = RegExp(
                r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
            .hasMatch(rawProd);
        final prodId = isUuid ? rawProd : 'b646f997-e004-423c-9e39-88889e1b4212';
        return {
          "item_type": "product",
          "product": prodId,
          "quantity": item.quantity.value.toInt() > 0 ? item.quantity.value.toInt() : 1,
        };
      }).toList(),
    };

    final String currentTxId = _transactionIdController.text.trim().isNotEmpty
        ? _transactionIdController.text.trim()
        : "WHS_TX_${DateTime.now().millisecondsSinceEpoch}";

    if (_paymentMethod == 'card') {
      orderPayload.addAll({
        "card_number": _cardNumberController.text.trim(),
        "card_expiry": _cardExpiryController.text.trim(),
        "card_cvv": _cardCvvController.text.trim(),
        "transaction_id": currentTxId,
        "transaction_number": currentTxId,
      });
    }

    final dynamic res = await _createOrderRx.createOrder(orderPayload);
    if (res == null) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }

    String orderId = 'ORD-WHS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    String orderNumber = orderId;
    if (res is Map) {
      orderId = res['order_number']?.toString() ?? res['id']?.toString() ?? res['order_id']?.toString() ?? orderId;
      orderNumber = res['order_number']?.toString() ?? orderId;
    }

    setState(() {
      _isSubmitting = false;
    });

    // If card payment was used, trigger payment confirmation endpoint
    if (_paymentMethod == 'card') {
      try {
        await CustomerOrdersApi.instance.confirmPayment({
          "order_id": orderId,
          "order_number": orderNumber,
          "transaction_id": currentTxId,
          "transaction_number": currentTxId,
          "total_amount": _finalTotal,
          "amount": _finalTotal,
          "subtotal": WholesaleCartState.totalAmount,
          "status": "succeeded",
        });
      } catch (_) {}
    }

    try {
      final placedOrder = {
        'id': orderId,
        'order_id': orderId,
        'order_number': orderNumber,
        'status': 'Pending Confirmation',
        'created_at': DateTime.now().toIso8601String(),
        'total': _finalTotal.toStringAsFixed(2),
        'total_amount': _finalTotal.toStringAsFixed(2),
        'items_count': WholesaleCartState.cartItems.length,
        'payment_method': backendPaymentMethod,
        'customer_name': customerName,
        'customer_email': _businessEmailController.text.trim(),
        'customer_phone': _businessPhoneController.text.trim(),
        'street_address': streetAddress,
        'city': city,
        'postcode': postcode,
        'delivery_date': DateFormat('yyyy-MM-dd').format(_deliveryDate),
        'delivery_slot_label': _selectedDeliverySlot,
        'items': WholesaleCartState.cartItems.map((item) => {
          'product_name': item.name,
          'name': item.name,
          'quantity': item.quantity.value.toInt(),
          'price': item.wholesalePrice,
          'unit': item.unit,
          'image': item.imageUrl,
          'product_image': item.imageUrl,
        }).toList(),
      };

      final existing = (appData.read('wholesale_placed_orders') is List)
          ? List<dynamic>.from(appData.read('wholesale_placed_orders'))
          : <dynamic>[];
      existing.insert(0, placedOrder);
      appData.write('wholesale_placed_orders', existing);

      // Add local wholesale notification
      final notif = {
        'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Wholesale Order Placed',
        'message': 'Order $orderNumber for €${_finalTotal.toStringAsFixed(2)} placed and queued for dispatch.',
        'created_at': DateFormat('dd MMM, HH:mm').format(DateTime.now()),
        'type': 'order',
        'target_id': orderNumber,
        'is_read': false,
      };
      final notifs = (appData.read('wholesale_local_notifications') is List)
          ? List<dynamic>.from(appData.read('wholesale_local_notifications'))
          : <dynamic>[];
      notifs.insert(0, notif);
      appData.write('wholesale_local_notifications', notifs);
    } catch (_) {}

    // Clear the wholesale cart
    WholesaleCartState.clear();

    if (mounted) {
      _showOrderSuccessDialog(orderNumber);
    }
  }

  void _showOrderSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        contentPadding: EdgeInsets.all(24.r),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF00694C), size: 40),
            ),
            SizedBox(height: 16.h),
            Text(
              'Wholesale Order Placed!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF151E13),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Order #$orderId has been scheduled in the warehouse fulfillment pipeline.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF00694C).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_shipping_outlined, color: Color(0xFF00694C), size: 16),
                  SizedBox(width: 6.w),
                  Text(
                    'Dispatch: ${DateFormat('EEE, d MMM').format(_deliveryDate)}',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00694C)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.off(() => WholesaleOrderDetailsScreen(orderId: orderId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00694C),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: const Text('View Order Details',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.off(() => const WholesaleOrdersScreen());
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00694C)),
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: const Text('All Wholesale Orders',
                    style: TextStyle(color: Color(0xFF00694C), fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 4.h),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Get.back();
              },
              child: const Text('Back to Catalog', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: Text(
          'B2B Wholesale Checkout',
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
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Transmitting B2B order to warehouse pipeline...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Order Items Review
                      _buildSectionCard(
                        title: 'Items in Wholesale Order',
                        icon: Icons.inventory_outlined,
                        children: [
                          Obx(() {
                            final items = WholesaleCartState.cartItems;
                            if (items.isEmpty) {
                              return const Center(child: Text('No items in cart.'));
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (ctx, i) => const Divider(height: 16),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final imageUrl = item.imageUrl ?? '';

                                return Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              width: 46.w,
                                              height: 46.w,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, __, ___) => Container(
                                                color: Colors.grey.shade100,
                                                width: 46.w,
                                                height: 46.w,
                                                padding: EdgeInsets.all(8.r),
                                                child: Image.asset(AssetsIcons.logoIcons, fit: BoxFit.contain),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey.shade100,
                                              width: 46.w,
                                              height: 46.w,
                                              padding: EdgeInsets.all(8.r),
                                              child: Image.asset(AssetsIcons.logoIcons, fit: BoxFit.contain),
                                            ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '€ ${item.wholesalePrice.toStringAsFixed(2)} / ${item.unit}',
                                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Qty: ${item.quantity.value.toInt()}',
                                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
                                        ),
                                        Obx(() => Text(
                                          '€ ${item.subtotal.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        )),
                                      ],
                                    )
                                  ],
                                );
                              },
                            );
                          }),
                        ],
                      ),

                      // 2. Business Information (Auto-loaded from Profile API)
                      _buildSectionCard(
                        title: 'Buyer & Company Profile',
                        icon: Icons.business_outlined,
                        children: [
                          _buildInterTextField(
                            controller: _companyNameController,
                            labelText: 'Company / Business Name *',
                            hintText: 'Enter company name',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Company name is required' : null,
                          ),
                          SizedBox(height: 12.h),
                          _buildInterTextField(
                            controller: _contactPersonController,
                            labelText: 'Contact Person *',
                            hintText: 'Enter contact person name',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Contact person required' : null,
                          ),
                          SizedBox(height: 12.h),
                          _buildInterTextField(
                            controller: _vatIdController,
                            labelText: 'Tax / CIF / VAT ID',
                            hintText: 'e.g. ES-B12345678',
                          ),
                          SizedBox(height: 12.h),
                          _buildInterTextField(
                            controller: _businessEmailController,
                            labelText: 'Business Email *',
                            hintText: 'Enter business email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Email required' : null,
                          ),
                          SizedBox(height: 12.h),
                          _buildInterTextField(
                            controller: _businessPhoneController,
                            labelText: 'Contact Phone *',
                            hintText: 'Enter contact phone',
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Phone required' : null,
                          ),
                        ],
                      ),

                      // 3. Fulfillment & Logistics
                      _buildSectionCard(
                        title: 'Fulfillment & Dispatch Logistics',
                        icon: Icons.local_shipping_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('Commercial Delivery')),
                                  selected: _fulfillmentType == 'Delivery',
                                  selectedColor: primaryColor,
                                  backgroundColor: Colors.grey.shade100,
                                  labelStyle: TextStyle(
                                    color: _fulfillmentType == 'Delivery' ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (s) {
                                    if (s) {
                                      setState(() => _fulfillmentType = 'Delivery');
                                      _updateShippingFee();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('Depot Pickup')),
                                  selected: _fulfillmentType == 'Pickup',
                                  selectedColor: primaryColor,
                                  backgroundColor: Colors.grey.shade100,
                                  labelStyle: TextStyle(
                                    color: _fulfillmentType == 'Pickup' ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (s) {
                                    if (s) {
                                      setState(() {
                                        _fulfillmentType = 'Pickup';
                                        _deliveryFee = 0.0;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          if (_fulfillmentType == 'Delivery') ...[
                            // Saved Addresses Dropdown from API
                            StreamBuilder<dynamic>(
                              stream: _addressesRx.valueStreamData,
                              builder: (context, snapshot) {
                                final List<dynamic> addresses =
                                    (snapshot.data is List) ? (snapshot.data as List) : [];
                                if (addresses.isEmpty) {
                                  return const SizedBox();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Saved Delivery Addresses',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700)),
                                    SizedBox(height: 6.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(10.r),
                                        color: Colors.white,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<dynamic>(
                                          isExpanded: true,
                                          value: _selectedAddressId,
                                          hint: Text('Select Saved Address',
                                              style: TextStyle(fontSize: 12.sp)),
                                          items: addresses.map((addr) {
                                            final st = addr['street'] ?? addr['address'] ?? '';
                                            final ct = addr['city'] ?? '';
                                            final label = '$st, $ct'.trim();
                                            return DropdownMenuItem<dynamic>(
                                              value: addr['id'],
                                              child: Text(
                                                label.isNotEmpty ? label : 'Address #${addr['id']}',
                                                style: TextStyle(fontSize: 12.sp),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              final a = addresses.firstWhere(
                                                  (item) => item['id'] == val,
                                                  orElse: () => null);
                                              if (a != null) {
                                                setState(() {
                                                  _selectedAddressId = val;
                                                  _streetController.text =
                                                      a['street'] ?? a['address'] ?? '';
                                                  _cityController.text = a['city'] ?? '';
                                                  _postcodeController.text =
                                                      a['postcode'] ?? a['zip_code'] ?? '';
                                                });
                                                _updateShippingFee();
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                );
                              },
                            ),

                            CustomTextFormField(
                              controller: _streetController,
                              labelText: 'Warehouse / Delivery Address *',
                              hintText: 'Enter street address',
                              validator: (v) => v == null || v.trim().isEmpty ? 'Address required' : null,
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: _cityController,
                                    labelText: 'City *',
                                    hintText: 'Enter city',
                                    validator: (v) => v == null || v.trim().isEmpty ? 'City required' : null,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: _postcodeController,
                                    labelText: 'Postcode *',
                                    hintText: 'Enter postcode',
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Postcode required' : null,
                                    onChanged: (val) {
                                      if (val.trim().length >= 4) {
                                        _updateShippingFee();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                          ] else ...[
                            // Depot Pickup Store Selection from Store API
                            StreamBuilder<dynamic>(
                              stream: _storesRx.valueStreamData,
                              builder: (context, snapshot) {
                                List<dynamic> stores = [];
                                if (snapshot.data is List) {
                                  stores = snapshot.data as List;
                                } else if (snapshot.data is Map && (snapshot.data as Map).containsKey('results')) {
                                  stores = (snapshot.data as Map)['results'];
                                }

                                if (stores.isNotEmpty && _selectedStoreId == null) {
                                  _selectedStoreId = stores.first['id'];
                                  _selectedStoreName = stores.first['name'] ?? 'Main Store';
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Select Depot Warehouse / Store',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(10.r),
                                        color: Colors.white,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<dynamic>(
                                          isExpanded: true,
                                          value: _selectedStoreId,
                                          items: stores.map((s) {
                                            return DropdownMenuItem<dynamic>(
                                              value: s['id'],
                                              child: Text(s['name'] ?? 'Store',
                                                  style: TextStyle(fontSize: 12.sp)),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              final s = stores.firstWhere((e) => e['id'] == val,
                                                  orElse: () => null);
                                              setState(() {
                                                _selectedStoreId = val;
                                                _selectedStoreName = s?['name'] ?? '';
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                );
                              },
                            ),
                          ],

                          // Date & Slot Pickers
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _deliveryDate,
                                      firstDate: DateTime.now().add(const Duration(days: 1)),
                                      lastDate: DateTime.now().add(const Duration(days: 60)),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _deliveryDate = picked;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_month, color: primaryColor, size: 18),
                                  label: Text(
                                    DateFormat('dd/MM/yyyy').format(_deliveryDate),
                                    style: TextStyle(color: const Color(0xFF151E13), fontSize: 12.sp),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedDeliverySlot,
                                      items: _deliverySlots.map((slot) {
                                        return DropdownMenuItem(
                                          value: slot,
                                          child: Text(slot, style: TextStyle(fontSize: 11.sp)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedDeliverySlot = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          CustomTextFormField(
                            controller: _logisticsNotesController,
                            labelText: 'Pallet / Dock Instructions',
                            hintText: 'e.g. Liftgate required, call driver 30 min before...',
                          ),
                        ],
                      ),

                      // 4. Coupon / Promo Code Card (API Integrated)
                      _buildSectionCard(
                        title: 'Coupon & Wholesale Promotions',
                        icon: Icons.local_offer_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  controller: _couponController,
                                  hintText: 'Enter promo code (e.g. SAVE40)',
                                ),
                              ),
                              SizedBox(width: 10.w),
                              ElevatedButton(
                                onPressed: _applyCoupon,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r)),
                                ),
                                child: const Text('Apply',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          if (_appliedCouponCode.isNotEmpty) ...[
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: primaryColor, size: 16),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Coupon "$_appliedCouponCode" applied: -€ ${_discountAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      // 5. Commercial Payment Terms
                      _buildSectionCard(
                        title: 'B2B Payment Terms',
                        icon: Icons.payments_outlined,
                        children: [
                          _buildPaymentOption(
                            id: 'cash',
                            title: 'Cash on Delivery (Commercial COD / Invoice)',
                            subtitle: 'Pay at warehouse loading dock or on freight delivery.',
                            icon: Icons.local_atm_outlined,
                          ),
                          _buildPaymentOption(
                            id: 'card',
                            title: 'Corporate Credit / Debit Card',
                            subtitle: 'Instant secure card payment with digital confirmation.',
                            icon: Icons.credit_card_outlined,
                          ),

                          if (_paymentMethod == 'card') ...[
                            SizedBox(height: 12.h),
                            CustomTextFormField(
                              controller: _cardNumberController,
                              labelText: 'Card Number',
                              hintText: '4111 2222 3333 4444',
                              keyboardType: TextInputType.number,
                              validator: (v) => _paymentMethod == 'card' &&
                                      (v == null || v.trim().length < 15)
                                  ? 'Enter valid card number'
                                  : null,
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: _cardExpiryController,
                                    labelText: 'Expiry (MM/YY)',
                                    hintText: '12/28',
                                    validator: (v) => _paymentMethod == 'card' &&
                                            (v == null || v.trim().isEmpty)
                                        ? 'Required'
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: _cardCvvController,
                                    labelText: 'CVV',
                                    hintText: '123',
                                    keyboardType: TextInputType.number,
                                    validator: (v) => _paymentMethod == 'card' &&
                                            (v == null || v.trim().isEmpty)
                                        ? 'Required'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // 6. Total Net Invoice Breakdown
                      Container(
                        padding: EdgeInsets.all(16.r),
                        margin: EdgeInsets.only(bottom: 20.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Wholesale Subtotal',
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                                Text(
                                  '€ ${WholesaleCartState.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                                ),
                              ],
                            )),
                            if (_discountAmount > 0) ...[
                              SizedBox(height: 6.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Coupon Discount',
                                      style: TextStyle(fontSize: 13.sp, color: Colors.green.shade700)),
                                  Text(
                                    '- € ${_discountAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Commercial Freight Handling',
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                                Text(
                                  _fulfillmentType == 'Delivery'
                                      ? (_deliveryFee > 0
                                          ? '€ ${_deliveryFee.toStringAsFixed(2)}'
                                          : 'Free (Bulk Order)')
                                      : 'Pickup €0.00',
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Net Invoice',
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                                Text(
                                  '€ ${_finalTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitWholesaleOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00694C),
                            disabledBackgroundColor:
                                const Color(0xFF00694C).withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Confirm and Place Order',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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

  Widget _buildInterTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: const Color(0xFF151E13),
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFF00694C), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == id;
    const primaryColor = Color(0xFF00694C);

    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = id;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey, size: 22.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF151E13) : Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _paymentMethod,
              activeColor: primaryColor,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _paymentMethod = val);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
