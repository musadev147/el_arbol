import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TenantWallet extends StatefulWidget {
  const TenantWallet({super.key});

  @override
  State<TenantWallet> createState() => _TenantWalletState();
}

class _TenantWalletState extends State<TenantWallet> {
  double _balance = 75.40;

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Cashback - Click & Collect',
      'date': 'June 28, 2026',
      'amount': 3.50,
      'isCredit': true,
      'type': 'Cashback',
    },
    {
      'title': 'Refund Adjustment WHS-40812',
      'date': 'June 27, 2026',
      'amount': 25.00,
      'isCredit': true,
      'type': 'Refund',
    },
    {
      'title': 'Stripe Top-up',
      'date': 'June 25, 2026',
      'amount': 50.00,
      'isCredit': true,
      'type': 'Deposit',
    },
    {
      'title': 'Surplus Pack Reservation',
      'date': 'June 20, 2026',
      'amount': 5.00,
      'isCredit': false,
      'type': 'Purchase',
    },
  ];

  void _addFunds() {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final cardController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top up Wallet Balance',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? 'Enter top up amount' : null,
                  decoration: const InputDecoration(
                    labelText: 'Amount (€)',
                    hintText: 'e.g. 50.00',
                  ),
                ),
                TextFormField(
                  controller: cardController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (v) => v!.length < 16 ? 'Invalid card number' : null,
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    hintText: 'Stripe Card digits',
                    counterText: '',
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final val = double.tryParse(amountController.text);
                        if (val != null && val > 0) {
                          setState(() {
                            _balance += val;
                            _transactions.insert(0, {
                              'title': 'Stripe Top-up',
                              'date': 'Today',
                              'amount': val,
                              'isCredit': true,
                              'type': 'Deposit',
                            });
                          });
                          Fluttertoast.showToast(msg: '€${val.toStringAsFixed(2)} added to Wallet!');
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00694C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('Top up now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
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
          'My Wallet',
          style: TextStyle(
            color: Color(0xFF151E13),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Glassmorphic Balance Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, Color(0xFF004D38)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '€ ${_balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: _addFunds,
                      icon: const Icon(Icons.add, color: primaryColor, size: 18),
                      label: const Text('Add Funds', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),

              Text(
                'Recent Transactions',
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
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    final bool isCredit = tx['isCredit'];

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isCredit ? Colors.green : Colors.red,
                              size: 18.r,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx['title'],
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF151E13),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${tx['date']}  •  ${tx['type']}',
                                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isCredit ? '+' : '-'}€ ${tx['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: isCredit ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
