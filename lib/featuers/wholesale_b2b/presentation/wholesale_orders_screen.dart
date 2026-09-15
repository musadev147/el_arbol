import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get/get.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../../common_wigdets/no_internet_or_data_widget.dart';
import '../../customers/orders/data/customer_orders_rx.dart';
import 'wholesale_order_details_screen.dart';
import 'package:el_arbol/helpers/di.dart';

class WholesaleOrdersScreen extends StatefulWidget {
  const WholesaleOrdersScreen({super.key});

  @override
  State<WholesaleOrdersScreen> createState() => _WholesaleOrdersScreenState();
}

class _WholesaleOrdersScreenState extends State<WholesaleOrdersScreen> {
  late final CustomerOrdersRx _rx;
  int _selectedFilterIndex = 0; // 0: Current Orders, 1: Previous Orders

  @override
  void initState() {
    super.initState();
    _rx = CustomerOrdersRx(empty: [], dataFetcher: BehaviorSubject<List<dynamic>>());
    _rx.fetchOrders();
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  bool _isPreviousOrder(String status) {
    final s = status.trim().toLowerCase();
    return s == 'delivered' ||
        s == 'completed' ||
        s == 'cancelled' ||
        s == 'returned' ||
        s == 'rejected';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'confirmed':
        return Colors.blue.shade700;
      case 'processing':
        return Colors.purple.shade700;
      case 'shipped':
      case 'in transit':
      case 'dispatched':
        return Colors.indigo.shade700;
      case 'delivered':
      case 'completed':
        return const Color(0xFF00694C);
      case 'cancelled':
      case 'returned':
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _showOrderTimeline(BuildContext context, String currentStatus, String orderNumber) {
    final s = currentStatus.trim().toLowerCase();
    final isCancelled = s == 'cancelled' || s == 'rejected';

    final stages = [
      {'title': 'Order Received', 'desc': 'Order submitted and in fulfillment queue'},
      {'title': 'Confirmed', 'desc': 'Verified by warehouse dispatch operations'},
      {'title': 'Processing & Palletizing', 'desc': 'Items picked, checked, and loaded'},
      {'title': 'Out for Delivery / Depot', 'desc': 'Freight carrier dispatched or ready for pickup'},
      {'title': 'Delivered', 'desc': 'Shipment delivered and signed for'},
    ];

    int currentStageIndex = 0;
    if (s == 'pending') {
      currentStageIndex = 0;
    } else if (s == 'confirmed') {
      currentStageIndex = 1;
    } else if (s == 'processing' || s == 'packaging') {
      currentStageIndex = 2;
    } else if (s == 'shipped' || s == 'in transit' || s == 'dispatched') {
      currentStageIndex = 3;
    } else if (s == 'delivered' || s == 'completed') {
      currentStageIndex = 4;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF151E13),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'ID: $orderNumber',
                      style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentStatus).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    currentStatus,
                    style: GoogleFonts.inter(
                      color: _getStatusColor(currentStatus),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (isCancelled) ...[
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 20),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'This order has been cancelled or rejected.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ] else ...[
              ...stages.asMap().entries.map((entry) {
                final idx = entry.key;
                final stage = entry.value;
                final isCompleted = idx <= currentStageIndex;
                final isCurrent = idx == currentStageIndex;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? const Color(0xFF00694C)
                                : Colors.grey.shade200,
                            border: isCurrent
                                ? Border.all(color: const Color(0xFF00694C), width: 3)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        if (idx < stages.length - 1)
                          Container(
                            width: 2.w,
                            height: 32.h,
                            color: idx < currentStageIndex
                                ? const Color(0xFF00694C)
                                : Colors.grey.shade200,
                          ),
                      ],
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: idx < stages.length - 1 ? 16.h : 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage['title']!,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                color: isCompleted
                                    ? const Color(0xFF151E13)
                                    : Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              stage['desc']!,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: isCompleted
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00694C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteOrder(String orderKey) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete Order',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        content: Text(
          'Are you sure you want to remove this order from your wholesale list? This action cannot be undone.',
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
      // 1. Remove from local stored orders
      try {
        final existing = (appData.read('wholesale_placed_orders') is List)
            ? List<dynamic>.from(appData.read('wholesale_placed_orders'))
            : <dynamic>[];
        existing.removeWhere((o) {
          if (o is Map) {
            final key = o['order_number']?.toString() ?? o['id']?.toString() ?? '';
            return key == orderKey;
          }
          return false;
        });
        appData.write('wholesale_placed_orders', existing);
      } catch (_) {}

      // 2. Add to deleted keys blacklist
      try {
        final deletedKeys = (appData.read('wholesale_deleted_orders') is List)
            ? List<String>.from(appData.read('wholesale_deleted_orders'))
            : <String>[];
        if (!deletedKeys.contains(orderKey)) {
          deletedKeys.add(orderKey);
          appData.write('wholesale_deleted_orders', deletedKeys);
        }
      } catch (_) {}

      setState(() {});
      AppToast.success('Order deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFF151E13)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF151E13)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'B2B Wholesale Orders',
          style: GoogleFonts.inter(
            color: const Color(0xFF151E13),
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF151E13)),
            onPressed: () => _rx.fetchOrders(),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<dynamic>(
          stream: _rx.valueStreamData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomAppLoading(message: 'Loading wholesale orders...');
            }

            if (snapshot.hasError) {
              return NoInternetOrDataWidget(
                title: 'Failed to Load Orders',
                message: 'Could not fetch wholesale orders. Please check your internet connection.',
                onRetry: () => _rx.fetchOrders(),
              );
            }

            final List<dynamic> serverOrders =
                (snapshot.data is List) ? (snapshot.data as List) : [];
            final List<dynamic> localOrders =
                (appData.read('wholesale_placed_orders') is List)
                    ? List<dynamic>.from(appData.read('wholesale_placed_orders'))
                    : [];

            final List<String> deletedKeys =
                (appData.read('wholesale_deleted_orders') is List)
                    ? List<String>.from(appData.read('wholesale_deleted_orders'))
                    : [];

            final Map<String, dynamic> mergedMap = {};
            for (final o in localOrders) {
              if (o is Map) {
                final key = o['order_number']?.toString() ?? o['id']?.toString() ?? '';
                if (key.isNotEmpty && !deletedKeys.contains(key)) {
                  mergedMap[key] = Map<String, dynamic>.from(o);
                }
              }
            }
            for (final o in serverOrders) {
              if (o is Map) {
                final key = o['order_number']?.toString() ?? o['id']?.toString() ?? '';
                if (key.isNotEmpty && !deletedKeys.contains(key)) {
                  // Merge but keep local rich item info if available
                  if (mergedMap.containsKey(key)) {
                    final existing = mergedMap[key]!;
                    final incoming = Map<String, dynamic>.from(o);
                    if (existing['items'] is List && (existing['items'] as List).isNotEmpty) {
                      incoming['items'] = existing['items'];
                    }
                    mergedMap[key] = incoming;
                  } else {
                    mergedMap[key] = Map<String, dynamic>.from(o);
                  }
                }
              }
            }

            final List<dynamic> allOrders = mergedMap.values.toList();

            // Filter Current vs Previous
            final currentOrders = allOrders
                .where((o) => !_isPreviousOrder(o['status']?.toString() ?? 'Pending'))
                .toList();
            final previousOrders = allOrders
                .where((o) => _isPreviousOrder(o['status']?.toString() ?? 'Pending'))
                .toList();

            final displayedOrders =
                _selectedFilterIndex == 0 ? currentOrders : previousOrders;

            return Column(
              children: [
                // Top Segmented Filter: Current Orders vs Previous Orders
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.all(4.r),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilterIndex = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _selectedFilterIndex == 0
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9.r),
                                boxShadow: _selectedFilterIndex == 0
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Current Orders',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: _selectedFilterIndex == 0
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _selectedFilterIndex == 0
                                          ? primaryColor
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  if (currentOrders.isNotEmpty) ...[
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: _selectedFilterIndex == 0
                                            ? primaryColor
                                            : Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${currentOrders.length}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilterIndex = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _selectedFilterIndex == 1
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9.r),
                                boxShadow: _selectedFilterIndex == 1
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Previous Orders',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: _selectedFilterIndex == 1
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _selectedFilterIndex == 1
                                          ? primaryColor
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  if (previousOrders.isNotEmpty) ...[
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: _selectedFilterIndex == 1
                                            ? primaryColor
                                            : Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${previousOrders.length}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Orders List
                Expanded(
                  child: displayedOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedFilterIndex == 0
                                    ? Icons.inventory_2_outlined
                                    : Icons.history_rounded,
                                size: 48.r,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                _selectedFilterIndex == 0
                                    ? 'No Current Orders'
                                    : 'No Previous Orders',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                _selectedFilterIndex == 0
                                    ? 'You have no active wholesale orders in progress.'
                                    : 'You have no delivered or completed past orders.',
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
                            await _rx.fetchOrders();
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                            itemCount: displayedOrders.length,
                            itemBuilder: (context, index) {
                              final order = displayedOrders[index] is Map
                                  ? Map<String, dynamic>.from(displayedOrders[index] as Map)
                                  : <String, dynamic>{};
                              final orderKey = order['order_number']?.toString() ??
                                  order['id']?.toString() ??
                                  '';

                              // Real order identifier
                              final rawNumber = order['order_number']?.toString() ?? '';
                              final rawId = order['id']?.toString() ?? '';
                              final displayOrderId = rawNumber.isNotEmpty
                                  ? rawNumber
                                  : (rawId.isNotEmpty ? '#$rawId' : 'WHS-Order');

                              final status = order['status']?.toString() ?? 'Pending';
                              final statusColor = _getStatusColor(status);

                              final createdDateStr = order['created_at']?.toString() ?? '';
                              DateTime parsedDate;
                              try {
                                parsedDate = DateTime.parse(createdDateStr).toLocal();
                              } catch (_) {
                                parsedDate = DateTime.now();
                              }

                              final double total = double.tryParse(
                                      order['total_amount']?.toString() ??
                                      order['total']?.toString() ??
                                      order['cart_subtotal']?.toString() ??
                                      '0.0') ?? 0.0;
                              final double adjustments =
                                  double.tryParse(order['adjustments']?.toString() ?? '0.0') ??
                                      0.0;
                              final double refunds =
                                  double.tryParse(order['refunds']?.toString() ?? '0.0') ?? 0.0;

                              // Extract items list
                              List<dynamic> items = [];
                              if (order['items'] is List) {
                                items = order['items'];
                              } else if (order['order_items'] is List) {
                                items = order['order_items'];
                              } else if (order['products'] is List) {
                                items = order['products'];
                              }

                              final itemsCount = items.isNotEmpty
                                  ? items.length
                                  : (order['items_count'] is int
                                      ? order['items_count']
                                      : 1);

                              return Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14.r),
                                    onTap: () => Get.to(() => WholesaleOrderDetailsScreen(
                                          orderId: displayOrderId,
                                          orderData: order,
                                        )),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.r),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Order ID, Status, and Delete Action
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  displayOrderId.startsWith('#') || displayOrderId.startsWith('ORD') || displayOrderId.startsWith('WHS')
                                                      ? 'Order $displayOrderId'
                                                      : 'Order #$displayOrderId',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF151E13),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w, vertical: 3.h),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: GoogleFonts.inter(
                                                    color: statusColor,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 6.w),
                                              IconButton(
                                                constraints: const BoxConstraints(),
                                                padding: EdgeInsets.all(4.r),
                                                icon: Icon(Icons.delete_outline_rounded,
                                                    color: Colors.red.shade400, size: 20.r),
                                                tooltip: 'Delete order',
                                                onPressed: () => _deleteOrder(orderKey),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            'Placed: ${DateFormat('yyyy-MM-dd HH:mm').format(parsedDate)}  •  $itemsCount items',
                                            style: GoogleFonts.inter(
                                              fontSize: 11.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),

                                          // Render products included in this order with details
                                          if (items.isNotEmpty) ...[
                                            SizedBox(height: 10.h),
                                            Container(
                                              padding: EdgeInsets.all(10.r),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF9FBF9),
                                                borderRadius: BorderRadius.circular(10.r),
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Order Items (${items.length}):',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xFF374151),
                                                    ),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  ...items.map((it) {
                                                    final name = it['product_name'] ??
                                                        it['name'] ??
                                                        it['title'] ??
                                                        (it['product'] is Map
                                                            ? (it['product']['name'] ?? it['product']['title'])
                                                            : null) ??
                                                        'Product';
                                                    final qty = it['quantity'] ?? it['qty'] ?? 1;
                                                    final unit = it['size_name'] ?? it['unit'] ?? 'kg';
                                                    final rawP = it['unit_price'] ??
                                                        it['price'] ??
                                                        it['wholesale_price'] ??
                                                        (it['product'] is Map ? it['product']['price'] : null);
                                                    final parsedPrice = rawP != null
                                                        ? double.tryParse(rawP
                                                            .toString()
                                                            .replaceAll('€', '')
                                                            .replaceAll('\$', '')
                                                            .trim())
                                                        : null;
                                                    final priceVal = parsedPrice != null
                                                        ? '€ ${parsedPrice.toStringAsFixed(2)}'
                                                        : '';

                                                    return Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 5.r,
                                                            height: 5.r,
                                                            decoration: const BoxDecoration(
                                                              color: primaryColor,
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                          SizedBox(width: 8.w),
                                                          Expanded(
                                                            child: Text(
                                                              '$name',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 12.sp,
                                                                color: const Color(0xFF1F2937),
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Text(
                                                            '$qty $unit',
                                                            style: GoogleFonts.inter(
                                                              fontSize: 11.sp,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.grey.shade700,
                                                            ),
                                                          ),
                                                          if (priceVal.isNotEmpty) ...[
                                                            SizedBox(width: 8.w),
                                                            Text(
                                                              priceVal,
                                                              style: GoogleFonts.inter(
                                                                fontSize: 11.sp,
                                                                fontWeight: FontWeight.bold,
                                                                color: primaryColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                          ],

                                          const Divider(height: 20),

                                          // Admin Adjustments Details if any
                                          if (adjustments != 0.0) ...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Admin Payment Adjustment',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12.sp,
                                                      color: Colors.amber.shade800,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                                Text(
                                                  '${adjustments >= 0 ? '+' : ''}€ ${adjustments.toStringAsFixed(2)}',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12.sp,
                                                      color: Colors.amber.shade800,
                                                      fontWeight: FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                          ],

                                          if (refunds != 0.0) ...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Admin Refunds Applied',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12.sp,
                                                      color: Colors.redAccent,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                                Text(
                                                  '-€ ${refunds.toStringAsFixed(2)}',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12.sp,
                                                      color: Colors.redAccent,
                                                      fontWeight: FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                          ],

                                          // Total and Buttons
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total Net Invoice',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                              Text(
                                                '€ ${(total + adjustments - refunds).toStringAsFixed(2)}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.h),

                                          // Action Buttons: Track Status & View Details
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () => _showOrderTimeline(
                                                      context, status, displayOrderId),
                                                  icon: const Icon(Icons.timeline_rounded,
                                                      color: primaryColor, size: 16),
                                                  label: Text(
                                                    'Track Status',
                                                    style: GoogleFonts.inter(
                                                      color: primaryColor,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    side: const BorderSide(color: primaryColor),
                                                    padding: EdgeInsets.symmetric(vertical: 9.h),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(9.r),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () => Get.to(() => WholesaleOrderDetailsScreen(
                                                        orderId: displayOrderId,
                                                        orderData: order,
                                                      )),
                                                  icon: const Icon(Icons.arrow_forward_rounded,
                                                      color: Colors.white, size: 16),
                                                  label: Text(
                                                    'Order Details',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: primaryColor,
                                                    elevation: 0,
                                                    padding: EdgeInsets.symmetric(vertical: 9.h),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(9.r),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
