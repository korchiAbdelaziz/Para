import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      color: Color(0xFF1A1A2E),
      child: Column(
        children: [
          // Newsletter Section
          Container(
            padding: EdgeInsets.all(isMobile ? 24 : 48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.turquoise, AppTheme.turquoise.withOpacity(0.8)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.white, size: isMobile ? 24 : 32),
                    SizedBox(width: 12),
                    Text(
                      'Offre exclusive',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Inscrivez-vous à notre newsletter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Inscrivez-vous et recevez 10% de réduction sur votre première commande, plus des offres exclusives et des conseils beauté.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: isMobile ? 13 : 15),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Votre adresse email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.send, size: 18),
                            SizedBox(width: 8),
                            Text("S'inscrire", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'En vous inscrivant, vous acceptez notre politique de confidentialité.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                ),
              ],
            ),
          ),
          
          // Features Bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: isMobile ? 16 : 48),
            color: Color(0xFF0F0F1E),
            child: isMobile
                ? Column(
                    children: [
                      _buildFeature(Icons.local_shipping_outlined, 'Livraison gratuite dès 50€'),
                      SizedBox(height: 12),
                      _buildFeature(Icons.lock_outline, 'Paiement sécurisé'),
                      SizedBox(height: 12),
                      _buildFeature(Icons.access_time_outlined, 'Retours sous 30 jours'),
                      SizedBox(height: 12),
                      _buildFeature(Icons.credit_card, 'Carte fidélité'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeature(Icons.local_shipping_outlined, 'Livraison gratuite dès 50€'),
                      _buildFeature(Icons.lock_outline, 'Paiement sécurisé'),
                      _buildFeature(Icons.access_time_outlined, 'Retours sous 30 jours'),
                      _buildFeature(Icons.credit_card, 'Carte fidélité'),
                    ],
                  ),
          ),
          
          // Footer Links
          Container(
            padding: EdgeInsets.all(isMobile ? 24 : 48),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFooterColumn('Produits', ['Soins du Visage', 'Soins du Corps', 'Cheveux', 'Maquillage', 'Promotions']),
                      SizedBox(height: 24),
                      _buildFooterColumn('Entreprise', ['À propos de', 'Nos magasins', 'Carrières', 'Blog', 'Contact']),
                      SizedBox(height: 24),
                      _buildFooterColumn('Soutien', ['FAQ', 'Livraison', 'Retours', 'CGV', 'Confidentialité']),
                      SizedBox(height: 24),
                      _buildContactInfo(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildContactInfo()),
                      SizedBox(width: 48),
                      Expanded(child: _buildFooterColumn('Produits', ['Soins du Visage', 'Soins du Corps', 'Cheveux', 'Maquillage', 'Promotions'])),
                      SizedBox(width: 48),
                      Expanded(child: _buildFooterColumn('Entreprise', ['À propos de', 'Nos magasins', 'Carrières', 'Blog', 'Contact'])),
                      SizedBox(width: 48),
                      Expanded(child: _buildFooterColumn('Soutien', ['FAQ', 'Livraison', 'Retours', 'CGV', 'Confidentialité'])),
                    ],
                  ),
          ),
          
          // Social & Copyright
          Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: isMobile ? 16 : 48),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(Icons.facebook),
                    SizedBox(width: 16),
                    _buildSocialIcon(Icons.camera_alt), // Instagram
                    SizedBox(width: 16),
                    _buildSocialIcon(Icons.play_arrow), // Twitter/X
                    SizedBox(width: 16),
                    _buildSocialIcon(Icons.video_library), // YouTube
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  '© 2026 ParaPharma. Tous droits réservés.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.turquoise.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.turquoise, size: 20),
        ),
        SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {},
                child: Text(
                  link,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_pharmacy, color: AppTheme.primaryGold, size: 24),
            ),
            SizedBox(width: 12),
            Text(
              'ParaPharma',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Votre parapharmacie en ligne de confiance. Des produits de qualité pour votre bien-être et votre beauté.',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
        ),
        SizedBox(height: 16),
        _buildContactItem(Icons.phone, '+33 1 23 45 67 89'),
        SizedBox(height: 8),
        _buildContactItem(Icons.email, 'contact@parapharma.com'),
        SizedBox(height: 8),
        _buildContactItem(Icons.location_on, '123 Rue de la Santé, 75001 Paris'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.turquoise, size: 16),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
