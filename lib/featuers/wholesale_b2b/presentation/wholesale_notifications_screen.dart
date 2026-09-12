import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../common_wigdets/app_toast.dart';
import 'package:el_arbol/featuers/wholesale_b2b/data/wholesale_rx.dart';
import 'package:el_arbol/helpers/di.dart';
import 'wholesale_orders_screen.dart';
import 'wholesale_support_tickets_screen.dart';

class WholesaleNotificationsScreen extends StatefulWidget {
  const WholesaleNotificationsScreen({super.key});

  @override
  State<WholesaleNotificationsScreen> createState() => _WholesaleNotificationsScreenState();
}

class _WholesaleNotificationsScreenState extends State<WholesaleNotificationsScreen> {
  late WholesaleNotificationsRx _rx;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _rx = WholesaleNotificationsRx(
      empty: {},
      dataFetcher: BehaviorSubject<dynamic>(),
    );
    _rx.fetchNotifications();
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getMergedNotifications(dynamic serverData) {
    final List<Map<String, dynamic>> merged = [];
    final List<String> deletedKeys = (appData.read('wholesale_deleted_notifications') is List)
        ? List<String>.from(appData.read('wholesale_deleted_notifications'))
        : [];

    // Local notifications first
    try {
      final local = appData.read('wholesale_local_notifications');
      if (local is List) {
        for (final item in local) {
          if (item is Map) {
            final id = item['id']?.toString() ?? '';
            if (id.isNotEmpty && !deletedKeys.contains(id)) {
              merged.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }
    } catch (_) {}

    // Server notifications
    List<dynamic> serverList = [];
    if (serverData is Map && serverData['results'] is List) {
      serverList = serverData['results'] as List;
    } else if (serverData is List) {
      serverList = serverData;
    }

    for (final item in serverList) {
      if (item is Map) {
        final id = item['id']?.toString() ?? '';
        if (id.isNotEmpty && !deletedKeys.contains(id)) {
          // Avoid duplicates if already in local
          if (!merged.any((m) => m['id']?.toString() == id)) {
            merged.add(Map<String, dynamic>.from(item));
          }
        }
      }
    }

    return merged;
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<Map<String, dynamic>> notifications) {
    setState(() {
      if (_selectedIds.length == notifications.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.clear();
        for (final n in notifications) {
          final id = n['id']?.toString() ?? '';
          if (id.isNotEmpty) _selectedIds.add(id);
        }
      }
    });
  }

  Future<void> _deleteSelectedNotifications() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete Notifications',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedIds.length} selected notification${_selectedIds.length > 1 ? 's' : ''}?',
          style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('Delete',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final idsToDelete = Set<String>.from(_selectedIds);

      // 1. Remove from local storage
      try {
        final local = (appData.read('wholesale_local_notifications') is List)
            ? List<dynamic>.from(appData.read('wholesale_local_notifications'))
            : <dynamic>[];
        local.removeWhere((item) => item is Map && idsToDelete.contains(item['id']?.toString()));
        appData.write('wholesale_local_notifications', local);
      } catch (_) {}

      // 2. Add to deleted blacklist
      try {
        final deletedKeys = (appData.read('wholesale_deleted_notifications') is List)
            ? List<String>.from(appData.read('wholesale_deleted_notifications'))
            : <String>[];
        for (final id in idsToDelete) {
          if (!deletedKeys.contains(id)) deletedKeys.add(id);
        }
        appData.write('wholesale_deleted_notifications', deletedKeys);
      } catch (_) {}

      // 3. Delete from backend if possible
      for (final id in idsToDelete) {
        try {
          _rx.api.deleteNotification(id);
        } catch (_) {}
      }

      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });

      AppToast.success('Deleted ${idsToDelete.length} notification${idsToDelete.length > 1 ? 's' : ''}');
      _rx.fetchNotifications();
    }
  }

  void _markAsRead(String id) {
    try {
      final local = (appData.read('wholesale_local_notifications') is List)
          ? List<dynamic>.from(appData.read('wholesale_local_notifications'))
          : <dynamic>[];
      for (final item in local) {
        if (item is Map && item['id']?.toString() == id) {
          item['is_read'] = true;
        }
      }
      appData.write('wholesale_local_notifications', local);
      setState(() {});
    } catch (_) {}
  }

