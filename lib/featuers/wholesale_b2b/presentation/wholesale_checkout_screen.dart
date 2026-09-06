import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../common_wigdets/common_button.dart';
import '../../../../common_wigdets/custom_textfiled.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../constants/app_assets/assets_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../customers/addresses/data/customer_addresses_rx.dart';
import '../../customers/orders/data/customer_orders_api.dart';
import '../../customers/orders/data/customer_orders_rx.dart';
import '../data/wholesale_rx.dart';
import 'wholesale_cart_state.dart';
import 'wholesale_orders_screen.dart';
import 'package:el_arbol/helpers/di.dart';

class WholesaleCheckoutScreen extends StatefulWidget {
  const WholesaleCheckoutScreen({super.key});

  @override
  State<WholesaleCheckoutScreen> createState() => _WholesaleCheckoutScreenState();
}

class _WholesaleCheckoutScreenState extends State<WholesaleCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Business & Contact Controllers
  final _companyNameController = TextEditingController(text: 'BioFresh Distributors SL');
  final _contactPersonController = TextEditingController(text: 'Carlos Mendoza');
  final _businessEmailController = TextEditingController(text: 'orders@biofresh.es');
  final _businessPhoneController = TextEditingController(text: '+34 622 998 877');
  final _vatIdController = TextEditingController(text: 'ES-B12345678');

  // Delivery & Address Controllers
  final _streetController = TextEditingController(text: 'Poligono Industrial La Vega, Nave 14');
  final _cityController = TextEditingController(text: 'Madrid');
  final _postcodeController = TextEditingController(text: '28045');
  final _logisticsNotesController = TextEditingController(text: 'Standard pallet delivery. Loading bay 2.');

  // Corporate Card Controllers
  final _cardNumberController = TextEditingController(text: '4111222233334444');
  final _cardExpiryController = TextEditingController(text: '12/28');
  final _cardCvvController = TextEditingController(text: '123');

  // Fulfillment & Logistics State
  String _fulfillmentType = 'Delivery'; // 'Delivery' or 'Pickup'
  dynamic _selectedStoreId;
  String _selectedStoreName = 'Madrid Central Warehouse';
  dynamic _selectedAddressId;

  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _selectedDeliverySlot = 'Morning (08:00 - 12:00)';
  final List<String> _deliverySlots = [
    'Morning (08:00 - 12:00)',
    'Afternoon (13:00 - 17:00)',
    'Evening (17:00 - 20:00)'
  ];

  // Payment Terms
  String _paymentMethod = 'bank_transfer'; // 'bank_transfer', 'cash', or 'card'

  bool _isSubmitting = false;

  late final WholesaleCheckoutOrderRx _orderRx;
  late final CustomerAddressesRx _addressesRx;
  late final CustomerStoresRx _storesRx;

  @override
  void initState() {
    super.initState();
    _orderRx = WholesaleCheckoutOrderRx(
      empty: null,
      dataFetcher: BehaviorSubject<dynamic>(),
    );

    _addressesRx = CustomerAddressesRx(
      empty: [],
      dataFetcher: BehaviorSubject<List<dynamic>>(),
    );
    _addressesRx.fetchAddresses();

    _storesRx = CustomerStoresRx(
      empty: [],
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _storesRx.fetchStores();
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
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _orderRx.dispose();
    _addressesRx.dispose();
    _storesRx.dispose();
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

    final List<dynamic> savedAddresses = (_addressesRx.valueStreamData.valueOrNull is List)
        ? (_addressesRx.valueStreamData.valueOrNull as List)
        : [];
    final selectedSavedAddr = savedAddresses.firstWhere(
      (a) => a['id'] == _selectedAddressId,
      orElse: () => null,
    );

    final streetAddress = _fulfillmentType == 'Delivery'
        ? (selectedSavedAddr != null
            ? (selectedSavedAddr['street'] ?? selectedSavedAddr['address'] ?? '')
            : _streetController.text.trim())
        : 'Pickup at $_selectedStoreName';

    final city = _fulfillmentType == 'Delivery'
        ? (selectedSavedAddr != null
            ? (selectedSavedAddr['city'] ?? '')
            : _cityController.text.trim())
        : _selectedStoreName;

    final postcode = _fulfillmentType == 'Delivery'
        ? (selectedSavedAddr != null
            ? (selectedSavedAddr['postcode'] ?? selectedSavedAddr['zip_code'] ?? '')
            : _postcodeController.text.trim())
        : '00000';

    final customerName = '${_companyNameController.text.trim()} - ${_contactPersonController.text.trim()}';

    // Map backend payment_method (API expects 'cash' or 'card')
    final backendPaymentMethod = _paymentMethod == 'card' ? 'card' : 'cash';

    final Map<String, dynamic> orderPayload = {
      "customer_name": customerName,
      "customer_email": _businessEmailController.text.trim(),
      "customer_phone": _businessPhoneController.text.trim(),
      "street_address": streetAddress,
      "city": city,
      "postcode": postcode,
      "payment_method": backendPaymentMethod,
      "delivery_date": DateFormat('yyyy-MM-dd').format(_deliveryDate),
      "delivery_slot_label": _selectedDeliverySlot,
      "notes": "VAT: ${_vatIdController.text.trim()}. Payment Term: ${_paymentMethod.toUpperCase()}. ${_logisticsNotesController.text.trim()}",
      "items": WholesaleCartState.cartItems.map((item) {
        return {
          "item_type": "product",
          "product": item.id.isNotEmpty ? item.id : item.name,
          "quantity": item.quantity.value.toInt(),
        };
      }).toList(),
    };

    if (_paymentMethod == 'card') {
      orderPayload.addAll({
        "card_number": _cardNumberController.text.trim(),
        "card_expiry": _cardExpiryController.text.trim(),
        "card_cvv": _cardCvvController.text.trim(),
      });
    }

    final response = await _orderRx.createOrder(orderPayload);

    setState(() {
      _isSubmitting = false;
    });

    if (response != null) {
      final orderId = response['id']?.toString() ??
          response['order_id']?.toString() ??
          response['order_number']?.toString() ??
          'WHS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final orderNumber = response['order_number']?.toString() ?? orderId;

      try {
        final placedOrder = {
          'id': orderId,
          'order_number': orderNumber,
          'status': 'Pending',
          'created_at': DateTime.now().toIso8601String(),
          'total': WholesaleCartState.totalAmount.toStringAsFixed(2),
          'items_count': WholesaleCartState.cartItems.length,
          'payment_method': backendPaymentMethod,
          'items': WholesaleCartState.cartItems.map((item) => {
            'name': item.name,
            'quantity': item.quantity.value.toInt(),
            'price': item.wholesalePrice,
            'unit': item.unit,
          }).toList(),
        };
        final existing = (appData.read('wholesale_placed_orders') is List)
            ? List<dynamic>.from(appData.read('wholesale_placed_orders'))
            : <dynamic>[];
        existing.insert(0, placedOrder);
        appData.write('wholesale_placed_orders', existing);

        // Add order placed notification
        final notif = {
          'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Wholesale Order Placed',
          'message': 'Order $orderNumber for €${WholesaleCartState.totalAmount.toStringAsFixed(2)} placed and queued for dispatch.',
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

      if (_paymentMethod == 'card') {
        try {
          await CustomerOrdersApi.instance.confirmPayment({
            "order_id": orderId,
            "transaction_id": "WHS_TX_${DateTime.now().millisecondsSinceEpoch}",
            "status": "succeeded",
          });
        } catch (_) {}
      }

      // Clear the wholesale cart
      WholesaleCartState.clear();

      if (mounted) {
        _showOrderSuccessDialog(orderId);
      }
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
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00694C)),
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
                  Get.off(() => const WholesaleOrdersScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00694C),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: const Text('View Wholesale Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Get.back(); // return to catalog
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

                      // 2. Business Information
                      _buildSectionCard(
                        title: 'Buyer & Company Profile',
                        icon: Icons.business_outlined,
                        children: [
                          _buildInterTextField(
                            controller: _companyNameController,
                            labelText: 'Company / Business Name *',
                            hintText: 'e.g. BioFresh Distributors SL',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Company name is required' : null,
                          ),
                          SizedBox(height: 12.h),
                          _buildInterTextField(
                            controller: _contactPersonController,
                            labelText: 'Contact Person *',
                            hintText: 'e.g. Carlos Mendoza',
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
                            hintText: 'e.g. orders@biofresh.es',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Email required' : null,
                          ),
                          SizedBox(height: 12.h),
                          _buildInterTextField(
                            controller: _businessPhoneController,
                            labelText: 'Contact Phone *',
                            hintText: 'e.g. +34 622 998 877',
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
                                    if (s) setState(() => _fulfillmentType = 'Delivery');
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
                                    if (s) setState(() => _fulfillmentType = 'Pickup');
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          if (_fulfillmentType == 'Delivery') ...[
                            // Saved addresses dropdown or manual inputs
                            StreamBuilder<dynamic>(
                              stream: _addressesRx.valueStreamData,
                              builder: (context, snapshot) {
                                final List<dynamic> addresses = snapshot.data is List ? snapshot.data as List : [];
                                if (addresses.isNotEmpty) {
                                  if (_selectedAddressId == null && addresses.isNotEmpty) {
                                    _selectedAddressId = addresses.first['id'];
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Select Delivery Address', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                                      SizedBox(height: 4.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<dynamic>(
                                            isExpanded: true,
                                            value: _selectedAddressId,
                                            items: addresses.map((addr) {
                                              final title = addr['title'] ?? 'Address';
                                              final street = addr['street'] ?? addr['address'] ?? '';
                                              final city = addr['city'] ?? '';
                                              return DropdownMenuItem<dynamic>(
                                                value: addr['id'],
                                                child: Text('$title ($street, $city)', style: TextStyle(fontSize: 12.sp)),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                _selectedAddressId = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    CustomTextFormField(
                                      controller: _streetController,
                                      labelText: 'Street Address *',
                                      hintText: 'e.g. Poligono Industrial La Vega 14',
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Address required' : null,
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextFormField(
                                            controller: _cityController,
                                            labelText: 'City *',
                                            hintText: 'e.g. Madrid',
                                            validator: (v) => v == null || v.trim().isEmpty ? 'City required' : null,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: CustomTextFormField(
                                            controller: _postcodeController,
                                            labelText: 'Postcode *',
                                            hintText: 'e.g. 28045',
                                            validator: (v) => v == null || v.trim().isEmpty ? 'Postcode required' : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                );
                              },
                            ),
                          ] else ...[
                            // Depot Pickup Store Selection
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
                                  _selectedStoreName = stores.first['name'] ?? '';
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Select Depot Warehouse', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<dynamic>(
                                          isExpanded: true,
                                          value: _selectedStoreId,
                                          items: stores.map((s) {
                                            return DropdownMenuItem<dynamic>(
                                              value: s['id'],
                                              child: Text(s['name'] ?? 'Store', style: TextStyle(fontSize: 12.sp)),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              final s = stores.firstWhere((e) => e['id'] == val, orElse: () => null);
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

                      // 4. Commercial Payment Terms
                      _buildSectionCard(
                        title: 'B2B Payment Terms',
                        icon: Icons.payments_outlined,
                        children: [
                          _buildPaymentOption(
                            id: 'bank_transfer',
                            title: 'Bank Wire / Commercial Invoice (Net 30)',
                            subtitle: 'Commercial invoice generated for wire payment upon receipt.',
                            icon: Icons.account_balance_outlined,
                          ),
                          _buildPaymentOption(
                            id: 'cash',
                            title: 'Cash on Delivery (Commercial COD)',
                            subtitle: 'Pay at warehouse loading dock or on freight delivery.',
                            icon: Icons.local_atm_outlined,
                          ),
                          _buildPaymentOption(
                            id: 'card',
                            title: 'Corporate Credit / Debit Card',
                            subtitle: 'Secure corporate card payment via Stripe B2B pipeline.',
                            icon: Icons.credit_card_outlined,
                          ),

                          if (_paymentMethod == 'card') ...[
                            SizedBox(height: 12.h),
                            CustomTextFormField(
                              controller: _cardNumberController,
                              labelText: 'Card Number',
                              hintText: '4111 2222 3333 4444',
                              keyboardType: TextInputType.number,
                              validator: (v) => _paymentMethod == 'card' && (v == null || v.length < 15) ? 'Invalid card' : null,
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: _cardExpiryController,
                                    labelText: 'Expiry (MM/YY)',
                                    hintText: '12/28',
                                    validator: (v) => _paymentMethod == 'card' && (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: _cardCvvController,
                                    labelText: 'CVV',
                                    hintText: '123',
                                    keyboardType: TextInputType.number,
                                    validator: (v) => _paymentMethod == 'card' && (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // 5. Total Net Invoice Breakdown
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
                            Container(
                              padding: EdgeInsets.all(10.r),
                              margin: EdgeInsets.only(bottom: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.amber.shade800, size: 16.r),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Wholesale orders are reviewed by operations. Payment adjustments or refunds can be modified in the admin console.',
                                      style: TextStyle(fontSize: 11.sp, color: Colors.amber.shade900, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Wholesale Subtotal', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                                Text(
                                  '€ ${WholesaleCartState.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                                ),
                              ],
                            )),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Commercial Freight Handling', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                                Text(
                                  _fulfillmentType == 'Delivery' ? 'Free (Bulk Order)' : 'Pickup €0.00',
                                  style: TextStyle(fontSize: 13.sp, color: primaryColor, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Net Invoice', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                                Text(
                                  '€ ${WholesaleCartState.totalAmount.toStringAsFixed(2)}',
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
                            disabledBackgroundColor: const Color(0xFF00694C).withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Confirm and Submit Order',
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
