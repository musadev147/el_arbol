import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:el_arbol/featuers/employee_self_service/data/rx.dart';
import 'package:el_arbol/featuers/employee_self_service/model/staff_dashboard_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import 'package:el_arbol/common_wigdets/app_toast.dart';

class StaffTasksScreen extends StatefulWidget {
  const StaffTasksScreen({super.key});

  @override
  State<StaffTasksScreen> createState() => _StaffTasksScreenState();
}

class _StaffTasksScreenState extends State<StaffTasksScreen> {
  late StaffTasksRx _tasksRx;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tasksRx = StaffTasksRx(empty: null, dataFetcher: BehaviorSubject<dynamic>());
    _fetchTasks();
  }

  @override
  void dispose() {
    _tasksRx.dispose();
    super.dispose();
  }

  void _fetchTasks() {
    final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    _tasksRx.fetchTasks(date: dateStr);
  }

  void _markCompleted(StaffTask task) async {
    EasyLoading.show(status: 'Updating...');
    final success = await _tasksRx.markTaskCompleted(task.id.toString());
    EasyLoading.dismiss();
    if (success) {
      AppToast.success("Task marked as completed");
      _fetchTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Daily Tasks', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                TextButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                      _fetchTasks();
                    }
                  },
                  icon: const Icon(Icons.calendar_month, color: primaryColor),
                  label: const Text('Change', style: TextStyle(color: primaryColor)),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _tasksRx.valueStreamData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomAppLoading(message: 'Loading daily tasks...');
                }
                final data = snapshot.data;
                if (data == null) {
                  return const Center(child: Text("Failed to load tasks."));
                }
                
                List<StaffTask> tasks = [];
                if (data is Map && data['results'] is List) {
                  tasks = (data['results'] as List).map((e) => StaffTask.fromJson(e)).toList();
                } else if (data is List) {
                  tasks = data.map((e) => StaffTask.fromJson(e)).toList();
                }
                
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64.r, color: Colors.grey.shade300),
                        SizedBox(height: 16.h),
                        Text('No tasks assigned for this date', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isCompleted = task.status == 'COMPLETED';
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  task.title ?? 'Untitled Task',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: isCompleted ? Colors.grey : Colors.black,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: isCompleted ? Colors.green.shade50 : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  task.status ?? 'PENDING',
                                  style: TextStyle(
                                    color: isCompleted ? Colors.green : Colors.blue,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          if (task.description != null && task.description!.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(task.description!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
                          ],
                          SizedBox(height: 16.h),
                          if (!isCompleted)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _markCompleted(task),
                                icon: const Icon(Icons.check, color: primaryColor),
                                label: const Text('Mark as Completed', style: TextStyle(color: primaryColor)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: primaryColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
