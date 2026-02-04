import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _buildNavButton(
            icon: Icons.chevron_left,
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            isMobile: isMobile,
          ),
          SizedBox(width: 8),
          
          // Page Numbers
          ...List.generate(
            totalPages > 7 ? 7 : totalPages,
            (index) {
              int pageNum;
              if (totalPages <= 7) {
                pageNum = index + 1;
              } else {
                if (currentPage <= 4) {
                  pageNum = index + 1;
                } else if (currentPage >= totalPages - 3) {
                  pageNum = totalPages - 6 + index;
                } else {
                  pageNum = currentPage - 3 + index;
                }
              }
              
              if (pageNum < 1 || pageNum > totalPages) return SizedBox.shrink();
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
                child: _buildPageButton(
                  pageNum: pageNum,
                  isActive: pageNum == currentPage,
                  onPressed: () => onPageChanged(pageNum),
                  isMobile: isMobile,
                ),
              );
            },
          ),
          
          SizedBox(width: 8),
          // Next Button
          _buildNavButton(
            icon: Icons.chevron_right,
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: isMobile ? 36 : 40,
        height: isMobile ? 36 : 40,
        decoration: BoxDecoration(
          color: onPressed != null ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onPressed != null ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          color: onPressed != null ? AppTheme.primaryGreen : Colors.grey.shade400,
          size: isMobile ? 20 : 24,
        ),
      ),
    );
  }

  Widget _buildPageButton({
    required int pageNum,
    required bool isActive,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: isMobile ? 36 : 40,
        height: isMobile ? 36 : 40,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryGold : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppTheme.primaryGold : AppTheme.primaryGreen.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            pageNum.toString(),
            style: TextStyle(
              color: isActive ? AppTheme.primaryGreen : AppTheme.textPrimary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ),
      ),
    );
  }
}
