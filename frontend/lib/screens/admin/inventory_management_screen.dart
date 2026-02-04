import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import 'product_form_screen.dart';
import 'bulk_upload_screen.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = Provider.of<AuthProvider>(context, listen: false).user?.token;
      Provider.of<InventoryProvider>(context, listen: false).fetchInventory(token);
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(filterStock: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Inventory & Stocks', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.teal.shade900,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(icon: Icon(Icons.list_alt_rounded), text: 'Stock List'),
              Tab(icon: Icon(Icons.add_box_outlined), text: 'Manual Add'),
              Tab(icon: Icon(Icons.upload_file_rounded), text: 'Bulk Upload'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStockList(),
            const ProductFormScreen(),
            const BulkUploadScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockList() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return RefreshIndicator(
      onRefresh: () async {
        final token = auth.user?.token;
        await Provider.of<InventoryProvider>(context, listen: false).fetchInventory(token);
        await Provider.of<ProductProvider>(context, listen: false).fetchProducts(filterStock: false);
      },
      child: Consumer2<InventoryProvider, ProductProvider>(
        builder: (context, inventoryProvider, productProvider, _) {
          if (inventoryProvider.isLoading || productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (productProvider.products.isEmpty) {
            return const Center(child: Text('No products in inventory.'));
          }

          // Create list with inventory quantities and sort by quantity descending
          final productsWithInventory = productProvider.products.map((product) {
            final inventory = inventoryProvider.items.firstWhere(
              (item) => item.productCode == product.sku,
              orElse: () => InventoryItem(productCode: product.sku, quantity: 0),
            );
            return {'product': product, 'inventory': inventory};
          }).toList();

          // Sort by quantity (highest first)
          productsWithInventory.sort((a, b) {
            final qtyA = (a['inventory'] as InventoryItem).quantity;
            final qtyB = (b['inventory'] as InventoryItem).quantity;
            return qtyB.compareTo(qtyA); // Descending order
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productsWithInventory.length,
            itemBuilder: (context, index) {
              final item = productsWithInventory[index];
              final product = item['product'] as dynamic;
              final inventory = item['inventory'] as InventoryItem;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, color: Colors.teal)),
                        )
                      : const Icon(Icons.inventory_2_outlined, color: Colors.teal),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('SKU: ${product.sku} | In Stock: ${inventory.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.teal),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showAddStockDialog(context, product.sku, auth.user?.token),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Stock+'),
                      ),
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

  void _showAddStockDialog(BuildContext context, String productCode, String? token) {
    final quantityController = TextEditingController();
    final piecesPerCartonController = TextEditingController();
    String selectedUnit = 'PIECE';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Stock for $productCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedUnit,
                items: ['PIECE', 'CARTON']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (val) => setState(() => selectedUnit = val!),
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                decoration: InputDecoration(
                  labelText: selectedUnit == 'PIECE' ? 'Quantity (Pieces) (+/-)' : 'Quantity (Cartons) (+/-)',
                  hintText: 'Use negative value to decrease',
                ),
              ),
              if (selectedUnit == 'CARTON') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: piecesPerCartonController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pieces per Carton'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(quantityController.text) ?? 0;
                final ppc = int.tryParse(piecesPerCartonController.text);
                
                final updateData = {
                  'productCode': productCode,
                  'quantity': qty,
                  'unit': selectedUnit,
                  'piecesPerCarton': ppc,
                };

                final success = await Provider.of<InventoryProvider>(context, listen: false)
                    .updateInventory(updateData, token);

                if (success) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
