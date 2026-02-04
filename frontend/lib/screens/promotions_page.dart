import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/main_navigation.dart';
import '../widgets/footer_section.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';
import '../utils/custom_notification.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration(days: 2, hours: 14, minutes: 35);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(filterStock: true);
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeRemaining.inSeconds > 0) {
            _timeRemaining = _timeRemaining - Duration(seconds: 1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          TopBar(),
          MainNavigation(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(isMobile),
                  _buildCountdownBanner(isMobile),
                  Consumer<ProductProvider>(
                    builder: (context, provider, _) {
                      final promoProducts = provider.products
                          .where((p) => p.discountPrice != null && p.discountPrice! > 0)
                          .toList();

                      return Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offres spéciales',
                              style: TextStyle(
                                fontSize: isMobile ? 24 : 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Durée limitée - Profitez-en maintenant !',
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 15,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                            _buildPromoGrid(promoProducts, isMobile, isTablet),
                          ],
                        ),
                      );
                    },
                  ),
                  FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60, horizontal: isMobile ? 16 : 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade500],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_offer, color: Colors.white, size: isMobile ? 20 : 24),
                SizedBox(width: 8),
                Text(
                  'PROMOTIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Offres Exceptionnelles',
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Jusqu\'à -50% sur une sélection de produits',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBanner(bool isMobile) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Container(
      margin: EdgeInsets.all(isMobile ? 16 : 48),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'L\'offre se termine dans',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountdownBox(days.toString().padLeft(2, '0'), 'Jours', isMobile),
              SizedBox(width: isMobile ? 8 : 16),
              _buildCountdownBox(hours.toString().padLeft(2, '0'), 'Heures', isMobile),
              SizedBox(width: isMobile ? 8 : 16),
              _buildCountdownBox(minutes.toString().padLeft(2, '0'), 'Minutes', isMobile),
              SizedBox(width: isMobile ? 8 : 16),
              _buildCountdownBox(seconds.toString().padLeft(2, '0'), 'Sec', isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 10 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryGold,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoGrid(List products, bool isMobile, bool isTablet) {
    if (products.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_offer_outlined, size: 80, color: AppTheme.accentGreen.withOpacity(0.5)),
              SizedBox(height: 16),
              Text('Aucune promotion disponible', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    int crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 1.2 : 0.85,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final discount = ((product.price - product.discountPrice!) / product.price * 100).round();
        return _buildPromoCard(product, discount, isMobile);
      },
    );
  }

  Widget _buildPromoCard(dynamic product, int discount, bool isMobile) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
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
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                            child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                          )
                        : Icon(Icons.local_pharmacy, size: 60, color: AppTheme.accentGreen),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-$discount %',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 15 : 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${product.price} €',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${product.discountPrice} €',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addItem(product);
                        showTopNotification(context, '${product.name} ajouté au panier', isError: false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.turquoise,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Ajouter au panier',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
    );
  }
}
