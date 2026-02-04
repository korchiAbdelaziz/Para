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
                  title: Text(
                    'Order #${order.orderNumber.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
}
