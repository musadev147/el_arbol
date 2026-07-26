import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../common_wigdets/custom_textfiled.dart';

class WholesaleDailyReportsScreen extends StatefulWidget {
  const WholesaleDailyReportsScreen({super.key});

  @override
  State<WholesaleDailyReportsScreen> createState() => _WholesaleDailyReportsScreenState();
}

class _WholesaleDailyReportsScreenState extends State<WholesaleDailyReportsScreen> {
  late WholesaleDailyReportsRx _rx;

  @override
  void initState() {
    super.initState();
    _rx = WholesaleDailyReportsRx(empty: {}, dataFetcher: BehaviorSubject<Map<String, dynamic>>());
    _rx.fetchDailyReports();
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  void _submitReport() {
    final cashController = TextEditingController();
    final bankController = TextEditingController();
    final expensesController = TextEditingController();
    final storeController = TextEditingController();
    final purchaseController = TextEditingController();
    final purchaseNoteController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              title: const Text('Submit Daily Report', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date: ${selectedDate.toIso8601String().split('T').first}', style: TextStyle(fontSize: 14.sp)),
                            const Icon(Icons.calendar_today, color: Color(0xFF00694C)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CustomTextFormField(controller: cashController, labelText: 'Cash Amount', keyboardType: TextInputType.number),
                    SizedBox(height: 8.h),
                    CustomTextFormField(controller: bankController, labelText: 'Bank Amount', keyboardType: TextInputType.number),
                    SizedBox(height: 8.h),
                    CustomTextFormField(controller: expensesController, labelText: 'Expenses', keyboardType: TextInputType.number),
                    SizedBox(height: 8.h),
                    CustomTextFormField(controller: storeController, labelText: 'Store Amount', keyboardType: TextInputType.number),
                    SizedBox(height: 8.h),
                    CustomTextFormField(controller: purchaseController, labelText: 'Purchase Amount', keyboardType: TextInputType.number),
                    SizedBox(height: 8.h),
                    CustomTextFormField(controller: purchaseNoteController, labelText: 'Purchase Note'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (cashController.text.isEmpty || bankController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Please fill required fields');
                      return;
                    }
                    
                    final success = await _rx.submitReport({
                      "date": selectedDate.toIso8601String().split('T').first,
                      "cash": double.tryParse(cashController.text) ?? 0.0,
                      "bank": double.tryParse(bankController.text) ?? 0.0,
                      "expenses": double.tryParse(expensesController.text) ?? 0.0,
                      "store": double.tryParse(storeController.text) ?? 0.0,
                      "purchase": double.tryParse(purchaseController.text) ?? 0.0,
                      "purchase_note": purchaseNoteController.text,
                    });
                    
                    if (success) {
                      Fluttertoast.showToast(msg: 'Report submitted');
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00694C)),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Daily Reports', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitReport,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Report', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: _rx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final data = snapshot.data;
          
          List<dynamic> reports = [];
          if (data is Map && data['results'] is List) {
            reports = data['results'] as List;
          } else if (data is List) {
            reports = data;
          }
          
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment_outlined, size: 64.r, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text('No reports submitted', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.r),
                  title: Text(report['date'] ?? 'Daily Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Text('Cash: \$${report['cash'] ?? 0} | Bank: \$${report['bank'] ?? 0}', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(height: 4.h),
                      Text('Expenses: \$${report['expenses'] ?? 0} | Store: \$${report['store'] ?? 0}', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(height: 4.h),
                      Text('Purchase: \$${report['purchase'] ?? 0}', style: TextStyle(fontSize: 12.sp)),
                      if (report['purchase_note'] != null && report['purchase_note'].toString().isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text('Note: ${report['purchase_note']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 11.sp, fontStyle: FontStyle.italic)),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
