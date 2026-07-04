import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FinancialReport {
  final String id;
  final DateTime date;
  final double cash;
  final double bank;
  final double purchases;
  final double expenses;
  final double balance;

  FinancialReport({
    required this.id,
    required this.date,
    required this.cash,
    required this.bank,
    required this.purchases,
    required this.expenses,
    required this.balance,
  });
}

class DailyFinancialReportScreen extends StatefulWidget {
  const DailyFinancialReportScreen({super.key});

  @override
  State<DailyFinancialReportScreen> createState() => _DailyFinancialReportScreenState();
}

class _DailyFinancialReportScreenState extends State<DailyFinancialReportScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cashController = TextEditingController(text: '0.00');
  final _bankController = TextEditingController(text: '0.00');
  final _purchasesController = TextEditingController(text: '0.00');
  final _expensesController = TextEditingController(text: '0.00');

  double _calculatedBalance = 0.00;
  DateTime? _filterDate;

  // Mock list of reports
  final List<FinancialReport> _submittedReports = [
    FinancialReport(
      id: 'REP-001',
      date: DateTime.now().subtract(const Duration(days: 1)),
      cash: 1250.00,
      bank: 3400.00,
      purchases: 450.00,
      expenses: 120.00,
      balance: 4080.00,
    ),
    FinancialReport(
      id: 'REP-002',
      date: DateTime.now().subtract(const Duration(days: 2)),
      cash: 980.00,
      bank: 2900.00,
      purchases: 310.00,
      expenses: 85.00,
      balance: 3485.00,
    )
  ];

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateBalance);
    _bankController.addListener(_calculateBalance);
    _purchasesController.addListener(_calculateBalance);
    _expensesController.addListener(_calculateBalance);
  }

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    _purchasesController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _calculateBalance() {
    final cash = double.tryParse(_cashController.text) ?? 0.0;
    final bank = double.tryParse(_bankController.text) ?? 0.0;
    final purchases = double.tryParse(_purchasesController.text) ?? 0.0;
    final expenses = double.tryParse(_expensesController.text) ?? 0.0;

    setState(() {
      _calculatedBalance = (cash + bank) - (purchases + expenses);
    });
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      final cash = double.tryParse(_cashController.text) ?? 0.0;
      final bank = double.tryParse(_bankController.text) ?? 0.0;
      final purchases = double.tryParse(_purchasesController.text) ?? 0.0;
      final expenses = double.tryParse(_expensesController.text) ?? 0.0;

      final report = FinancialReport(
        id: 'REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        date: DateTime.now(),
        cash: cash,
        bank: bank,
        purchases: purchases,
        expenses: expenses,
        balance: _calculatedBalance,
      );

      setState(() {
        _submittedReports.insert(0, report);
        // Reset form
        _cashController.text = '0.00';
        _bankController.text = '0.00';
        _purchasesController.text = '0.00';
        _expensesController.text = '0.00';
      });

      Get.snackbar(
        'Report Submitted',
        'Daily report has been filed successfully.',
        backgroundColor: const Color(0xFF00694C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    // Filter reports
    final filteredReports = _filterDate == null
        ? _submittedReports
        : _submittedReports.where((r) {
            return r.date.year == _filterDate!.year &&
                r.date.month == _filterDate!.month &&
                r.date.day == _filterDate!.day;
          }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAF8),
        appBar: AppBar(
          title: Text(
            'Daily Financial Report',
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
          bottom: const TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
            tabs: [
              Tab(text: 'Submit New Report'),
              Tab(text: 'Previous Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Submit Form
            SingleChildScrollView(
              padding: EdgeInsets.all(20.r),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Daily Totals',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF151E13),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Inputs Row
                    _buildReportInputField('Cash Received', _cashController),
                    SizedBox(height: 12.h),
                    _buildReportInputField('Bank Deposits', _bankController),
                    SizedBox(height: 12.h),
                    _buildReportInputField('Purchases from Shop', _purchasesController),
                    SizedBox(height: 12.h),
                    _buildReportInputField('Expenses / Outgoings', _expensesController),
                    
                    SizedBox(height: 24.h),

                    // Balance Display Container
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: _calculatedBalance >= 0 ? const Color(0xFFECF7E4) : const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _calculatedBalance >= 0 ? const Color(0xFF00694C).withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calculated Net Balance',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _calculatedBalance >= 0 ? const Color(0xFF00694C) : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '€ ${_calculatedBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: _calculatedBalance >= 0 ? const Color(0xFF00694C) : Colors.red,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Formula: (Cash + Bank) - (Purchases + Expenses)',
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Submit Daily Report',
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
            ),

            // Tab 2: Previous Reports List
            Column(
              children: [
                // Filter bar
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _filterDate == null
                            ? 'Showing All Reports'
                            : 'Report for ${DateFormat('yyyy-MM-dd').format(_filterDate!)}',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today, color: primaryColor),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _filterDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _filterDate = picked;
                                });
                              }
                            },
                          ),
                          if (_filterDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () => setState(() => _filterDate = null),
                            )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: filteredReports.isEmpty
                      ? Center(
                          child: Text(
                            'No reports found.',
                            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        report.id,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('yyyy-MM-dd').format(report.date),
                                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                                      )
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  _buildReportRowDetail('Cash Received', report.cash),
                                  _buildReportRowDetail('Bank Deposits', report.bank),
                                  _buildReportRowDetail('Purchases', report.purchases),
                                  _buildReportRowDetail('Expenses', report.expenses),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Net Balance',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '€ ${report.balance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          color: report.balance >= 0 ? primaryColor : Colors.red,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF151E13),
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '€ ',
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF00694C)),
            ),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please enter a value';
            }
            if (double.tryParse(val) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        )
      ],
    );
  }

  Widget _buildReportRowDetail(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp)),
          Text('€ ${value.toStringAsFixed(2)}', style: TextStyle(fontSize: 13.sp)),
        ],
      ),
    );
  }
}
