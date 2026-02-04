import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/main_navigation.dart';
import '../widgets/footer_section.dart';
import '../widgets/pagination_widget.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import '../utils/custom_notification.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int _currentPage = 1;
  final int _itemsPerPage = 12;
  String? _selectedCategory;
  double _minPrice = 0;
  double _maxPrice = 1000;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchProducts(filterStock: true);
      provider.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final isMobile = screenWidth <= 600;

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
                  Consumer<ProductProvider>(
                    builder: (context, provider, _) {
                      final filteredProducts = _getFilteredProducts(provider.products);
                      final totalPages = (filteredProducts.length / _itemsPerPage).ceil();
                      final startIndex = (_currentPage - 1) * _itemsPerPage;
                      final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredProducts.length);
                      final paginatedProducts = filteredProducts.sublist(
                        startIndex,
                        endIndex,
                      );

                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isMobile ? 16 : 48),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMobile) ...[
                                  Container(
                                    width: 250,
                                    child: _buildFilters(provider),
                                  ),
                                  SizedBox(width: 32),
                                ],
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildProductsHeader(filteredProducts.length, isMobile),
                                      SizedBox(height: 24),
                                      _buildProductGrid(paginatedProducts, isDesktop, isTablet),
                                      if (totalPages > 1)
                                        PaginationWidget(
                                          currentPage: _currentPage,
                                          totalPages: totalPages,
                                          onPageChanged: (page) {
                                            setState(() => _currentPage = page);
                                            // Scroll to top
                                            Scrollable.ensureVisible(
                                              context,
                                              duration: Duration(milliseconds: 300),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FooterSection(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showMobileFilters(context),
              backgroundColor: AppTheme.primaryGold,
              child: Icon(Icons.filter_list, color: AppTheme.primaryGreen),
            )
          : null,
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60, horizontal: isMobile ? 16 : 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Tous nos produits',
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Découvrez nos meilleures ventes sélectionnées pour vous',
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

  Widget _buildProductsHeader(int totalProducts, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$totalProducts produits trouvés',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: AppTheme.textSecondary,
          ),
        ),
        Row(
          children: [
            Icon(Icons.grid_view, size: 20, color: AppTheme.turquoise),
            SizedBox(width: 16),
            Icon(Icons.list, size: 20, color: AppTheme.textSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters(ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        SizedBox(height: 16),
        ...provider.categories.map((category) {
          final isSelected = _selectedCategory == category;
          return CheckboxListTile(
            dense: true,
            title: Text(category, style: TextStyle(fontSize: 14)),
            value: isSelected,
            activeColor: AppTheme.primaryGold,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value! ? category : null;
                _currentPage = 1;
              });
            },
          );
        }),
        SizedBox(height: 24),
        Text(
          'Prix',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 1000,
          divisions: 20,
          activeColor: AppTheme.primaryGold,
          labels: RangeLabels('${_minPrice.round()}€', '${_maxPrice.round()}€'),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
              _currentPage = 1;
            });
          },
        ),
        Text(
          '${_minPrice.round()}€ - ${_maxPrice.round()}€',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildProductGrid(List products, bool isDesktop, bool isTablet) {
    if (products.isEmpty) {
      return Container(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.accentGreen.withOpacity(0.5)),
              SizedBox(height: 16),
              Text('Aucun produit trouvé', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    int crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.68,
        crossAxisSpacing: isDesktop ? 24 : 16,
        mainAxisSpacing: isDesktop ? 24 : 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                            child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                          )
                        : Icon(Icons.local_pharmacy, size: 50, color: AppTheme.accentGreen),
                  ),
                  if (product.discountPrice != null && product.discountPrice! > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Promo',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (product.category != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category!,
                          style: TextStyle(color: AppTheme.lightGold, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  if (product.discountPrice != null && product.discountPrice! > 0)
                    Row(
                      children: [
                        Text(
                          '${product.price} €',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${product.discountPrice} €',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '${product.price} €',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addItem(product);
                        showTopNotification(context, '${product.name} ajouté', isError: false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.turquoise,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart, size: 16),
                          SizedBox(width: 6),
                          Text('Ajouter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  List _getFilteredProducts(List products) {
    return products.where((product) {
      bool categoryMatch = _selectedCategory == null || 
                          _selectedCategory == 'All' || 
                          product.category == _selectedCategory;
      
      double price = product.discountPrice != null && product.discountPrice! > 0
          ? product.discountPrice!.toDouble()
          : product.price.toDouble();
      
      bool priceMatch = price >= _minPrice && price <= _maxPrice;
      
      return categoryMatch && priceMatch;
    }).toList();
  }

  void _showMobileFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<ProductProvider>(
        builder: (context, provider, _) => Container(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: _buildFilters(provider),
          ),
        ),
      ),
    );
  }
}
