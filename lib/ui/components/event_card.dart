import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../theme/app_colors.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onCalendarTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onBookmarkTap,
    this.onCalendarTap,
  });

  Color _getCategoryBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'hackathon':
        return AppColors.pillBlueBg;
      case 'tech':
      case 'ai':
        return AppColors.pillPurpleBg;
      case 'workshop':
      case 'design':
        return AppColors.pillGreenBg;
      case 'career':
      case 'networking':
        return AppColors.pillAmberBg;
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category.toLowerCase()) {
      case 'hackathon':
        return AppColors.pillBlueText;
      case 'tech':
      case 'ai':
        return AppColors.pillPurpleText;
      case 'workshop':
      case 'design':
        return AppColors.pillGreenText;
      case 'career':
      case 'networking':
        return AppColors.pillAmberText;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Badge Box on Left
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.navyDark,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navyDark.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.monthShort,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greenBadge,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.day,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Details Column in Middle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badges / Pills
                      if (event.categories.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: event.categories.take(2).map((cat) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryBgColor(cat),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _getCategoryTextColor(cat),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      // Event Title
                      Text(
                        event.eventName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Time Info Row
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              event.time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Venue Info Row
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              event.venue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Icons on Right (Calendar mark + Bookmark)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onCalendarTap != null || event.isCalendarMarked)
                      IconButton(
                        icon: Icon(
                          event.isCalendarMarked
                              ? Icons.event_available_rounded
                              : Icons.calendar_today_outlined,
                          color: event.isCalendarMarked
                              ? AppColors.greenIndicator
                              : AppColors.textMuted,
                          size: 20,
                        ),
                        splashRadius: 20,
                        tooltip: event.isCalendarMarked
                            ? 'Marked on Calendar'
                            : 'Add to Calendar',
                        onPressed: onCalendarTap,
                      ),
                    IconButton(
                      icon: Icon(
                        event.isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: event.isSaved
                            ? AppColors.purpleAccent
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      splashRadius: 20,
                      tooltip: event.isSaved ? 'Saved' : 'Save Event',
                      onPressed: onBookmarkTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
