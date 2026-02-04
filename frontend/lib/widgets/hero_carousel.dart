import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _slides = [
    {
      'badge': 'Des cheveux fortifiés et brillants',
      'title': 'Soins capillaires\nPremium',
      'description': 'Découvrez notre gamme de shampooings masques et aux actifs naturels.',
      'buttonText': 'Explorateur',
      'buttonColor': Color(0xFFE91E63),
      'image': 'https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=800',
    },
    {
      'badge': 'Protégez votre peau avec style cet été',
      'title': 'Nouvelle Collection\nSolaire',
      'description': 'Des protections solaires innovantes pour toute la famille. SPF 30 à 50+.',
      'buttonText': 'Voir la collection',
      'buttonColor': Color(0xFFFF9800),
      'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=800',
    },
    {
      'badge': 'Découvrez nos soins premium pour une peau éclatante',
      'title': 'Votre Beauté,\nNotre Priorité',
      'description': 'Des produits de parapharmacie sélectionnés avec soin pour votre bien-être quotidien.',
      'buttonText': 'Découvrez nos produits',
      'buttonColor': AppTheme.turquoise,
      'image': 'https://images.unsplash.com/photo-1571875257727-256c39da42af?w=800',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      height: isMobile ? 400 : 500,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return _buildSlide(slide, isMobile);
            },
          ),
          // Indicators
          Positioned(
            bottom: 20,
            left: isMobile ? 20 : 60,
            child: Row(
              children: List.generate(_slides.length, (index) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  width: _currentPage == index ? 40 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide, bool isMobile) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.network(
            slide['image'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppTheme.primaryGreen.withOpacity(0.3),
            ),
          ),
        ),
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        // Content
        Positioned(
          left: isMobile ? 20 : 60,
          top: isMobile ? 60 : 100,
          right: isMobile ? 20 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: slide['buttonColor'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slide['badge'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Title
              Text(
                slide['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16),
              // Description
              Container(
                width: isMobile ? double.infinity : 500,
                child: Text(
                  slide['description'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 24),
              // CTA Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: slide['buttonColor'],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 14 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slide['buttonText'],
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: isMobile ? 18 : 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
