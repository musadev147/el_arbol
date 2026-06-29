import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LeftoverPackScreen extends StatefulWidget {
  const LeftoverPackScreen({super.key});

  @override
  State<LeftoverPackScreen> createState() => _LeftoverPackScreenState();
}

class _LeftoverPackScreenState extends State<LeftoverPackScreen> {
  final List<Map<String, dynamic>> _stores = [
    {
      'name': 'El Árbol Centro',
      'address': 'Calle Sierpes 14, Sevilla',
      'packsAvailable': 3,
      'reserved': false,
      'code': 'ARBOL-SURPLUS-8902',
    },
    {
      'name': 'El Árbol Nervión',
      'address': 'Avenida de la Buhaira 27, Sevilla',
      'packsAvailable': 4,
      'reserved': false,
      'code': 'ARBOL-SURPLUS-4113',
    },
    {
      'name': 'El Árbol Triana',
      'address': 'Calle San Jacinto 82, Sevilla',
      'packsAvailable': 0,
      'reserved': false,
      'code': 'ARBOL-SURPLUS-7629',
    },
  ];

  void _reservePack(int index) {
    if (_stores[index]['packsAvailable'] <= 0) return;

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
                  const Text('Reserve Leftover Pack for €5.00'),
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
                              _stores[index]['packsAvailable']--;
                              _stores[index]['reserved'] = true;
                            });
                            Fluttertoast.showToast(
                              msg: "Leftover Pack Reserved Successfully!",
                              backgroundColor: const Color(0xFF00694C),
                              textColor: Colors.white,
                            );
                          });
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
                  child: const Text('Pay €5.00'),
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
              child: ListView.builder(
                itemCount: _stores.length,
                itemBuilder: (context, index) {
                  final store = _stores[index];
                  final bool outOfStock = store['packsAvailable'] == 0 && !store['reserved'];

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
                            Text(
                              store['name'],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF151E13),
                              ),
                            ),
                            Text(
                              '€5.00',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          store['address'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        if (store['reserved']) ...[
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
                                      store['code'],
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
                                outOfStock ? 'Sold Out' : '${store['packsAvailable']} packs left today',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: outOfStock ? Colors.red : primaryColor,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: outOfStock ? null : () => _reservePack(index),
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
              ),
            )
          ],
        ),
      ),
    );
  }
}
