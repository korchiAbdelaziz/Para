import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';


import 'user_orders_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.fetchAllUsers(auth.user?.token);
      orderProvider.fetchUserRanking(auth.user?.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('User Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade900,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading && orderProvider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.teal));
                }

                if (orderProvider.error != null && orderProvider.users.isEmpty) {
                  return Center(child: Text('Error: ${orderProvider.error}'));
                }

                // Merge auth users with ranking stats
                final filteredUsers = orderProvider.users.where((user) {
                  final name = (user['username'] ?? user['name'] ?? '').toString().toLowerCase();
                  final email = (user['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final username = user['username'] ?? user['name'];
                    
                    // Find order count from ranking
                    final rankingEntry = orderProvider.users.firstWhere(
                      (u) => (u['username'] ?? u['name']) == username,
                      orElse: () => {'orderCount': 0},
                    );
                    final orderCount = rankingEntry['orderCount'] ?? 0;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => UserOrdersScreen(user: user)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.teal.shade50,
                          backgroundImage: user['profileImageUrl'] != null ? NetworkImage(user['profileImageUrl']) : null,
                          child: user['profileImageUrl'] == null ? const Icon(Icons.person, color: Colors.teal) : null,
                        ),
                        title: Text(username ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${user['email'] ?? 'No email'}\n$orderCount Orders'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
