import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      height: 40,
      color: AppTheme.turquoise,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              isMobile 
                ? "Livraison gratuite dès 50€"
                : "Livraison gratuite dès 50€ d'achat | Retours sous 30 jours",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 11 : 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: isMobile ? 16 : 18),
                SizedBox(width: 4),
                Text(
                  'Se connecter',
                  style: TextStyle(fontSize: isMobile ? 11 : 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
