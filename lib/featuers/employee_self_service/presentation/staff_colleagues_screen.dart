import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:el_arbol/featuers/employee_self_service/data/rx.dart';
import 'package:rxdart/rxdart.dart';

class StaffColleaguesScreen extends StatefulWidget {
  const StaffColleaguesScreen({super.key});

  @override
  State<StaffColleaguesScreen> createState() => _StaffColleaguesScreenState();
}

class _StaffColleaguesScreenState extends State<StaffColleaguesScreen> {
  late StaffColleaguesRx _colleaguesRx;

  @override
  void initState() {
    super.initState();
    _colleaguesRx = StaffColleaguesRx(empty: null, dataFetcher: BehaviorSubject<dynamic>());
    _colleaguesRx.fetchColleagues();
  }

  @override
  void dispose() {
    _colleaguesRx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Colleagues', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: _colleaguesRx.valueStreamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text("Failed to load colleagues."));
          }
          
          List<dynamic> colleagues = [];
          if (data is Map && data['results'] is List) {
            colleagues = data['results'] as List;
          } else if (data is List) {
            colleagues = data;
          }
          
          if (colleagues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64.r, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text('No colleagues found in your stores', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: colleagues.length,
            itemBuilder: (context, index) {
              final colleague = colleagues[index];
              final String name = colleague['name'] ?? colleague['user']?['name'] ?? 'Unknown';
              final String role = colleague['role'] ?? 'Staff';
              final String phone = colleague['phone'] ?? colleague['user']?['phone'] ?? '';
              
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20.sp),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            role,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                          ),
                          if (phone.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 12.sp, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(phone, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      ),
    );
  }
}
