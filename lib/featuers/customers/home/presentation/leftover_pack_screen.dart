import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'data/rx.dart';
import 'model/leftover_store_model.dart';

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

  void _reservePack(LeftoverPack pack) {
    final stock = pack.stock ?? 0;
    if (stock <= 0) return;

    final price = pack.price ?? 0.0;

    // Show simulated payment dialog first
    showDialog(
      context: context,
      builder: (context) {
        bool processing = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              title: const Text('Stripe Secure Checkout'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Reserve leftover pack "${pack.name}" for €${price.toStringAsFixed(2)}'),
                  SizedBox(height: 16.h),
                  if (processing)
                    const CircularProgressIndicator(color: Color(0xFF00694C))
                  else ...[
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: Colors.blue),
                        SizedBox(width: 10.w),
                        const Text('•••• •••• •••• 4242'),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Pickup only, no delivery is available for Leftover Packs.',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: processing ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: processing
                      ? null
                      : () {
                          setDialogState(() {
                            processing = true;
                          });
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pop(context);
                            setState(() {
                              pack.stock = (pack.stock ?? 1) - 1;
                              _reservedPackIds.add(pack.id ?? 0);
                              _reservationCodes[pack.id ?? 0] = 'ARBOL-SURPLUS-${1000 + (pack.id ?? 0)}';
                            });
                            Fluttertoast.showToast(
                              msg: "Leftover Pack Reserved Successfully!",
                              backgroundColor: const Color(0xFF00694C),
                              textColor: Colors.white,
                            );
                          });
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
                  child: Text('Pay €${price.toStringAsFixed(2)}'),
                ),
              ],
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
                    return const Center(child: CircularProgressIndicator(color: primaryColor));
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
                                    onPressed: outOfStock ? null : () => _reservePack(pack),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Reserve'),
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