  void _onNotificationTap(Map<String, dynamic> notif) {
    final id = notif['id']?.toString() ?? '';
    _markAsRead(id);

    final type = notif['type']?.toString().toLowerCase() ?? '';
    if (type == 'order') {
      Get.to(() => const WholesaleOrdersScreen());
    } else if (type == 'ticket') {
      Get.to(() => const WholesaleSupportTicketsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return StreamBuilder<dynamic>(
      stream: _rx.valueStreamData,
      builder: (context, snapshot) {
        final notifications = _getMergedNotifications(snapshot.data);

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAF8),
          appBar: AppBar(
            backgroundColor: _isSelectionMode ? primaryColor : Colors.transparent,
            elevation: _isSelectionMode ? 1 : 0,
            leading: _isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedIds.clear();
                        _isSelectionMode = false;
                      });
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
                    onPressed: () => Navigator.maybePop(context),
                  ),
            title: Text(
              _isSelectionMode
                  ? '${_selectedIds.length} Selected'
                  : 'Notifications',
              style: GoogleFonts.inter(
                color: _isSelectionMode ? Colors.white : const Color(0xFF151E13),
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
              ),
            ),
            actions: [
              if (_isSelectionMode) ...[
                TextButton(
                  onPressed: () => _selectAll(notifications),
                  child: Text(
                    _selectedIds.length == notifications.length
                        ? 'Deselect All'
                        : 'Select All',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  tooltip: 'Delete Selected',
                  onPressed: _selectedIds.isNotEmpty ? _deleteSelectedNotifications : null,
                ),
              ] else ...[
                if (notifications.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSelectionMode = true;
                      });
                    },
                    icon: const Icon(Icons.checklist_rounded, color: primaryColor, size: 18),
                    label: Text(
                      'Select',
                      style: GoogleFonts.inter(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF151E13)),
                  onPressed: () => _rx.fetchNotifications(),
                ),
              ],
            ],
          ),
          bottomNavigationBar: _isSelectionMode && _selectedIds.isNotEmpty
              ? SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        )
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _deleteSelectedNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      label: Text(
                        'Delete (${_selectedIds.length}) Selected',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_none_rounded,
                            size: 38.r, color: primaryColor),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Notifications',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF151E13),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'You are all caught up! Updates regarding wholesale orders and support tickets will appear here.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async {
                    await _rx.fetchNotifications();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      final id = notif['id']?.toString() ?? '';
                      final isSelected = _selectedIds.contains(id);
                      final isRead = notif['is_read'] == true || notif['read'] == true;
                      final type = notif['type']?.toString().toLowerCase() ?? '';

                      IconData iconData = Icons.notifications_outlined;
                      Color iconColor = primaryColor;
                      if (type == 'order') {
                        iconData = Icons.local_shipping_outlined;
                        iconColor = const Color(0xFF00694C);
                      } else if (type == 'ticket') {
                        iconData = Icons.support_agent_rounded;
                        iconColor = Colors.blue.shade700;
                      }

                      return GestureDetector(
                        onLongPress: () {
                          if (!_isSelectionMode) {
                            setState(() {
                              _isSelectionMode = true;
                              _selectedIds.add(id);
                            });
                          }
                        },
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleSelection(id);
                          } else {
                            _onNotificationTap(notif);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.06)
                                : (isRead ? Colors.white : const Color(0xFFF4F9F5)),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : (isRead ? Colors.grey.shade200 : primaryColor.withValues(alpha: 0.3)),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isSelectionMode)
                                Padding(
                                  padding: EdgeInsets.only(right: 12.w, top: 2.h),
                                  child: Checkbox(
                                    value: isSelected,
                                    activeColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    onChanged: (_) => _toggleSelection(id),
                                  ),
                                )
                              else
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  margin: EdgeInsets.only(right: 12.w),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(iconData, color: iconColor, size: 20.r),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif['title'] ?? 'Notification',
                                            style: GoogleFonts.inter(
                                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                              fontSize: 13.sp,
                                              color: const Color(0xFF151E13),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (!isRead && !_isSelectionMode)
                                          Container(
                                            width: 8.r,
                                            height: 8.r,
                                            margin: EdgeInsets.only(left: 6.w),
                                            decoration: const BoxDecoration(
                                              color: primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      notif['message'] ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade700,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      notif['created_at'] ?? 'Recently',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey.shade400,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!_isSelectionMode) ...[
                                SizedBox(width: 4.w),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: Colors.grey.shade400, size: 18.r),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    setState(() {
                                      _selectedIds.clear();
                                      _selectedIds.add(id);
                                    });
                                    _deleteSelectedNotifications();
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
