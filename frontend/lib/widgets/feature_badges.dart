import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeatureBadges extends StatelessWidget {
  const FeatureBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    final features = [
      {
        'icon': Icons.local_shipping_outlined,
        'text': 'Livraison gratuite dès 50€',
      },
      {
        'icon': Icons.verified_outlined,
        'text': 'Produits authentiques',
      },
      {
        'icon': Icons.access_time_outlined,
        'text': 'Livraison en 24-48h',
      },
      {
        'icon': Icons.star_outline,
        'text': 'Satisfait ou remboursé',
      },
    ];

    if (isMobile) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        color: AppTheme.turquoise.withOpacity(0.1),
        child: Column(
          children: features.map((feature) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildFeatureBadge(feature, isMobile),
            );
          }).toList(),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: isTablet ? 24 : 48),
      color: AppTheme.turquoise.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: features.map((feature) {
          return Expanded(
            child: _buildFeatureBadge(feature, isMobile),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeatureBadge(Map<String, dynamic> feature, bool isMobile) {
    return Row(
      mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.turquoise.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            feature['icon'],
            color: AppTheme.turquoise,
            size: isMobile ? 20 : 24,
          ),
        ),
        SizedBox(width: 12),
        Flexible(
          child: Text(
            feature['text'],
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
