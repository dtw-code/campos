import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/event_provider.dart';
import '../theme/app_colors.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  /// Helper to show as a modal bottom sheet
  static void show(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EventDetailsScreen(event: event),
    );
  }

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _checklistExpanded = true;

  @override
  void initState() {
    super.initState();
    // Ensure the event has a checklist (lazy-generate for mock/existing events)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().ensureChecklist(widget.event.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to keep saved and calendar-marked state in sync
    final provider = context.watch<EventProvider>();
    final currentEvent = provider.events.firstWhere(
      (e) => e.id == widget.event.id,
      orElse: () => widget.event,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Top drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  children: [
                    // Header Banner with Date Badge, Categories and Bookmark
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.navyDark,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                currentEvent.monthShort,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.greenBadge,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentEvent.day,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: currentEvent.categories.map((cat) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.purpleLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      cat,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.purpleDarkText,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currentEvent.formattedDate,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bookmark icon button
                        IconButton(
                          icon: Icon(
                            currentEvent.isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: currentEvent.isSaved
                                ? AppColors.purpleAccent
                                : AppColors.textMuted,
                            size: 26,
                          ),
                          onPressed: () {
                            context.read<EventProvider>().toggleSaveEvent(
                              currentEvent.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  currentEvent.isSaved
                                      ? 'Removed from saved events'
                                      : 'Event saved to your list!',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Event Title
                    Text(
                      currentEvent.eventName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Cards (Time, Venue, Organizer, Registration Deadline)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.purpleAccent,
                            title: 'Time',
                            subtitle: currentEvent.time,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.location_on_rounded,
                            iconColor: AppColors.greenIndicator,
                            title: 'Venue',
                            subtitle: currentEvent.venue,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.group_rounded,
                            iconColor: AppColors.tealIndicator,
                            title: 'Organized By',
                            subtitle: currentEvent.organizer,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.people_alt_rounded,
                            iconColor: AppColors.purpleAccent,
                            title: 'Team Size / Members',
                            subtitle: currentEvent.membersRange,
                          ),
                          if (currentEvent.registrationDeadline != null) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                              icon: Icons.alarm_rounded,
                              iconColor: AppColors.pinkIndicator,
                              title: 'Registration Deadline',
                              subtitle:
                                  '${currentEvent.registrationDeadline!.month}/${currentEvent.registrationDeadline!.day}/${currentEvent.registrationDeadline!.year}',
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // About / Description Section
                    const Text(
                      'About This Event',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentEvent.description.isNotEmpty
                          ? currentEvent.description
                          : 'No detailed description provided yet for this campus event.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Preparation Checklist Section
                    _buildChecklistSection(currentEvent, provider),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom 3 Action Buttons: Registration, Add to Calendar, Notion
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.cardBorder, width: 1),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Button 1: Registration Button (Direct primary action)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final url =
                                currentEvent.registrationUrl ??
                                'https://events.campus.edu/register/${currentEvent.id}';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.open_in_browser_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Opening registration link:\n$url',
                                        style: const TextStyle(fontSize: 12.5),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.navyDark,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Registration',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Row for Button 2 (Add to Calendar) & Button 3 (Notion)
                      Row(
                        children: [
                          // Button 2: Add to Calendar
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final isNowMarked = context
                                    .read<EventProvider>()
                                    .toggleCalendarMark(currentEvent.id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          isNowMarked
                                              ? Icons.check_circle_rounded
                                              : Icons.event_busy_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isNowMarked
                                                ? 'Added to calendar! Marked on ${currentEvent.monthShort} ${currentEvent.day}.'
                                                : 'Removed from calendar.',
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: isNowMarked
                                        ? AppColors.greenIndicator
                                        : AppColors.navyDark,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: currentEvent.isCalendarMarked
                                    ? AppColors.greenLight
                                    : AppColors.purpleLight.withAlpha(120),
                                side: BorderSide(
                                  color: currentEvent.isCalendarMarked
                                      ? AppColors.greenIndicator
                                      : AppColors.purpleBorder,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                currentEvent.isCalendarMarked
                                    ? Icons.event_available_rounded
                                    : Icons.calendar_today_rounded,
                                size: 16,
                                color: currentEvent.isCalendarMarked
                                    ? AppColors.greenIndicator
                                    : AppColors.purpleDarkText,
                              ),
                              label: Text(
                                currentEvent.isCalendarMarked
                                    ? 'Marked in Calendar'
                                    : 'Add to Calendar',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: currentEvent.isCalendarMarked
                                      ? AppColors.greenIndicator
                                      : AppColors.purpleDarkText,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Button 3: Notion Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'N',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Synced "${currentEvent.eventName}" to your Notion workspace!',
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF2E2E2E),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF7F7F5),
                                side: const BorderSide(
                                  color: Color(0xFFE0E0DC),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'N',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              label: const Text(
                                'Notion',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E2E2E),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChecklistSection(Event event, EventProvider provider) {
    if (event.checklist.isEmpty) {
      return const SizedBox.shrink();
    }

    final checkedCount = event.checkedItems
        .where((checked) => checked)
        .length;
    final totalCount = event.checklist.length;
    final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with toggle and progress
        GestureDetector(
          onTap: () {
            setState(() {
              _checklistExpanded = !_checklistExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.greenBadge,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Preparation Checklist',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Progress badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: checkedCount == totalCount
                        ? AppColors.greenIndicator.withAlpha(50)
                        : Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$checkedCount / $totalCount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: checkedCount == totalCount
                          ? AppColors.greenBadge
                          : Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _checklistExpanded ? 0.0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: Colors.white54,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Progress bar
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              checkedCount == totalCount
                  ? AppColors.greenIndicator
                  : AppColors.purpleAccent,
            ),
          ),
        ),

        // Checklist items
        if (_checklistExpanded) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: List.generate(event.checklist.length, (index) {
                final isChecked = index < event.checkedItems.length &&
                    event.checkedItems[index];
                final isLast = index == event.checklist.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        provider.toggleChecklistItem(event.id, index);
                      },
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(index == 0 ? 14 : 0),
                        bottom: Radius.circular(isLast ? 14 : 0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? AppColors.greenIndicator
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isChecked
                                      ? AppColors.greenIndicator
                                      : AppColors.textMuted.withAlpha(80),
                                  width: 1.5,
                                ),
                              ),
                              child: isChecked
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event.checklist[index],
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: isChecked
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: AppColors.textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 0, indent: 48, endIndent: 14),
                  ],
                );
              }),
            ),
          ),

          // Completion celebration
          if (checkedCount == totalCount && totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.greenIndicator.withAlpha(60),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      color: AppColors.greenIndicator,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All tasks completed! You\'re fully prepared. 🎉',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenIndicator,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
