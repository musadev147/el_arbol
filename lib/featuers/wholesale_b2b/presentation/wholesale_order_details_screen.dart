import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../constants/app_assets/assets_icons.dart';
import '../../../../common_wigdets/app_toast.dart';
import '../../../../common_wigdets/custom_app_loading.dart';
import '../../../helpers/di.dart';
import '../../customers/orders/data/customer_orders_rx.dart';
import 'wholesale_cart_screen.dart';
import 'wholesale_cart_state.dart';
import 'wholesale_support_tickets_screen.dart';

class WholesaleOrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? orderData;

  const WholesaleOrderDetailsScreen({
    super.key,
    required this.orderId,
    this.orderData,
  });

  @override
  State<WholesaleOrderDetailsScreen> createState() =>
      _WholesaleOrderDetailsScreenState();
}

class _WholesaleOrderDetailsScreenState
    extends State<WholesaleOrderDetailsScreen> {
  late CustomerSingleOrderRx _rx;
  Map<String, dynamic>? _cachedData;

  @override
  void initState() {
    super.initState();
    _cachedData = widget.orderData != null
        ? Map<String, dynamic>.from(widget.orderData!)
        : null;

    if (_cachedData == null) {
      try {
        final existing = appData.read('wholesale_placed_orders');
        if (existing is List && existing.isNotEmpty) {
          final match = existing.firstWhere(
            (it) =>
                it['id']?.toString() == widget.orderId ||
                it['order_id']?.toString() == widget.orderId ||
                it['order_number']?.toString() == widget.orderId,
            orElse: () => null,
          );
          if (match != null && match is Map) {
            _cachedData = Map<String, dynamic>.from(match);
          }
        }
      } catch (_) {}
    }

    _rx = CustomerSingleOrderRx(
      empty: _cachedData ?? {},
      dataFetcher: BehaviorSubject<Map<String, dynamic>>.seeded(_cachedData ?? {}),
    );

    if (_cachedData != null && _cachedData!.isNotEmpty) {
      _rx.dataFetcher.sink.add(_cachedData!);
    }

    if (widget.orderId.isNotEmpty &&
        !widget.orderId.toLowerCase().startsWith('mock') &&
        !widget.orderId.toLowerCase().startsWith('ord-whs-')) {
      _rx.fetchSingleOrder(widget.orderId);
    }
  }

  @override
  void dispose() {
    _rx.dispose();
    super.dispose();
  }

  String _formatDateTime(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('d MMM yyyy, h:mm a').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'confirmed':
        return Colors.blue.shade700;
      case 'processing':
      case 'packaging':
      case 'palletizing':
        return Colors.purple.shade700;
      case 'shipped':
      case 'in transit':
      case 'dispatched':
        return Colors.indigo.shade700;
      case 'delivered':
      case 'completed':
        return const Color(0xFF00694C);
      case 'cancelled':
      case 'canceled':
      case 'rejected':
      case 'returned':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'confirmed':
        return Icons.verified_outlined;
      case 'processing':
      case 'palletizing':
        return Icons.inventory_2_outlined;
      case 'shipped':
      case 'in transit':
      case 'dispatched':
        return Icons.local_shipping_outlined;
      case 'delivered':
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
      case 'returned':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  int _getTimelineIndex(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'pending') return 0;
    if (s == 'confirmed') return 1;
    if (s == 'processing' || s == 'packaging' || s == 'palletizing') return 2;
    if (s == 'shipped' || s == 'in transit' || s == 'dispatched') return 3;
    if (s == 'delivered' || s == 'completed') return 4;
    return 0;
  }

  String? _resolveImageUrl(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'false') return null;
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    if (str.startsWith('/')) {
      return 'http://apielarbol.icommerce.com.bd$str';
    }
    return 'http://apielarbol.icommerce.com.bd/$str';
  }

  void _reorderItems(List<dynamic> items) {
    if (items.isEmpty) {
      AppToast.info('No items found in this order to reorder.');
      return;
    }

    int addedCount = 0;
    for (var it in items) {
      if (it is Map) {
        final id = it['product'] is Map
            ? (it['product']['id']?.toString() ?? '')
            : (it['product']?.toString() ??
                it['product_id']?.toString() ??
                it['id']?.toString() ??
                '');
        final name = it['product_name']?.toString() ??
            it['name']?.toString() ??
            it['title']?.toString() ??
            (it['product'] is Map ? (it['product']['name'] ?? it['product']['title']) : null) ??
            'Wholesale Product';
        final rawPrice = it['unit_price'] ??
            it['price'] ??
            it['wholesale_price'] ??
            (it['product'] is Map ? it['product']['price'] : null) ??
            0.0;
        final price = double.tryParse(
                rawPrice.toString().replaceAll('€', '').replaceAll('\$', '').trim()) ??
            0.0;
        final unit = it['size_name']?.toString() ?? it['unit']?.toString() ?? 'kg';
        final rawQty = it['quantity'] ?? it['qty'] ?? 1;
        final qty = double.tryParse(rawQty.toString()) ?? 1.0;
        final rawImg = it['product_image'] ??
            it['image'] ??
            it['imageUrl'] ??
            it['image_url'] ??
            it['thumbnail'] ??
            it['thumbnail_url'] ??
            (it['product'] is Map
                ? (it['product']['thumbnailUrl'] ??
                    it['product']['product_image'] ??
                    it['product']['image'] ??
                    it['product']['thumbnail'])
                : null);
        final img = _resolveImageUrl(rawImg);

        WholesaleCartState.addToCart(
          id: id,
          name: name,
          price: price,
          unit: unit,
          imageUrl: img,
          qty: qty,
        );
        addedCount++;
      }
    }

    AppToast.success('Added $addedCount item(s) to Wholesale Cart');
    Get.to(() => const WholesaleCartScreen());
  }

  void _showCommercialInvoiceModal(
      BuildContext context, Map<String, dynamic> order, String orderNumber) {
    final status = order['status']?.toString() ?? 'Pending';
    final createdDateStr = order['created_at']?.toString() ??
        order['date']?.toString() ??
        order['ordered_at']?.toString() ??
        '';

    List<dynamic> items = [];
    if (order['items'] is List) {
      items = order['items'];
    } else if (order['order_items'] is List) {
      items = order['order_items'];
    } else if (order['products'] is List) {
      items = order['products'];
    }

    final double total =
        double.tryParse(order['total']?.toString() ?? '0.0') ?? 0.0;
    final double adjustments =
        double.tryParse(order['adjustments']?.toString() ?? '0.0') ?? 0.0;
    final double refunds =
        double.tryParse(order['refunds']?.toString() ?? '0.0') ?? 0.0;
    final netTotal = total + adjustments - refunds;

    final company = order['company_name'] ??
        order['business_name'] ??
        order['customer_name'] ??
        'Wholesale Partner';
    final vat = order['vat_id'] ?? order['cif'] ?? order['tax_id'] ?? '';
    final paymentMethod = order['payment_method']?.toString() ?? 'cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
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
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00694C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: const Icon(Icons.receipt_long,
                            color: Color(0xFF00694C), size: 22),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Commercial Invoice',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF151E13),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Invoice #INV-$orderNumber',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor & Client Header
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FBF9),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ISSUED BY',
                                      style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade500),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text('El Árbol Organic SL',
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5.sp,
                                            color: const Color(0xFF00694C))),
                                    Text('VAT: ES-B88776655',
                                        style: GoogleFonts.inter(
                                            fontSize: 10.5.sp,
                                            color: Colors.grey.shade700)),
                                    Text('Madrid, Spain',
                                        style: GoogleFonts.inter(
                                            fontSize: 10.5.sp,
                                            color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'BILLED TO',
                                      style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade500),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      company.toString(),
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5.sp,
                                          color: const Color(0xFF151E13)),
                                      textAlign: TextAlign.end,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (vat.toString().isNotEmpty)
                                      Text('VAT: $vat',
                                          style: GoogleFonts.inter(
                                              fontSize: 10.5.sp,
                                              color: Colors.grey.shade700),
                                          textAlign: TextAlign.end),
                                    Text('B2B Wholesale Account',
                                        style: GoogleFonts.inter(
                                            fontSize: 10.5.sp,
                                            color: Colors.grey.shade600),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Date: ${_formatDateTime(createdDateStr)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 8.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(status),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Items Breakdown Table
                    Text(
                      'Items Breakdown',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF151E13),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(9.r)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text('Description',
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2,
                                    child: Text('Qty',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2,
                                    child: Text('Rate',
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2,
                                    child: Text('Amount',
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          if (items.isEmpty)
                            Padding(
                              padding: EdgeInsets.all(16.r),
                              child: Text('Standard B2B Bulk Order Items',
                                  style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600)),
                            )
                          else
                            ...items.map((it) {
                              final name = it['name'] ??
                                  it['product_name'] ??
                                  it['title'] ??
                                  'Wholesale Product';
                              final qty = it['quantity'] ?? it['qty'] ?? 1;
                              final unit = it['unit'] ?? 'kg';
                              final price = double.tryParse(
                                      it['price']?.toString() ?? '0.0') ??
                                  0.0;
                              final sub = price *
                                  (double.tryParse(qty.toString()) ?? 1.0);

                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.grey.shade200)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        '$name',
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            color: const Color(0xFF1F2937)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '$qty $unit',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            color: Colors.grey.shade700),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '€${price.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            color: Colors.grey.shade700),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '€${sub.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF00694C)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Financial summary
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal Net:',
                                  style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade700)),
                              Text('€${total.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (adjustments != 0.0) ...[
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Adjustments:',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.amber.shade800)),
                                Text(
                                    '${adjustments >= 0 ? '+' : ''}€${adjustments.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade800)),
                              ],
                            ),
                          ],
                          if (refunds != 0.0) ...[
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Refunds Applied:',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.redAccent)),
                                Text('-€${refunds.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent)),
                              ],
                            ),
                          ],
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Net Due:',
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF151E13))),
                              Text('€${netTotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00694C))),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Payment Terms:',
                                  style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      color: Colors.grey.shade600)),
                              Expanded(
                                child: Text(
                                    paymentMethod == 'bank_transfer'
                                        ? 'Bank Transfer (Net 30)'
                                        : paymentMethod.toUpperCase(),
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text:
                              'Commercial Invoice INV-$orderNumber\nTotal: €${netTotal.toStringAsFixed(2)}\nBilled to: $company'));
                      AppToast.success('Invoice details copied to clipboard');
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text('Copy Details',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00694C),
                      side: const BorderSide(color: Color(0xFF00694C)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      AppToast.success(
                          'Commercial Invoice INV-$orderNumber downloaded');
                    },
                    icon: const Icon(Icons.download, size: 16, color: Colors.white),
                    label: Text('Download PDF',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00694C),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.orderId.startsWith('#') ||
                  widget.orderId.startsWith('ORD') ||
                  widget.orderId.startsWith('WHS')
              ? 'Wholesale Order ${widget.orderId}'
              : 'Wholesale Order #${widget.orderId}',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              if (widget.orderId.isNotEmpty) {
                _rx.fetchSingleOrder(widget.orderId);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<dynamic>(
        stream: _rx.valueStreamData,
        initialData: _cachedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _cachedData == null) {
            return const CustomAppLoading(
                message: 'Loading wholesale order details...');
          }

          final dynamic raw = snapshot.data ?? _cachedData;
          final Map<String, dynamic> order = (raw is Map)
              ? Map<String, dynamic>.from(raw)
              : (_cachedData ?? {});

          final rawNumber = order['order_number']?.toString() ?? '';
          final rawId =
              order['id']?.toString() ?? widget.orderId.toString();
          final displayOrderId = rawNumber.isNotEmpty
              ? rawNumber
              : (rawId.isNotEmpty ? rawId : 'WHS-Order');

          final status = order['status']?.toString() ?? 'Pending';
          final statusColor = _getStatusColor(status);
          final statusIcon = _getStatusIcon(status);

          final createdDateStr = order['created_at']?.toString() ??
              order['date']?.toString() ??
              order['ordered_at']?.toString() ??
              '';

          // Extract items list
          List<dynamic> items = [];
          if (order['items'] is List) {
            items = order['items'];
          } else if (order['order_items'] is List) {
            items = order['order_items'];
          } else if (order['products'] is List) {
            items = order['products'];
          } else if (order['lines'] is List) {
            items = order['lines'];
          }

          // Financial calculations
          double calculatedSubtotal = 0.0;
          for (var it in items) {
            if (it is Map) {
              final rawPrice = it['unit_price'] ??
                  it['price'] ??
                  it['wholesale_price'] ??
                  (it['product'] is Map ? it['product']['price'] : null) ??
                  0.0;
              final p = double.tryParse(rawPrice
                      .toString()
                      .replaceAll('€', '')
                      .replaceAll('\$', '')
                      .trim()) ??
                  0.0;
              final q = double.tryParse(it['quantity']?.toString() ??
                      it['qty']?.toString() ??
                      '1') ??
                  1.0;
              calculatedSubtotal += (p * q);
            }
          }

          final rawTotal = order['total_amount'] ??
              order['total'] ??
              order['grand_total'] ??
              order['cart_subtotal'];
          final double total = (rawTotal != null &&
                  double.tryParse(rawTotal.toString()) != null)
              ? double.parse(rawTotal.toString())
              : calculatedSubtotal;
          final double adjustments = double.tryParse(
                  order['adjustments']?.toString() ?? '0.0') ??
              0.0;
          final double refunds =
              double.tryParse(order['refunds']?.toString() ?? '0.0') ?? 0.0;
          final double tax =
              double.tryParse(order['tax']?.toString() ?? '0.0') ?? 0.0;
          final double shipping =
              double.tryParse(order['shipping']?.toString() ?? '0.0') ?? 0.0;
          final double grandTotal =
              total + adjustments - refunds + tax + shipping;

          // Logistics & Company info
          final customerName = order['customer_name']?.toString() ?? '';
          final company = order['company_name'] ??
              order['business_name'] ??
              (customerName.contains('-')
                  ? customerName.split('-').first.trim()
                  : (customerName.isNotEmpty
                      ? customerName
                      : 'Wholesale Buyer'));
          final contactPerson = order['contact_person'] ??
              order['buyer_name'] ??
              (customerName.contains('-')
                  ? customerName.split('-').last.trim()
                  : (customerName.isNotEmpty
                      ? customerName
                      : ''));
          final phone = order['customer_phone'] ??
              order['phone'] ??
              order['business_phone'] ??
              '';
          final email = order['customer_email'] ??
              order['email'] ??
              order['business_email'] ??
              '';
          final vat = order['vat_id'] ?? order['cif'] ?? order['tax_id'] ?? '';
          final street = order['street_address']?.toString() ?? '';
          final city = order['city']?.toString() ?? '';
          final postcode = order['postcode']?.toString() ?? '';
          final fullStreet = (street.isNotEmpty && city.isNotEmpty)
              ? '$street, $city $postcode'.trim()
              : (street.isNotEmpty
                  ? street
                  : (city.isNotEmpty ? '$city $postcode'.trim() : ''));
          final deliveryAddress = (order['delivery_address']?.toString().isNotEmpty ?? false)
              ? order['delivery_address']
              : (fullStreet.isNotEmpty ? fullStreet : 'Warehouse Pickup / Delivery');
          final logisticsNotes = order['logistics_notes'] ??
              order['notes'] ??
              '';
          final deliverySlot = order['delivery_slot_label'] ??
              order['delivery_slot'] ??
              'Standard Delivery';
          final paymentMethod =
              order['payment_method']?.toString() ?? 'bank_transfer';

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status & Live Fulfillment Header
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(statusIcon,
                                color: statusColor, size: 28.sp),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayOrderId.startsWith('#') ||
                                                displayOrderId.startsWith('ORD') ||
                                                displayOrderId.startsWith('WHS')
                                            ? 'Order $displayOrderId'
                                            : 'Order #$displayOrderId',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                          color: const Color(0xFF151E13),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        status,
                                        style: GoogleFonts.inter(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                if (createdDateStr.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          size: 13.sp,
                                          color: Colors.grey.shade500),
                                      SizedBox(width: 4.w),
                                      Text(
                                        _formatDateTime(createdDateStr),
                                        style: GoogleFonts.inter(
                                          color: Colors.grey.shade600,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Stepper Pipeline Progress
                      _buildPipelineStepper(status),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 2. Business & Buyer Profile Card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Icon(Icons.business_center_outlined,
                                color: primaryColor, size: 18),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Business & Commercial Account',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF151E13),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildInfoRow('Company', company.toString()),
                      SizedBox(height: 6.h),
                      _buildInfoRow('Contact Person', contactPerson.toString()),
                      SizedBox(height: 6.h),
                      _buildInfoRow('VAT / Tax ID', vat.toString()),
                      SizedBox(height: 6.h),
                      _buildInfoRow('Phone', phone.toString()),
                      SizedBox(height: 6.h),
                      _buildInfoRow('Email', email.toString()),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 3. Logistics & Warehouse Delivery Details
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Icon(Icons.local_shipping_outlined,
                                color: primaryColor, size: 18),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Logistics & Pallet Delivery',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF151E13),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildInfoRow('Delivery Address', deliveryAddress.toString(),
                          isAddress: true),
                      SizedBox(height: 8.h),
                      _buildInfoRow('Preferred Slot', deliverySlot.toString()),
                      SizedBox(height: 8.h),
                      _buildInfoRow('Handling Notes', logisticsNotes.toString()),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 4. Products & Pallets Breakdown
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: const Icon(Icons.inventory_2_outlined,
                                    color: primaryColor, size: 18),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Pallet Items (${items.length})',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF151E13),
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => _reorderItems(items),
                            icon: const Icon(Icons.replay_rounded,
                                size: 15, color: primaryColor),
                            label: Text(
                              'Reorder All',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      if (items.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Center(
                            child: Text(
                              'No item breakdown details found for this order.',
                              style: GoogleFonts.inter(
                                  fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final item = items[index] as Map<String, dynamic>;
                            final name = item['product_name'] ??
                                item['name'] ??
                                item['title'] ??
                                (item['product'] is Map
                                    ? (item['product']['name'] ?? item['product']['title'])
                                    : null) ??
                                'Wholesale Product';

                            final rawImage = item['product_image'] ??
                                item['image'] ??
                                item['imageUrl'] ??
                                item['image_url'] ??
                                item['thumbnail'] ??
                                item['thumbnail_url'] ??
                                item['product_thumbnail'] ??
                                (item['product'] is Map
                                    ? (item['product']['thumbnailUrl'] ??
                                        item['product']['product_image'] ??
                                        item['product']['image'] ??
                                        item['product']['thumbnail'])
                                    : null);
                            final image = _resolveImageUrl(rawImage);

                            final rawP = item['unit_price'] ??
                                item['price'] ??
                                item['wholesale_price'] ??
                                (item['product'] is Map ? item['product']['price'] : null) ??
                                '0.00';
                            final price = double.tryParse(rawP
                                    .toString()
                                    .replaceAll('€', '')
                                    .replaceAll('\$', '')
                                    .trim()) ??
                                0.0;
                            final qty = item['quantity'] ?? item['qty'] ?? 1;
                            final unit = item['size_name'] ?? item['unit'] ?? 'kg';
                            final rawLineTotal = item['line_total'];
                            final lineTotal = rawLineTotal != null
                                ? (double.tryParse(rawLineTotal.toString().replaceAll('€', '').trim()) ?? (price * (double.tryParse(qty.toString()) ?? 1.0)))
                                : (price * (double.tryParse(qty.toString()) ?? 1.0));

                            return Row(
                              children: [
                                Container(
                                  width: 54.r,
                                  height: 54.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F6F4),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9.r),
                                    child: image != null && image.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.shade100,
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (_, __, ___) => Container(
                                              color: const Color(0xFFF9FBF9),
                                              padding: EdgeInsets.all(6.r),
                                              child: Image.asset(
                                                AssetsIcons.logoIcons,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => const Icon(
                                                  Icons.eco_rounded,
                                                  color: primaryColor,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: const Color(0xFFF9FBF9),
                                            padding: EdgeInsets.all(6.r),
                                            child: Image.asset(
                                              AssetsIcons.logoIcons,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.eco_rounded,
                                                color: primaryColor,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.toString(),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                          color: const Color(0xFF151E13),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        'Quantity: $qty $unit  •  €${price.toStringAsFixed(2)} / $unit',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '€${lineTotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 5. Invoice & Financial Breakdown
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: const Icon(Icons.payments_outlined,
                                    color: primaryColor, size: 18),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Invoice & Payment Summary',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF151E13),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.print_outlined,
                                color: primaryColor, size: 20),
                            tooltip: 'View Invoice',
                            onPressed: () => _showCommercialInvoiceModal(
                                context, order, displayOrderId),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildSummaryRow(
                          'Items Subtotal', '€${total.toStringAsFixed(2)}'),
                      if (tax > 0) ...[
                        SizedBox(height: 6.h),
                        _buildSummaryRow(
                            'Tax (VAT)', '€${tax.toStringAsFixed(2)}'),
                      ],
                      if (shipping > 0) ...[
                        SizedBox(height: 6.h),
                        _buildSummaryRow('Freight & Logistics',
                            '€${shipping.toStringAsFixed(2)}'),
                      ],
                      if (adjustments != 0.0) ...[
                        SizedBox(height: 6.h),
                        _buildSummaryRow('Admin Adjustment',
                            '${adjustments >= 0 ? '+' : ''}€${adjustments.toStringAsFixed(2)}',
                            color: Colors.amber.shade800),
                      ],
                      if (refunds != 0.0) ...[
                        SizedBox(height: 6.h),
                        _buildSummaryRow('Refunds Applied',
                            '-€${refunds.toStringAsFixed(2)}',
                            color: Colors.redAccent),
                      ],
                      const Divider(height: 20),
                      _buildSummaryRow(
                        'Total Net Invoice',
                        '€${grandTotal.toStringAsFixed(2)}',
                        isTotal: true,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: 8.h),
                      _buildSummaryRow(
                        'Payment Method',
                        paymentMethod == 'bank_transfer'
                            ? 'Corporate Bank Transfer (Net 30)'
                            : paymentMethod.toUpperCase(),
                        isSubtitle: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // 6. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCommercialInvoiceModal(
                            context, order, displayOrderId),
                        icon: const Icon(Icons.receipt_long,
                            color: primaryColor, size: 18),
                        label: Text(
                          'View Invoice',
                          style: GoogleFonts.inter(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryColor),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _reorderItems(items),
                        icon: const Icon(Icons.replay_rounded,
                            color: Colors.white, size: 18),
                        label: Text(
                          'Reorder',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Get.to(() => const WholesaleSupportTicketsScreen());
                    },
                    icon: Icon(Icons.support_agent_rounded,
                        color: Colors.grey.shade700, size: 18),
                    label: Text(
                      'Contact Warehouse Support regarding this order',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade700,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPipelineStepper(String status) {
    final s = status.trim().toLowerCase();
    final isCancelled = s == 'cancelled' || s == 'canceled' || s == 'rejected';

    if (isCancelled) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 22),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'This order was cancelled and will not proceed through dispatch.',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentStage = _getTimelineIndex(status);
    final stages = [
      {'title': 'Received', 'desc': 'Queue'},
      {'title': 'Confirmed', 'desc': 'Verified'},
      {'title': 'Palletizing', 'desc': 'Packing'},
      {'title': 'Dispatched', 'desc': 'Transit'},
      {'title': 'Delivered', 'desc': 'Signed'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (idx) {
        final isCompleted = idx <= currentStage;
        final isCurrent = idx == currentStage;
        final stage = stages[idx];

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3.h,
                      color: idx == 0
                          ? Colors.transparent
                          : (idx <= currentStage
                              ? const Color(0xFF00694C)
                              : Colors.grey.shade200),
                    ),
                  ),
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF00694C)
                          : Colors.grey.shade200,
                      border: isCurrent
                          ? Border.all(
                              color: const Color(0xFF00694C), width: 3)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Container(
                      height: 3.h,
                      color: idx == stages.length - 1
                          ? Colors.transparent
                          : (idx < currentStage
                              ? const Color(0xFF00694C)
                              : Colors.grey.shade200),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                stage['title']!,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCompleted
                      ? const Color(0xFF151E13)
                      : Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Row(
      crossAxisAlignment:
          isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.grey.shade600,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: const Color(0xFF151E13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isSubtitle = false,
    Color? color,
    Color? primaryColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: isTotal
                ? const Color(0xFF151E13)
                : (isSubtitle ? Colors.grey.shade600 : Colors.grey.shade700),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14.sp : (isSubtitle ? 11.sp : 12.sp),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: color ??
                (isTotal ? (primaryColor ?? const Color(0xFF00694C)) : const Color(0xFF151E13)),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 16.sp : (isSubtitle ? 11.sp : 12.sp),
          ),
        ),
      ],
    );
  }
}
