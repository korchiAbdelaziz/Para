import 'package:flutter/material.dart';
import 'product_management_screen.dart';
import 'bulk_upload_screen.dart';
import 'user_management_screen.dart';
import 'order_management_screen.dart';
import 'inventory_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Central', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.teal.shade900,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.teal.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your shop inventory and data efficiently.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildDashboardCard(
                  context,
                  'Products',
                  'Manage inventory',
                  Icons.inventory_2_rounded,
                  [Colors.teal.shade400, Colors.teal.shade700],
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProductManagementScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Imports',
                  'Bulk CSV Upload',
                  Icons.auto_awesome_motion_rounded,
                  [Colors.indigo.shade400, Colors.indigo.shade700],
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const BulkUploadScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Users',
                  'Registered clients',
                  Icons.people_alt_rounded,
                  [Colors.orange.shade400, Colors.orange.shade700],
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UserManagementScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'All Orders',
                  'System history',
                  Icons.receipt_long_rounded,
                  [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const OrderManagementScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Stock Units',
                  'Cartons & Pieces',
                  Icons.warehouse_rounded,
                  [Colors.blueGrey.shade400, Colors.blueGrey.shade700],
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InventoryManagementScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
