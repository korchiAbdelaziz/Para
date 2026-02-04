import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
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
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderProvider.error != null) {
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
                  title: Text(
                    'Order #${order.orderNumber.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Total: ${order.totalAmount.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                  leading: const Icon(Icons.shopping_bag, color: Colors.teal),
                  children: [
                    Divider(color: Colors.grey.shade200),
                    ...order.items.map((item) => ListTile(
                      title: Text(item.productCode),
                      subtitle: Text('${item.quantity} x ${item.price} €'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(item.price * item.quantity).toStringAsFixed(2)} €'),
                          if (order.status == 'PENDING_VALIDATION')
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                              onPressed: () => _showUpdateDialog(context, order.id, item),
                            ),
                        ],
                      ),
                    )).toList(),
                    if (order.status == 'PENDING_VALIDATION')
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _cancelOrder(order.id),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancel Order'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
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

  void _cancelOrder(String id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await Provider.of<OrderProvider>(context, listen: false).cancelOrder(id, auth.user?.token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Order Cancelled'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  void _showUpdateDialog(BuildContext context, String orderId, var item) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Quantity for ${item.productCode}'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Quantity (0 to remove)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newQty = int.tryParse(quantityController.text);
              if (newQty != null && newQty >= 0) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final success = await Provider.of<OrderProvider>(context, listen: false)
                    .updateOrderItem(orderId, item.productCode, newQty, auth.user?.token);
                
                if (success) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    Provider.of<OrderProvider>(context, listen: false).fetchUserOrders(
                      auth.user?.username ?? 'Guest',
                      auth.user?.token,
                    );
                  }
                } else {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update. Check stock.')));
                   }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
