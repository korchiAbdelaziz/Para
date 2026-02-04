import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/products_page.dart';
import '../screens/promotions_page.dart';
import '../screens/contact_page.dart';

class MainNavigation extends StatefulWidget {
  final String currentPage;
  
  const MainNavigation({super.key, this.currentPage = 'Accueil'});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  void _navigateToPage(BuildContext context, String page) {
    if (page == widget.currentPage) return;

    Widget destination;
    switch (page) {
      case 'Accueil':
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      case 'Produits':
        destination = ProductsPage();
        break;
      case 'Promotions':
        destination = PromotionsPage();
        break;
      case 'Contact':
        destination = ContactPage();
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48),
      child: Row(
        children: [
          // Logo
          InkWell(
            onTap: () => _navigateToPage(context, 'Accueil'),
            child: _buildLogo(),
          ),
          SizedBox(width: isMobile ? 16 : 48),
          
          // Menu (Desktop only)
          if (!isMobile) ...[
            Expanded(child: _buildMenu(context)),
            SizedBox(width: 24),
          ] else
            Spacer(),
          
          // Action Icons
          _buildActionIcons(isMobile),
          
          // Mobile Menu Button
          if (isMobile)
            IconButton(
              icon: Icon(Icons.menu, color: AppTheme.primaryGreen),
              onPressed: () => _showMobileMenu(context),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.local_pharmacy,
            color: AppTheme.primaryGold,
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Text(
          "Dani's Parasante",
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    final menuItems = ['Accueil', 'Produits', 'Catégories', 'Promotions', 'Contact'];
    
    return Row(
      children: menuItems.map((item) {
        final isSelected = widget.currentPage == item;
        return Padding(
          padding: EdgeInsets.only(right: 32),
          child: InkWell(
            onTap: () => _navigateToPage(context, item),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                if (isSelected)
                  Container(
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionIcons(bool isMobile) {
    return Row(
      children: [
        if (!isMobile) ...[
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.primaryGreen),
            onPressed: () {},
            tooltip: 'Rechercher',
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.favorite_border, color: AppTheme.primaryGreen),
            onPressed: () {},
            tooltip: 'Favoris',
          ),
          SizedBox(width: 8),
        ],
        Consumer<CartProvider>(
          builder: (context, cart, _) => Badge(
            label: Text(cart.totalQuantity.toString()),
            isLabelVisible: cart.totalQuantity > 0,
            backgroundColor: AppTheme.primaryGold,
            textColor: AppTheme.primaryGreen,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryGreen),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              tooltip: 'Panier',
            ),
          ),
        ),
        if (!isMobile) ...[
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.turquoise,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              children: [
                Icon(Icons.support_agent, size: 18),
                SizedBox(width: 8),
                Text('Support', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMobileMenuItem(context, 'Accueil', Icons.home_outlined),
            _buildMobileMenuItem(context, 'Produits', Icons.inventory_2_outlined),
            _buildMobileMenuItem(context, 'Catégories', Icons.category_outlined),
            _buildMobileMenuItem(context, 'Promotions', Icons.local_offer_outlined),
            _buildMobileMenuItem(context, 'Contact', Icons.contact_support_outlined),
            Divider(height: 32),
            _buildMobileMenuItem(context, 'Rechercher', Icons.search),
            _buildMobileMenuItem(context, 'Favoris', Icons.favorite_border),
            _buildMobileMenuItem(context, 'Support', Icons.support_agent),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMenuItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        _navigateToPage(context, title);
      },
    );
  }
}
