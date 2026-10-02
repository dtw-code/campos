import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnnouncementBanner extends StatelessWidget {
  final VoidCallback onTap;

  const AnnouncementBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFAF5FF), Color(0xFFEDE9FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.purpleBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.purpleAccent.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // AI Sparkle Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purpleAccent.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Heading and description
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Have an announcement? Let AI extract event details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purpleDarkText,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Paste text, flyers or emails to auto-create events',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B21A8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Forward Arrow Icon in circular button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.purpleBorder),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.purpleAccent,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
