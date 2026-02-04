import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';


class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<OrderProvider>(context, listen: false).fetchAllOrders(auth.user?.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderProvider.error != null) {
            return Center(child: Text('Error: ${orderProvider.error}'));
          }
          if (orderProvider.orders.isEmpty) {
            return const Center(child: Text('No orders found in the system.'));
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
                  title: Row(
                    children: [
                      Text(
                        'Order #${order.orderNumber.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                  subtitle: Text(
                    'By: ${order.username} | Total: ${order.totalAmount.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.teal),
                  ),
                  leading: const Icon(Icons.receipt_long, color: Colors.teal),
                  children: [
                    Divider(color: Colors.grey.shade200),
                    ...order.items.map((item) => ListTile(
                      title: Text(item.productCode),
                      subtitle: Text('${item.quantity} x ${item.price} €'),
                      trailing: Text('${(item.price * item.quantity).toStringAsFixed(2)} €'),
                    )).toList(),
                    if (order.status == 'PENDING_VALIDATION')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _handleCancel(context, orderProvider, order.id, auth.user?.token),
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _handleValidate(context, orderProvider, order.id, auth.user?.token),
                              icon: const Icon(Icons.check),
                              label: const Text('Validate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
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
    switch (status) {
      case 'VALIDATED':
        color = Colors.green;
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _handleValidate(BuildContext context, OrderProvider provider, String id, String? token) async {
    final success = await provider.validateOrder(id, token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Validated')));
    }
  }

  void _handleCancel(BuildContext context, OrderProvider provider, String id, String? token) async {
    final success = await provider.cancelOrder(id, token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Cancelled & Stock Restored')));
    }
  }
}
