import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../utils/custom_notification.dart';
import '../theme/app_theme.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Timer? _refreshTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _fetchData();
    _fadeController.forward();
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _fetchData(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _fetchData({bool silent = false}) {
    Future.microtask(() {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchProducts(filterStock: true);
      if (!silent) provider.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildPremiumAppBar(context),
      drawer: _buildDrawer(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            return Column(
              children: [
                if (productProvider.categories.isNotEmpty)
                  _buildCategoryFilter(productProvider, isDesktop),
                Expanded(
                  child: _buildProductGrid(productProvider, isDesktop, isTablet),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.local_pharmacy, color: AppTheme.primaryGold, size: 24),
          ),
          SizedBox(width: 12),
          Text(
            "Dani's Parasante",
            style: TextStyle(
              color: AppTheme.primaryGold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        if (Provider.of<AuthProvider>(context, listen: false).user?.username != 'admin')
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge(
              label: Text(cart.totalQuantity.toString()),
              isLabelVisible: cart.totalQuantity > 0,
              backgroundColor: AppTheme.primaryGold,
              textColor: AppTheme.primaryGreen,
              child: ch,
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: AppTheme.lightGold),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: AppTheme.lightGold),
          tooltip: 'Actualiser',
          onPressed: () => _fetchData(),
        ),
        IconButton(
          icon: Icon(Icons.logout_rounded, color: AppTheme.lightGold),
          onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCategoryFilter(ProductProvider provider, bool isDesktop) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 12),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final isSelected = provider.selectedCategory == category ||
              (provider.selectedCategory == null && category == 'All');

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: FilterChip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  provider.setCategory(selected ? category : 'All');
                },
                backgroundColor: Colors.white,
                selectedColor: AppTheme.lightGold,
                checkmarkColor: AppTheme.primaryGreen,
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGold : AppTheme.primaryGreen.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider provider, bool isDesktop, bool isTablet) {
    if (provider.isLoading && provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryGold),
            SizedBox(height: 16),
            Text('Chargement...', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    if (provider.error != null && provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            SizedBox(height: 16),
            Text('Erreur: ${provider.error}', style: TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.accentGreen.withOpacity(0.5)),
            SizedBox(height: 16),
            Text('Aucun produit disponible', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    int crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    double padding = isDesktop ? 32 : (isTablet ? 24 : 16);

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.68,
        crossAxisSpacing: isDesktop ? 24 : 16,
        mainAxisSpacing: isDesktop ? 24 : 16,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
        return _AnimatedProductCard(
          product: product,
          index: index,
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
              ),
            ),
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primaryGold,
                        child: Icon(Icons.person, size: 40, color: AppTheme.primaryGreen),
                      ),
                      SizedBox(height: 12),
                      Text(
                        auth.user?.username ?? 'Guest',
                        style: TextStyle(color: AppTheme.lightGold, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(Icons.home_rounded, 'Accueil', () => Navigator.pop(context)),
                if (auth.user?.username != 'admin')
                  _buildDrawerItem(Icons.history_rounded, 'Mes Commandes', () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrdersScreen()));
                  }),
                _buildDrawerItem(Icons.person_rounded, 'Mon Profil', () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
                }),
                if (auth.user?.username == 'admin')
                  _buildDrawerItem(Icons.admin_panel_settings_rounded, 'Admin Dashboard', () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
                  }),
                Divider(color: AppTheme.lightGold.withOpacity(0.3), thickness: 1, indent: 16, endIndent: 16),
                _buildDrawerItem(Icons.logout_rounded, 'Déconnexion', () => auth.logout(), isDestructive: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red.shade300 : AppTheme.lightGold),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red.shade300 : AppTheme.lightGold,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: AppTheme.primaryGold.withOpacity(0.1),
    );
  }
}

class _AnimatedProductCard extends StatefulWidget {
  final dynamic product;
  final int index;

  const _AnimatedProductCard({required this.product, required this.index});

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).user?.username == 'admin';

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: TweenAnimationBuilder(
          duration: Duration(milliseconds: 400 + (widget.index * 50)),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOut,
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Card(
            elevation: _isHovered ? 12 : 3,
            shadowColor: _isHovered ? AppTheme.primaryGold.withOpacity(0.4) : AppTheme.primaryGreen.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: _isHovered ? AppTheme.primaryGold : Colors.transparent,
                width: 2,
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: widget.product),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          child: widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                  child: Image.network(
                                    widget.product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.local_pharmacy, size: 50, color: AppTheme.accentGreen),
                                  ),
                                )
                              : Icon(Icons.local_pharmacy, size: 50, color: AppTheme.accentGreen),
                        ),
                        if (widget.product.category != null)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.primaryGold, width: 1),
                              ),
                              child: Text(
                                widget.product.category!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.lightGold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (widget.product.discountPrice != null && widget.product.discountPrice! > 0)
                          Row(
                            children: [
                              Text(
                                '${widget.product.price} €',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${widget.product.discountPrice} €',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            '${widget.product.price} €',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        SizedBox(height: 12),
                        if (!isAdmin)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (widget.product.stock <= 0) {
                                  showTopNotification(
                                    context,
                                    'Rupture de stock!',
                                    isError: true,
                                    actionLabel: 'OK',
                                    onAction: () {},
                                  );
                                  return;
                                }
                                cart.addItem(widget.product);
                                showTopNotification(
                                  context,
                                  '${widget.product.name} ajouté',
                                  isError: false,
                                  actionLabel: 'VOIR',
                                  onAction: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => const CartScreen()),
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: AppTheme.primaryGreen,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                elevation: _isHovered ? 4 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_shopping_cart, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Ajouter',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
