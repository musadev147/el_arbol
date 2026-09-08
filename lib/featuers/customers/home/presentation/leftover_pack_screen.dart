import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'data/rx.dart';
import 'model/leftover_store_model.dart';
import '../../orders/data/customer_orders_rx.dart';
import '../../orders/presentation/customer_cart_screen.dart';
import '../../orders/presentation/customer_checkout_screen.dart';
import '../../../../common_wigdets/custom_app_loading.dart';

class LeftoverPackScreen extends StatefulWidget {
  const LeftoverPackScreen({super.key});

  @override
  State<LeftoverPackScreen> createState() => _LeftoverPackScreenState();
}

class _LeftoverPackScreenState extends State<LeftoverPackScreen> {
  late final GetLeftoverStoreRx _rx;
  final Set<int> _reservedPackIds = {};
  final Map<int, String> _reservationCodes = {};

  @override
  void initState() {
    super.initState();
    _rx = GetLeftoverStoreRx(
      empty: [],
      dataFetcher: BehaviorSubject<List<LeftoverStoreModel>>(),
    );
    _rx.fetchLeftoverStores();
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  void _reservePack(LeftoverPack pack, LeftoverStoreModel store) {
    final maxStock = pack.stock ?? 1;
    if (maxStock <= 0) return;

    final double price = pack.price ?? 0.0;
    final double originalPrice = pack.originalPrice ?? 0.0;
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double totalPrice = price * quantity;

            return Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 48.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Header: Store info & Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00694C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Surplus Food • Store Pickup Only',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF00694C),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                pack.name ?? 'Surplus Food Pack',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF151E13),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.storefront, size: 16.r, color: Colors.grey.shade600),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${store.name ?? 'Store'} • ${store.address ?? ''}',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (pack.description != null && pack.description!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(
                        pack.description!,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, height: 1.4),
                      ),
                    ],

                    SizedBox(height: 16.h),
                    const Divider(height: 1, color: Color(0xFFF0F1F3)),
                    SizedBox(height: 16.h),

                    // Price & Stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  '€${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                if (originalPrice > 0) ...[
                                  SizedBox(width: 8.w),
                                  Text(
                                    '€${originalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '$maxStock left in store',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00694C),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF151E13),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: quantity > 1
                                    ? () => setModalState(() => quantity--)
                                    : null,
                                constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                                padding: EdgeInsets.zero,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  '$quantity',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: quantity < maxStock
                                    ? () => setModalState(() => quantity++)
                                    : null,
                                constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await CustomerCartRx.instance.addLeftoverPackToBasket(
                            packId: pack.id ?? 0,
                            name: pack.name ?? 'Surplus Food Pack',
                            price: price,
                            storeName: store.name,
                            quantity: quantity,
                          );

                          Navigator.pop(ctx);
                          Get.snackbar(
                            'Added to Cart',
                            '${pack.name ?? "Leftover Pack"} added to your cart.',
                            backgroundColor: const Color(0xFF00694C),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 4),
                            mainButton: TextButton(
                              onPressed: () {
                                Get.to(() => CustomerCartScreen(
                                  cartItems: RxList<Map<String, dynamic>>([]),
                                ));
                              },
                              child: const Text(
                                'View Cart',
                                style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        label: Text(
                          'Add to Cart • €${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00694C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Optional instant checkout option
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          await CustomerCartRx.instance.addLeftoverPackToBasket(
                            packId: pack.id ?? 0,
                            name: pack.name ?? 'Surplus Food Pack',
                            price: price,
                            storeName: store.name,
                            quantity: quantity,
                          );
                          Navigator.pop(ctx);
                          Get.to(() => const CustomerCheckoutScreen());
                        },
                        child: Text(
                          'Order & Checkout Directly',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF00694C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          'Leftover Packs',
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Info
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF004D37)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save Food & Money!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Reserve surplus organic food packs from nearby stores. Pickup only at the chosen shop.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.eco,
                    color: Colors.white.withOpacity(0.3),
                    size: 64.r,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Nearest Surplus Packs',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF151E13),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: StreamBuilder<List<LeftoverStoreModel>>(
                stream: _rx.valueStreamData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomAppLoading.list(message: 'Loading leftover packs...');
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load leftover packs'));
                  }

                  final stores = snapshot.data ?? [];
                  final List<Map<String, dynamic>> packsWithStoreInfo = [];

                  for (var store in stores) {
                    if (store.leftoverPacks != null) {
                      for (var pack in store.leftoverPacks!) {
                        packsWithStoreInfo.add({
                          'store': store,
                          'pack': pack,
                        });
                      }
                    }
                  }

                  if (packsWithStoreInfo.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco_outlined, size: 48.r, color: Colors.grey),
                          SizedBox(height: 10.h),
                          const Text('No surplus packs available today.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: packsWithStoreInfo.length,
                    itemBuilder: (context, index) {
                      final item = packsWithStoreInfo[index];
                      final LeftoverStoreModel store = item['store'];
                      final LeftoverPack pack = item['pack'];
                      final bool isReserved = _reservedPackIds.contains(pack.id);
                      final int stock = pack.stock ?? 0;
                      final bool outOfStock = stock <= 0 && !isReserved;
                      final double price = pack.price ?? 0.0;
                      final double originalPrice = pack.originalPrice ?? 0.0;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    pack.name ?? 'Surplus Food Pack',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF151E13),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (originalPrice > 0)
                                      Text(
                                        '€${originalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '€${price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Shop: ${store.name ?? ''} (${store.address ?? ''})',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                            if (pack.description != null && pack.description!.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Text(
                                pack.description!,
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                              ),
                            ],
                            SizedBox(height: 12.h),
                            if (isReserved) ...[
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: primaryColor),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Reserved & Paid',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    const Text(
                                      'Show this receipt code at checkout to pick up your pack:',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _reservationCodes[pack.id] ?? '',
                                          style: TextStyle(
                                            fontFamily: 'Orbitron',
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF151E13),
                                          ),
                                        ),
                                        const Icon(Icons.qr_code, size: 24),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    outOfStock ? 'Sold Out' : '$stock packs left today',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: outOfStock ? Colors.red : primaryColor,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: outOfStock ? null : () => _reservePack(pack, store),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Reserve Now'),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
