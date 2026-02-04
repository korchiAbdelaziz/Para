import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';

class UserOrdersScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserOrdersScreen({super.key, required this.user});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final username = widget.user['username'] ?? widget.user['name'];
      Provider.of<OrderProvider>(context, listen: false).fetchUserOrders(username, auth.user?.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Orders: ${widget.user['username'] ?? widget.user['name']}', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade900,
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No orders placed by this user yet.', style: TextStyle(color: Colors.grey.shade600)),
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
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.teal),
                    ),
                    title: Text(
                      'Order #${order.orderNumber.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Total: ${order.totalAmount.toStringAsFixed(2)} €', 
                          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(color: Colors.grey.shade100),
                      ),
                      ...order.items.map((item) => ListTile(
                        title: Text(item.productCode, style: const TextStyle(fontSize: 14)),
                        subtitle: Text('${item.quantity} x ${item.price} €'),
                        trailing: Text('${(item.price * item.quantity).toStringAsFixed(2)} €', 
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      )).toList(),
                      if (order.status == 'PENDING_VALIDATION')
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _cancelOrder(order.id),
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _validateOrder(order.id),
                                  icon: const Icon(Icons.check_rounded, size: 18),
                                  label: const Text('Validate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _validateOrder(String id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await Provider.of<OrderProvider>(context, listen: false).validateOrder(id, auth.user?.token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Validated!')));
    }
  }

  void _cancelOrder(String id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await Provider.of<OrderProvider>(context, listen: false).cancelOrder(id, auth.user?.token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Cancelled & Stock Restored!')));
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'VALIDATED': color = Colors.green; break;
      case 'CANCELLED': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
