import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final testimonials = [
      {
        'name': 'Sophie Martin',
        'time': 'Il y a 2 semaines',
        'rating': 5,
        'text': "J'adore cette parapharmacie ! Les produits sont de qualité et la livraison est toujours rapide. Le service client est exceptionnel.",
        'avatar': 'S',
      },
      {
        'name': 'Thomas Bernard',
        'time': 'Il y a 1 mois',
        'rating': 5,
        'text': "Excellent choix de produits. J'ai trouvé exactement ce que je cherchais pour ma routine de soin. Prix compétitifs aussi !",
        'avatar': 'T',
      },
      {
        'name': 'Marie Dubois',
        'time': 'Il y a 3 semaines',
        'rating': 5,
        'text': "Site très bien fait, navigation facile et paiement sécurisé. Je recommande vivement pour tous vos besoins en parapharmacie.",
        'avatar': 'M',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80, horizontal: isMobile ? 16 : 48),
      color: AppTheme.backgroundLight,
      child: Column(
        children: [
          Text(
            'Ce que disent nos clients',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Découvrez les avis de nos clients satisfaits',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 48),
          isMobile
              ? Column(
                  children: testimonials.map((t) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _buildTestimonialCard(t),
                  )).toList(),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: testimonials.map((t) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: _buildTestimonialCard(t),
                    ),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.turquoise,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.format_quote, color: Colors.white, size: 24),
          ),
          SizedBox(height: 16),
          Row(
            children: List.generate(
              testimonial['rating'],
              (index) => Icon(Icons.star, color: AppTheme.primaryGold, size: 18),
            ),
          ),
          SizedBox(height: 12),
          Text(
            testimonial['text'],
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryGold.withOpacity(0.2),
                child: Text(
                  testimonial['avatar'],
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testimonial['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Text(
                    testimonial['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
