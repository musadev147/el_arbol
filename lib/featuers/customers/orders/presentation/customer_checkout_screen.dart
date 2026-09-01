import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/customer_orders_api.dart';
import '../data/customer_orders_rx.dart';
import '../../addresses/data/customer_addresses_rx.dart';

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

  // Contact Info Controllers
  final nameController = TextEditingController(text: 'John Doe');
  final emailController = TextEditingController(text: 'john@example.com');
  final phoneController = TextEditingController(text: '+34622334455');

  // Manual Address Controllers (if no saved address is selected)
  final streetController = TextEditingController(text: '123 Main Street');
  final cityController = TextEditingController(text: 'Madrid');
  final postcodeController = TextEditingController(text: '28001');

  // Coupon Controller
  final couponController = TextEditingController();

  // Payment Controllers
  final cardNumberController = TextEditingController(text: '4111222233334444');
  final cardExpiryController = TextEditingController(text: '12/28');
  final cardCvvController = TextEditingController(text: '123');

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
    _cartRx = CustomerCartRx(
      empty: {},
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _storesRx = CustomerStoresRx(
      empty: [],
      dataFetcher: BehaviorSubject<dynamic>(),
    );

    // Initial API fetches
    _shippingMethodsRx.fetchShippingMethods();
    _addressesRx.fetchAddresses();
    _cartRx.fetchBasket();
    _storesRx.fetchStores();
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

    super.dispose();
  }

  double getSubtotal(List<dynamic> items) {
    double sum = 0.0;
    for (var item in items) {
      final details = item['product_details'] ?? {};
      final price = double.tryParse(details['price']?.toString() ?? '0.0') ?? 0.0;
      final quantity = item['quantity'] as int? ?? 1;
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

  Future<void> _submitOrderPipeline(List<dynamic> items) async {
    if (!_formKey.currentState!.validate()) {
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
      "items": items.map((item) => {
        "item_type": "product",
        "product": item['product_details']?['id'] ?? item['product'],
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
      final createdOrderData = _createOrderRx.valueStreamData.valueOrNull;
      if (createdOrderData != null && createdOrderData is Map) {
        final orderId = createdOrderData['id']?.toString() ?? createdOrderData['order_id']?.toString();
        if (orderId != null) {
          if (paymentMethod == 'card') {
            await _paymentConfirmationRx.confirmPayment({
              "order_id": orderId,
              "transaction_id": "ST_MOCK_${DateTime.now().millisecondsSinceEpoch}",
              "status": "succeeded",
            });
          }

          setState(() {
            checkingOut = false;
          });

          // Delete all basket items from the backend server
          for (var item in items) {
            final basketItemId = item['id']?.toString();
            if (basketItemId != null) {
              try {
                await CustomerOrdersApi.instance.deleteBasketItem(basketItemId);
              } catch (_) {}
            }
          }

          _cartRx.clean();

          try {
            CustomerOrdersApi.instance.cancelCheckout();
          } catch (_) {}

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                title: const Text('Order Placed Successfully!'),
                content: Text('Your order #$orderId has been submitted to the kitchen/delivery pipeline.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // close dialog
                      Get.back(); // close checkout screen
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
                    child: const Text('OK', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
            return;
          }
        }
      }

    setState(() {
      checkingOut = false;
    });
    Fluttertoast.showToast(msg: "Failed to place order. Please check inputs or try again.");
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
                                  separatorBuilder: (context, index) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final details = item['product_details'] ?? {};
                                    final name = details['name'] ?? 'Product';
                                    final price = double.tryParse(details['price']?.toString() ?? '0.0') ?? 0.0;
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
                                              Text('€${price.toStringAsFixed(2)} x $qty', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
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
                                      return const Center(child: CircularProgressIndicator());
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
                                      if (couponController.text.isEmpty) return;
                                      final couponResult = await _couponRx.validateCoupon(couponController.text);
                                      if (couponResult != null && couponResult is Map) {
                                        setState(() {
                                          appliedCouponCode = couponController.text;
                                          discountAmount = double.tryParse(couponResult['discount']?.toString() ?? '0.0') ?? 0.0;
                                          if (discountAmount == 0.0) {
                                            discountAmount = (currentSubtotal * 0.40); // fallback 40% discount
                                          }
                                        });
                                        Fluttertoast.showToast(msg: "Coupon Applied successfully!");
                                      } else {
                                        Fluttertoast.showToast(msg: "Invalid or Expired Coupon");
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                    child: const Text('Apply', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              if (appliedCouponCode.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                Text('Applied: $appliedCouponCode (Saved €${discountAmount.toStringAsFixed(2)})',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
                                    const Text('Discount', style: TextStyle(color: Colors.green)),
                                    Text('-€${discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                                  ],
                                ),
                              ],
                              const Divider(height: 20),
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
