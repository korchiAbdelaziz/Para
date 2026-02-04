import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/main_navigation.dart';
import '../widgets/footer_section.dart';
import '../theme/app_theme.dart';
import '../utils/custom_notification.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
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
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 48),
                    child: isMobile || isTablet
                        ? Column(
                            children: [
                              _buildContactForm(isMobile),
                              SizedBox(height: 32),
                              _buildContactInfo(isMobile),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildContactForm(isMobile)),
                              SizedBox(width: 48),
                              Expanded(child: _buildContactInfo(isMobile)),
                            ],
                          ),
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
          colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.support_agent, size: isMobile ? 48 : 64, color: AppTheme.primaryGold),
          SizedBox(height: 16),
          Text(
            'Contactez-nous',
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Notre équipe est là pour vous aider',
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

  Widget _buildContactForm(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envoyez-nous un message',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person, color: AppTheme.turquoise),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGold, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: AppTheme.turquoise),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGold, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre email';
                }
                if (!value.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Sujet',
                prefixIcon: Icon(Icons.subject, color: AppTheme.turquoise),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGold, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un sujet';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Message',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.message, color: AppTheme.turquoise),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGold, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre message';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    showTopNotification(
                      context,
                      'Message envoyé avec succès !',
                      isError: false,
                    );
                    _formKey.currentState!.reset();
                    _nameController.clear();
                    _emailController.clear();
                    _subjectController.clear();
                    _messageController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.turquoise,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text(
                      'Envoyer le message',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(bool isMobile) {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.phone,
          title: 'Téléphone',
          content: '+33 1 23 45 67 89',
          subtitle: 'Lun-Ven: 9h-18h',
          isMobile: isMobile,
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.email,
          title: 'Email',
          content: 'contact@parapharma.com',
          subtitle: 'Réponse sous 24h',
          isMobile: isMobile,
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.location_on,
          title: 'Adresse',
          content: '123 Rue de la Santé',
          subtitle: '75001 Paris, France',
          isMobile: isMobile,
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.access_time,
          title: 'Horaires',
          content: 'Lun-Ven: 9h-18h',
          subtitle: 'Sam: 10h-16h',
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required String subtitle,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.turquoise.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.turquoise, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
