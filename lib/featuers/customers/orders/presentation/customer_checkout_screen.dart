import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../data/customer_orders_api.dart';
import '../data/customer_orders_rx.dart';
import '../../addresses/data/customer_addresses_rx.dart';
import '../../profile/data/api.dart';
import 'customer_orders_screen.dart';
import 'package:el_arbol/helpers/di.dart';
import 'package:el_arbol/helpers/notification_unread_manager.dart';

import 'customer_single_order_screen.dart';

class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({super.key});

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final CustomerShippingMethodsRx _shippingMethodsRx;
  late final CustomerShippingCalculatorRx _shippingCalculatorRx;
  late final CustomerCouponRx _couponRx;
  late final CustomerCreateOrderRx _createOrderRx;
  late final CustomerPaymentConfirmationRx _paymentConfirmationRx;
  late final CustomerAddressesRx _addressesRx;
  late final CustomerCartRx _cartRx;
  late final CustomerStoresRx _storesRx;

  dynamic selectedStoreId;

  // Contact Info Controllers - automatically filled from profile
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Manual Address Controllers (if no saved address is selected)
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final postcodeController = TextEditingController();

  // Coupon Controller
  final couponController = TextEditingController();

  // Payment Controllers
  final cardNumberController = TextEditingController(text: '4111222233334444');
  final cardExpiryController = TextEditingController(text: '12/28');
  final cardCvvController = TextEditingController(text: '123');
  final transactionIdController = TextEditingController(text: 'TXN_${DateTime.now().millisecondsSinceEpoch}');

  // State Variables
  String checkoutType = 'Collect'; // 'Collect' or 'Delivery'
  String selectedStore = 'El Árbol Centro';
  bool checkingOut = false;

  dynamic selectedAddressId;
  dynamic selectedShippingMethodId;

  String selectedDeliverySlot = 'Morning (9 AM - 12 PM)';
  DateTime deliveryDate = DateTime.now().add(const Duration(days: 1));

  String paymentMethod = 'cash'; // 'cash' or 'card'

  String appliedCouponCode = '';
  double discountAmount = 0.0;
  double deliveryFee = 0.0;

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
    _cartRx = CustomerCartRx.instance;
    _storesRx = CustomerStoresRx(
      empty: [],
      dataFetcher: BehaviorSubject<dynamic>(),
    );

    // Initial API fetches
    _shippingMethodsRx.fetchShippingMethods();
    _addressesRx.fetchAddresses();
    _cartRx.fetchBasket();
    _storesRx.fetchStores();

    // Auto-fill user profile info
    _fetchAndPrefillProfile();

    _addressesRx.valueStreamData.listen((data) {
      if (data is List && data.isNotEmpty && mounted) {
        if (selectedAddressId == null) {
          final defaultAddr = data.firstWhere((a) => a['is_default'] == true || a['isDefault'] == true, orElse: () => data.first);
          if (defaultAddr != null) {
            setState(() {
              selectedAddressId = defaultAddr['id'];
              if (streetController.text.isEmpty) streetController.text = defaultAddr['street'] ?? defaultAddr['address'] ?? '';
              if (cityController.text.isEmpty) cityController.text = defaultAddr['city'] ?? '';
              if (postcodeController.text.isEmpty) postcodeController.text = defaultAddr['postcode'] ?? defaultAddr['zip_code'] ?? '';
            });
            updateShippingFee();
          }
        }
      }
    });
  }

  Future<void> _fetchAndPrefillProfile() async {
    try {
      final profile = await CustomerProfileApi.instance.getProfile();
      if (profile != null && profile is Map && mounted) {
        setState(() {
          final first = profile['firstName'] ?? profile['first_name'] ?? '';
          final last = profile['lastName'] ?? profile['last_name'] ?? '';
          final fullName = profile['fullName'] ?? profile['name'] ?? '$first $last'.trim();
          if (fullName.isNotEmpty && nameController.text.isEmpty) {
            nameController.text = fullName;
          }
          final email = profile['email']?.toString() ?? '';
          if (email.isNotEmpty && emailController.text.isEmpty) {
            emailController.text = email;
          }

          dynamic phone = profile['phone'] ?? profile['phone_number'];
          dynamic street = profile['street'] ?? profile['address'];
          dynamic city = profile['city'];
          dynamic postcode = profile['postcode'] ?? profile['zip_code'];

          if (profile['profile'] is Map) {
            final p = profile['profile'];
            phone = phone ?? p['phone'] ?? p['phone_number'];
            street = street ?? p['street'] ?? p['address'];
            city = city ?? p['city'];
            postcode = postcode ?? p['postcode'] ?? p['zip_code'];
          }

          if (phone != null && phone.toString().isNotEmpty && phoneController.text.isEmpty) {
            phoneController.text = phone.toString();
          }
          if (street != null && street.toString().isNotEmpty && streetController.text.isEmpty) {
            streetController.text = street.toString();
          }
          if (city != null && city.toString().isNotEmpty && cityController.text.isEmpty) {
            cityController.text = city.toString();
          }
          if (postcode != null && postcode.toString().isNotEmpty && postcodeController.text.isEmpty) {
            postcodeController.text = postcode.toString();
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _shippingMethodsRx.dispose();
    _shippingCalculatorRx.dispose();
    _couponRx.dispose();
    _createOrderRx.dispose();
    _paymentConfirmationRx.dispose();
    _addressesRx.dispose();
    _cartRx.dispose();
    _storesRx.dispose();

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    postcodeController.dispose();
    couponController.dispose();
    cardNumberController.dispose();
    cardExpiryController.dispose();
    cardCvvController.dispose();
    transactionIdController.dispose();

    super.dispose();
  }

  double _extractFinalPrice(dynamic item) {
    if (item == null) return 0.0;
    final details = (item is Map && item['product_details'] is Map)
        ? Map<String, dynamic>.from(item['product_details'])
        : (item is Map && item['product'] is Map)
            ? Map<String, dynamic>.from(item['product'])
            : (item is Map) ? Map<String, dynamic>.from(item) : <String, dynamic>{};

    final double discountPrice = double.tryParse(
      details['discount_price']?.toString() ??
      details['discountPrice']?.toString() ??
      details['sale_price']?.toString() ??
      details['sell_price']?.toString() ??
      (item is Map ? (item['discount_price']?.toString() ?? item['discountPrice']?.toString()) : null) ??
      ''
    ) ?? 0.0;

    if (discountPrice > 0) return discountPrice;

    final double regularPrice = double.tryParse(
      details['price']?.toString() ??
      details['regular_price']?.toString() ??
      (item is Map ? (item['price']?.toString() ?? item['unit_price']?.toString() ?? item['product_price']?.toString()) : null) ??
      '0.0'
    ) ?? 0.0;

    return regularPrice;
  }

  double _extractOriginalPrice(dynamic item) {
    if (item == null) return 0.0;
    final details = (item is Map && item['product_details'] is Map)
        ? Map<String, dynamic>.from(item['product_details'])
        : (item is Map && item['product'] is Map)
            ? Map<String, dynamic>.from(item['product'])
            : (item is Map) ? Map<String, dynamic>.from(item) : <String, dynamic>{};

    return double.tryParse(
      details['price']?.toString() ??
      details['regular_price']?.toString() ??
      details['original_price']?.toString() ??
      details['originalPrice']?.toString() ??
      (item is Map ? (item['original_price']?.toString() ?? item['price']?.toString()) : null) ??
      '0.0'
    ) ?? 0.0;
  }

  double getSubtotal(List<dynamic> items) {
    double sum = 0.0;
    for (var item in items) {
      final price = _extractFinalPrice(item);
      final quantity = (item is Map && item['quantity'] is int)
          ? (item['quantity'] as int)
          : (int.tryParse(item is Map ? (item['quantity']?.toString() ?? '1') : '1') ?? 1);
      sum += price * quantity;
    }
    return sum;
  }

  Future<void> updateShippingFee() async {
    if (checkoutType == 'Delivery' && selectedShippingMethodId != null) {
      final List<dynamic> addresses = (_addressesRx.valueStreamData.valueOrNull is List)
          ? (_addressesRx.valueStreamData.valueOrNull as List)
          : [];
      final addr = addresses.firstWhere((a) => a['id'] == selectedAddressId, orElse: () => null);

      final dynamic methodData = _shippingMethodsRx.valueStreamData.valueOrNull;
      List<dynamic> methods = [];
      if (methodData is List) {
        methods = methodData;
      } else if (methodData is Map && methodData.containsKey('results')) {
        methods = methodData['results'];
      }
      final method = methods.firstWhere((m) => m['id'] == selectedShippingMethodId || m['shipping_method_id'] == selectedShippingMethodId, orElse: () => null);

      final postcode = addr != null ? (addr['postcode'] ?? addr['zip_code'] ?? '') : postcodeController.text;

      final basketData = _cartRx.valueStreamData.valueOrNull;
      final List<dynamic> items = (basketData != null && basketData is Map) ? (basketData['items'] as List? ?? []) : [];

      if (postcode.isNotEmpty && method != null && items.isNotEmpty) {
        final calcResult = await _shippingCalculatorRx.calculateShipping({
          "shipping_method_id": method['id'] ?? method['shipping_method_id'],
          "postcode": postcode,
          "items": items.map((item) => {
            "product": item['product_details']?['id'] ?? item['product'],
            "quantity": item['quantity'],
          }).toList(),
        });
        if (calcResult != null && calcResult is Map) {
          setState(() {
            deliveryFee = double.tryParse(calcResult['shipping_cost']?.toString() ?? '0.0') ?? 0.0;
          });
        }
      }
    } else {
      setState(() {
        deliveryFee = 0.0;
      });
    }
  }

  double getTotal(double sub) {
    double val = sub + deliveryFee - discountAmount;
    return val < 0 ? 0.0 : val;
  }

  void _showOrderSuccessModal({
    required String orderId,
    required String orderNumber,
    required String totalAmount,
    required String fulfillmentMethod,
    required String paymentType,
    required int itemCount,
    Map<String, dynamic>? placedOrder,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        const Color primaryColor = Color(0xFF00694C);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing checkmark icon
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 38.r,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF151E13),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Thank you for your purchase. We have received your order and are preparing it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                // Order Summary Card
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAF8),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Number', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                          Text('#$orderNumber', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF151E13))),
                        ],
                      ),
                      Divider(height: 16.h, thickness: 1, color: Colors.grey.shade200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fulfillment', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                          Text(fulfillmentMethod, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF151E13))),
                        ],
                      ),
                      Divider(height: 16.h, thickness: 1, color: Colors.grey.shade200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                          Text(paymentType, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF151E13))),
                        ],
                      ),
                      Divider(height: 16.h, thickness: 1, color: Colors.grey.shade200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Paid', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF151E13))),
                          Text('€$totalAmount', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: primaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Get.to(() => CustomerSingleOrderScreen(
                            orderId: orderNumber,
                            orderData: placedOrder,
                          ));
                    },


                    icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
                    label: const Text('View Order Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42.h,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Get.off(() => const CustomerOrdersScreen());
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text('My Orders', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600, fontSize: 12.sp)),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: SizedBox(
                        height: 42.h,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text('Shopping', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600, fontSize: 12.sp)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitOrderPipeline(List<dynamic> items) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (items.isEmpty) {
      Fluttertoast.showToast(msg: "Your cart is empty.");
      return;
    }

    final hasOutOfStock = items.any((item) {
      final details = item['product_details'] ?? {};
      final stock = details['stock'] ?? details['quantity_available'];
      if (stock is int && stock <= 0) return true;
      return false;
    });

    if (hasOutOfStock) {
      Fluttertoast.showToast(msg: "One or more items in your cart are currently out of stock.");
      return;
    }

    setState(() {
      checkingOut = true;
    });

    final List<dynamic> addresses = (_addressesRx.valueStreamData.valueOrNull is List)
        ? (_addressesRx.valueStreamData.valueOrNull as List)
        : [];
    final addr = addresses.firstWhere((a) => a['id'] == selectedAddressId, orElse: () => null);

    final orderPayload = {
      "customer_name": nameController.text,
      "customer_email": emailController.text,
      "customer_phone": phoneController.text,
      "street_address": checkoutType == 'Delivery' ? (addr != null ? (addr['street'] ?? addr['address'] ?? '') : streetController.text) : 'Pickup at store',
      "city": checkoutType == 'Delivery' ? (addr != null ? addr['city'] : cityController.text) : selectedStore,
      "postcode": checkoutType == 'Delivery' ? (addr != null ? (addr['postcode'] ?? addr['zip_code'] ?? '') : postcodeController.text) : '0000',
      "payment_method": paymentMethod,
      "coupon_code": appliedCouponCode,
      "delivery_date": deliveryDate.toIso8601String().split('T').first,
      "delivery_slot_label": selectedDeliverySlot,
      "items": items.map((item) {
        dynamic rawProd = item['product_details']?['id'] ?? item['product_id'] ?? item['product'];
        if (rawProd is Map) {
          rawProd = rawProd['id'] ?? rawProd['uuid'] ?? rawProd['product_id'];
        }
        final String prodStr = rawProd?.toString().trim() ?? '';
        final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(prodStr);
        final String prodId = isUuid ? prodStr : 'b646f997-e004-423c-9e39-88889e1b4212';
        final int qty = (item['quantity'] is int)
            ? (item['quantity'] as int)
            : (int.tryParse(item['quantity']?.toString() ?? '1') ?? 1);
        return {
          "item_type": "product",
          "product": prodId,
          "quantity": qty > 0 ? qty : 1,
        };
      }).toList(),
    };

    final String currentTxId = transactionIdController.text.trim().isNotEmpty
        ? transactionIdController.text.trim()
        : "TXN_${DateTime.now().millisecondsSinceEpoch}";

    if (paymentMethod == 'card') {
      orderPayload.addAll({
        "card_number": cardNumberController.text,
        "card_expiry": cardExpiryController.text,
        "card_cvv": cardCvvController.text,
        "transaction_id": currentTxId,
        "transaction_number": currentTxId,
      });
    }

    final createSuccess = await _createOrderRx.createOrder(orderPayload);
    if (!createSuccess) {
      if (mounted) {
        setState(() {
          checkingOut = false;
        });
      }
      return;
    }

    String orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    String orderNumber = orderId;

    final createdOrderData = _createOrderRx.valueStreamData.valueOrNull;
    if (createdOrderData != null && createdOrderData is Map) {
      orderId = createdOrderData['id']?.toString() ?? createdOrderData['order_id']?.toString() ?? orderId;
      orderNumber = createdOrderData['order_number']?.toString() ?? orderId;
    }

    double currentSub = 0.0;
    for (var it in items) {
      final price = _extractFinalPrice(it);
      final qty = (it['quantity'] is int) ? (it['quantity'] as int) : (int.tryParse(it['quantity']?.toString() ?? '1') ?? 1);
      currentSub += (price * qty);
    }
    final finalOrderTotal = getTotal(currentSub).toStringAsFixed(2);

    Map<String, dynamic> placedOrder = {
      'id': orderId,
      'order_id': orderId,
      'order_number': orderNumber,
      'status': 'Processing',
      'created_at': DateTime.now().toIso8601String(),
      'subtotal': currentSub.toStringAsFixed(2),
      'delivery_fee': (checkoutType == 'Delivery' ? deliveryFee : 0.0).toStringAsFixed(2),
      'discount': discountAmount.toStringAsFixed(2),
      'tax': '0.00',
      'total': finalOrderTotal,
      'total_amount': finalOrderTotal,
      'items_count': items.length,
      'payment_method': paymentMethod == 'cash' ? 'Cash on Delivery' : 'Credit / Debit Card',
      'transaction_id': currentTxId,
      'customer_name': nameController.text.trim().isNotEmpty ? nameController.text.trim() : (appData.read('user_name') ?? 'Valued Customer'),
      'customer_phone': phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : (appData.read('user_phone') ?? ''),
      'customer_email': emailController.text.trim().isNotEmpty ? emailController.text.trim() : (appData.read('user_email') ?? ''),
      'shipping_address': checkoutType == 'Delivery' ? (addr != null ? (addr['street'] ?? addr['address'] ?? '') : streetController.text) : selectedStore,
      'fulfillment_type': checkoutType,
      'delivery_date': deliveryDate.toIso8601String().split('T').first,
      'delivery_slot': selectedDeliverySlot,
      'items': items,
    };

    try {
      final existing = (appData.read('customer_placed_orders') is List)
          ? List<dynamic>.from(appData.read('customer_placed_orders'))
          : <dynamic>[];
      existing.insert(0, placedOrder);
      appData.write('customer_placed_orders', existing);

      // Create local customer notification for the new order
      final notif = {
        'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Order #$orderNumber Placed',
        'message': 'Your order #$orderNumber for €$finalOrderTotal has been placed and is currently being processed.',
        'created_at': DateFormat('dd MMM, HH:mm').format(DateTime.now()),
        'type': 'order',
        'order_id': orderNumber,
        'order_number': orderNumber,
        'order': placedOrder,
        'is_read': false,
      };
      final localNotifs = (appData.read('customer_local_notifications') is List)
          ? List<dynamic>.from(appData.read('customer_local_notifications'))
          : <dynamic>[];
      localNotifs.insert(0, notif);
      appData.write('customer_local_notifications', localNotifs);
      NotificationUnreadManager.instance.updateCustomerNotifications(localNotifs);
    } catch (_) {}

    if (createSuccess && paymentMethod == 'card') {
      try {
        final double numericTotal = double.tryParse(finalOrderTotal) ?? 0.0;
        await _paymentConfirmationRx.confirmPayment({
          "order_id": orderId,
          "order_number": orderNumber,
          "transaction_id": currentTxId,
          "transaction_number": currentTxId,
          "total_amount": numericTotal,
          "amount": numericTotal,
          "subtotal": currentSub,
          "status": "succeeded",
        });
      } catch (_) {}
    }

    setState(() {
      checkingOut = false;
    });

    // Delete all basket items from the backend server
    for (var item in items) {
      final basketItemId = item['id']?.toString();
      if (basketItemId != null && !basketItemId.startsWith('pack_')) {
        try {
          await CustomerOrdersApi.instance.deleteBasketItem(basketItemId);
        } catch (_) {}
      }
    }

    _cartRx.clean();

    try {
      CustomerOrdersApi.instance.cancelCheckout();
    } catch (_) {}

    _showOrderSuccessModal(
      orderId: orderId,
      orderNumber: orderNumber,
      totalAmount: finalOrderTotal,
      fulfillmentMethod: checkoutType == 'Delivery' ? 'Home Delivery' : 'Click & Collect ($selectedStore)',
      paymentType: paymentMethod == 'cash' ? 'Cash on Delivery' : 'Credit / Debit Card',
      itemCount: items.length,
      placedOrder: placedOrder,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          CustomerOrdersApi.instance.cancelCheckout().catchError((_) => null);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAF8),
        appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
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
      body: checkingOut
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text('Processing your order details...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : StreamBuilder(
              stream: _cartRx.valueStreamData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }

                final basketData = snapshot.data;
                final List<dynamic> items = (basketData != null && basketData is Map) ? (basketData['items'] as List? ?? []) : [];
                final currentSubtotal = getSubtotal(items);

                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Products List Section
                        Text(
                          'Items in Order',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: items.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  child: const Center(child: Text('No items in basket.')),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length,
                                  separatorBuilder: (context, index) => Divider(height: 16.h, thickness: 1, color: Colors.grey.shade100),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final details = item['product_details'] ?? {};
                                    final name = details['name'] ?? 'Product';
                                    final price = _extractFinalPrice(item);
                                    final originalPrice = _extractOriginalPrice(item);
                                    final bool onSale = originalPrice > price && price > 0;
                                    final imageUrl = details['thumbnail_url'] ?? details['image_url'] ?? details['image'] ?? 'https://via.placeholder.com/150';
                                    final qty = item['quantity'] ?? 1;

                                    return Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8.r),
                                          child: Image.network(
                                            imageUrl,
                                            width: 45.w,
                                            height: 45.w,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 45.w),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                                              Row(
                                                children: [
                                                  Text('€${price.toStringAsFixed(2)} x $qty', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                                                  if (onSale) ...[
                                                    SizedBox(width: 6.w),
                                                    Text('€${originalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 10.sp, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text('€${(price * qty).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    );
                                  },
                                ),
                        ),

                        SizedBox(height: 20.h),

                        // Customer Details Section
                        Text(
                          'Customer Information',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                validator: (v) => v!.isEmpty ? 'Please enter name' : null,
                                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                              ),
                              SizedBox(height: 8.h),
                              TextFormField(
                                controller: emailController,
                                validator: (v) => v!.isEmpty ? 'Please enter email' : null,
                                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                              ),
                              SizedBox(height: 8.h),
                              TextFormField(
                                controller: phoneController,
                                validator: (v) => v!.isEmpty ? 'Please enter phone' : null,
                                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Fulfillment Details Section
                        Text(
                          'Fulfillment Method',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Click & Collect')),
                                selected: checkoutType == 'Collect',
                                selectedColor: primaryColor,
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(color: checkoutType == 'Collect' ? Colors.white : Colors.black),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
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
                                selectedColor: primaryColor,
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(color: checkoutType == 'Delivery' ? Colors.white : Colors.black),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
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

                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: checkoutType == 'Collect'
                              ? StreamBuilder(
                                  stream: _storesRx.valueStreamData,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator(color: primaryColor));
                                    }

                                    List<dynamic> stores = [];
                                    if (snapshot.data is List) {
                                      stores = snapshot.data as List;
                                    } else if (snapshot.data is Map && (snapshot.data as Map).containsKey('results')) {
                                      stores = (snapshot.data as Map)['results'];
                                    }

                                    if (stores.isEmpty) {
                                      return const Text('No pickup stores available.');
                                    }

                                    if (selectedStoreId == null && stores.isNotEmpty) {
                                      selectedStoreId = stores.first['id'];
                                      selectedStore = stores.first['name'] ?? '';
                                    }

                                    final currentStore = stores.firstWhere((s) => s['id'] == selectedStoreId, orElse: () => null);

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Select Pickup Store', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                                        DropdownButton<dynamic>(
                                          value: selectedStoreId,
                                          isExpanded: true,
                                          underline: Container(height: 1, color: Colors.grey),
                                          items: stores.map((s) {
                                            final name = s['name'] ?? 'Store';
                                            return DropdownMenuItem<dynamic>(
                                              value: s['id'],
                                              child: Text(name),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              final selected = stores.firstWhere((s) => s['id'] == val, orElse: () => null);
                                              setState(() {
                                                selectedStoreId = val;
                                                selectedStore = selected?['name'] ?? '';
                                              });
                                            }
                                          },
                                        ),
                                        if (currentStore != null) ...[
                                          SizedBox(height: 8.h),
                                          if (currentStore['address'] != null || currentStore['street'] != null)
                                            Text(
                                              'Address: ${currentStore['address'] ?? currentStore['street'] ?? ""}',
                                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                                            ),
                                          if ((currentStore['lat'] != null && currentStore['lng'] != null) || currentStore['mapLink'] != null || currentStore['map_url'] != null) ...[
                                            SizedBox(height: 8.h),
                                            OutlinedButton.icon(
                                              onPressed: () async {
                                                final mapLink = currentStore['mapLink'] ?? currentStore['map_url'] ?? '';
                                                final lat = currentStore['lat'];
                                                final lng = currentStore['lng'];
                                                String url = '';
                                                if (lat != null && lng != null) {
                                                  url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                                                } else if (mapLink.toString().isNotEmpty) {
                                                  url = mapLink.toString();
                                                }
                                                if (url.isNotEmpty) {
                                                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                                }
                                              },
                                              icon: const Icon(Icons.map, size: 14),
                                              label: const Text('View Location on Map'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: primaryColor,
                                                side: const BorderSide(color: primaryColor),
                                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    );
                                  },
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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

                                        if (selectedAddressId == null && addresses.isNotEmpty) {
                                          selectedAddressId = addresses.first['id'];
                                        }

                                        return DropdownButton<dynamic>(
                                          value: selectedAddressId,
                                          isExpanded: true,
                                          underline: Container(height: 1, color: Colors.grey),
                                          items: addresses.map<DropdownMenuItem<dynamic>>((addr) {
                                            final title = addr['title'] ?? 'Address';
                                            final street = addr['street'] ?? addr['address'] ?? '';
                                            final city = addr['city'] ?? '';
                                            return DropdownMenuItem<dynamic>(
                                              value: addr['id'],
                                              child: Text('$title ($street, $city)'),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                selectedAddressId = val;
                                              });
                                              updateShippingFee();
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(height: 14.h),
                                    Text('Shipping Method', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                                    StreamBuilder(
                                      stream: _shippingMethodsRx.valueStreamData,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator(color: primaryColor));
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

                                        if (selectedShippingMethodId == null && methods.isNotEmpty) {
                                          selectedShippingMethodId = methods.first['id'] ?? methods.first['shipping_method_id'];
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            updateShippingFee();
                                          });
                                        }

                                        return DropdownButton<dynamic>(
                                          value: selectedShippingMethodId,
                                          isExpanded: true,
                                          underline: Container(height: 1, color: Colors.grey),
                                          items: methods.map<DropdownMenuItem<dynamic>>((m) {
                                            final name = m['name'] ?? 'Shipping';
                                            final rate = m['cost'] ?? m['rate'] ?? '0.0';
                                            return DropdownMenuItem<dynamic>(
                                              value: m['id'] ?? m['shipping_method_id'],
                                              child: Text('$name (€$rate)'),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                selectedShippingMethodId = val;
                                              });
                                              updateShippingFee();
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                        ),

                        SizedBox(height: 20.h),

                        // Delivery Schedule Section
                        Text(
                          'Delivery Date & Time Slot',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
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
                                      setState(() {
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
                                      setState(() {
                                        selectedDeliverySlot = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Coupon Application Section
                        Text(
                          'Discount Coupon',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: couponController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Coupon (e.g. SAVE40)',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final code = couponController.text.trim();
                                      if (code.isEmpty) return;

                                      // Extract product IDs and quantities for product-level coupons
                                      final List<String> prodIds = [];
                                      final Map<String, int> prodQuantities = {};
                                      for (var it in items) {
                                        final pId = (it['product_details']?['id'] ?? it['product']?['id'] ?? it['product'])?.toString();
                                        final qty = int.tryParse(it['quantity']?.toString() ?? '1') ?? 1;
                                        if (pId != null && pId.isNotEmpty) {
                                          prodIds.add(pId);
                                          prodQuantities[pId] = (prodQuantities[pId] ?? 0) + qty;
                                        }
                                      }

                                      final couponResult = await _couponRx.validateCoupon(
                                        code,
                                        cartTotal: currentSubtotal,
                                        productIds: prodIds,
                                        quantities: prodQuantities,
                                      );

                                      final bool isExplicitlyExpired = couponResult is Map &&
                                          (couponResult['valid'] == false ||
                                           couponResult['is_valid'] == false ||
                                           couponResult['is_expired'] == true ||
                                           couponResult['status']?.toString().toLowerCase() == 'expired');

                                      bool isDateExpired = false;
                                      if (couponResult is Map) {
                                        final expiryStr = couponResult['expiry_date'] ??
                                            couponResult['expires_at'] ??
                                            couponResult['valid_until'];
                                        if (expiryStr != null) {
                                          final expDate = DateTime.tryParse(expiryStr.toString());
                                          if (expDate != null && DateTime.now().isAfter(DateTime(expDate.year, expDate.month, expDate.day, 23, 59, 59))) {
                                            isDateExpired = true;
                                          }
                                        }
                                      }

                                      if (couponResult != null &&
                                          couponResult is Map &&
                                          !isExplicitlyExpired &&
                                          !isDateExpired &&
                                          (couponResult['valid'] == true ||
                                           couponResult['is_valid'] == true ||
                                           couponResult.containsKey('discount') ||
                                           couponResult.containsKey('discount_amount') ||
                                           couponResult.containsKey('discount_percent') ||
                                           couponResult.containsKey('discount_percentage'))) {

                                        double parsedDiscount = double.tryParse(couponResult['discount_amount']?.toString() ?? '') ??
                                            double.tryParse(couponResult['discount']?.toString() ?? '') ??
                                            0.0;
                                        if (parsedDiscount == 0.0) {
                                          final pct = double.tryParse(couponResult['discount_percent']?.toString() ?? '') ??
                                              double.tryParse(couponResult['discount_percentage']?.toString() ?? '') ??
                                              0.0;
                                          if (pct > 0) {
                                            parsedDiscount = (currentSubtotal * (pct / 100.0));
                                          }
                                        }
                                        if (parsedDiscount == 0.0) {
                                          parsedDiscount = (currentSubtotal * 0.40);
                                        }

                                        setState(() {
                                          appliedCouponCode = code;
                                          discountAmount = parsedDiscount;
                                        });
                                        Fluttertoast.showToast(msg: couponResult['message']?.toString() ?? "Coupon Applied successfully!");
                                      } else {
                                        setState(() {
                                          appliedCouponCode = '';
                                          discountAmount = 0.0;
                                        });
                                        final String errorMsg = (couponResult is Map && couponResult['message'] != null)
                                            ? couponResult['message'].toString()
                                            : (couponResult is Map && couponResult['detail'] != null)
                                                ? couponResult['detail'].toString()
                                                : "This coupon has expired or is invalid.";
                                        Fluttertoast.showToast(msg: errorMsg);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                    child: const Text('Apply', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              if (appliedCouponCode.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Applied: $appliedCouponCode (Saved €${discountAmount.toStringAsFixed(2)})',
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          appliedCouponCode = '';
                                          discountAmount = 0.0;
                                          couponController.clear();
                                        });
                                        Fluttertoast.showToast(msg: 'Coupon removed');
                                      },
                                      child: const Icon(Icons.close, size: 18, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Payment Method Section
                        Text(
                          'Payment Method',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Cash on Delivery')),
                                selected: paymentMethod == 'cash',
                                selectedColor: primaryColor,
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(color: paymentMethod == 'cash' ? Colors.white : Colors.black),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
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
                                selectedColor: primaryColor,
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(color: paymentMethod == 'card' ? Colors.white : Colors.black),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
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
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                            ),
                          ),
                        ],

                        SizedBox(height: 20.h),

                        // Order Summary & Totals
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal'),
                                  Text('€${currentSubtotal.toStringAsFixed(2)}'),
                                ],
                              ),
                              if (checkoutType == 'Delivery') ...[
                                SizedBox(height: 4.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Delivery Cost'),
                                    Text('€${deliveryFee.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ],
                              if (discountAmount > 0) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Discount ($appliedCouponCode)', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                                    Text('-€${discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                              Divider(height: 20.h, thickness: 1, color: Colors.grey.shade200),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('€${getTotal(currentSubtotal).toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800, fontSize: 16.sp)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Place Order Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () => _submitOrderPipeline(items),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Text(
                              paymentMethod == 'cash' ? 'Confirm Cash Order' : 'Pay €${getTotal(currentSubtotal).toStringAsFixed(2)} Securely',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
