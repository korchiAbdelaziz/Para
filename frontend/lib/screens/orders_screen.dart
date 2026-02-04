import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../utils/custom_notification.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto-refresh every 5 seconds to simulate real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _fetchData(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _fetchData({bool silent = false}) {
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<OrderProvider>(context, listen: false).fetchUserOrders(
        auth.user?.username ?? 'Guest',
        auth.user?.token,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchData(),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (orderProvider.error != null && orderProvider.orders.isEmpty) {
            return Center(child: Text('Error: ${orderProvider.error}'));
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                elevation: 0,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Text(
                        'Order #${order.orderNumber.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Total: ${order.totalAmount.toStringAsFixed(2)} €',
                      style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    child: const Icon(Icons.shopping_bag, color: Colors.teal, size: 20),
                  ),
                  children: [
                    Divider(color: Colors.grey.shade200, height: 1),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productCode, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text('${item.price} € / unit', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                          ),
                          if (order.status == 'PENDING_VALIDATION') ...[
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                              onPressed: () => _updateQuantity(order.id, item, -1),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                              onPressed: () => _updateQuantity(order.id, item, 1),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _updateQuantity(order.id, item, -item.quantity),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ] else
                            Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 70,
                            child: Text(
                              '${(item.price * item.quantity).toStringAsFixed(2)} €',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    if (order.status == 'PENDING_VALIDATION')
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _cancelOrder(order.id),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancel Request'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'PENDING_VALIDATION':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        label = 'Pending';
        break;
      case 'VALIDATED':
        color = Colors.blue;
        icon = Icons.thumb_up;
        label = 'Validated';
        break;
      case 'IN_DELIVERY':
        color = Colors.indigo;
        icon = Icons.local_shipping;
        label = 'Shipping';
        break;
      case 'DELIVERED':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Delivered';
        break;
      case 'CANCELLED':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuantity(String orderId, var item, int change) async {
    final newQty = item.quantity + change;
    if (newQty < 0) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await Provider.of<OrderProvider>(context, listen: false)
        .updateOrderItem(orderId, item.productCode, newQty, auth.user?.token);

    if (!success && mounted) {
      showTopNotification(
        context, 
        'Update failed. Check stock availability.', 
        isError: true,
        actionLabel: 'OK',
        onAction: () {}
      );
    } else {
       if (mounted) _fetchData(silent: true);
    }
  }

  void _cancelOrder(String id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await Provider.of<OrderProvider>(context, listen: false).cancelOrder(id, auth.user?.token);
    if (success && mounted) {
      showTopNotification(
        context, 
        'Order Cancelled Successfully', 
        isError: false,
        actionLabel: 'UNDO',
        onAction: () {}
      );
      _fetchData(silent: true);
    }
  }
}
