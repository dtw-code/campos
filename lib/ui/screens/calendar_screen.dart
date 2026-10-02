import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/event_provider.dart';
import '../components/event_card.dart';
import '../theme/app_colors.dart';
import 'event_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Default to August 2026 to align with mock events like HackMIT on August 28
    _focusedMonth = DateTime(2026, 8);
    _selectedDay = DateTime(2026, 8, 28);
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDay = null;
    });
  }

  List<Event> _eventsForDay(List<Event> allEvents, DateTime day) {
    return allEvents.where((e) {
      return e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final allEvents = provider.events;

    // Collect days marked by the student
    final markedDays = provider.getCalendarMarkedDays(
      _focusedMonth.year,
      _focusedMonth.month,
    );

    // Collect all event days
    final allEventDays = <int>{};
    for (final event in allEvents) {
      if (event.date.year == _focusedMonth.year &&
          event.date.month == _focusedMonth.month) {
        allEventDays.add(event.date.day);
      }
    }

    final selectedDayEvents = _selectedDay != null
        ? _eventsForDay(allEvents, _selectedDay!)
        : <Event>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyDark,
        elevation: 0,
        title: const Text(
          'Campus Calendar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          _buildHeader(markedDays.length),

          // Scrollable calendar & events
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildMonthNavigator(markedDays.length),
                  _buildDayOfWeekLabels(),
                  _buildCalendarGrid(allEventDays, markedDays),
                  _buildLegend(),

                  const SizedBox(height: 12),

                  if (_selectedDay != null) ...[
                    _buildSelectedDayHeader(),
                    if (selectedDayEvents.isEmpty)
                      _buildNoEventsPlaceholder()
                    else
                      _buildEventsList(selectedDayEvents),
                  ] else ...[
                    const SizedBox(height: 16),
                    _buildHintSection(markedDays.length),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int markedCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: AppColors.navyDark,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.purpleAccent.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.purpleAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Marked Campus Dates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  markedCount == 0
                      ? 'No dates marked yet. Add events to calendar!'
                      : '$markedCount event date${markedCount == 1 ? '' : 's'} highlighted on your calendar',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Jump to Aug 2026 / Hackathon shortcut
          GestureDetector(
            onTap: () {
              setState(() {
                _focusedMonth = DateTime(2026, 8);
                _selectedDay = DateTime(2026, 8, 28);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greenBadge.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.greenBadge.withAlpha(80)),
              ),
              child: const Text(
                'Aug 28',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenBadge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator(int markedInMonth) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthName = months[_focusedMonth.month - 1];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildArrowButton(Icons.chevron_left_rounded, _goToPreviousMonth),
          Column(
            children: [
              Text(
                '$monthName ${_focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (markedInMonth > 0)
                Text(
                  '$markedInMonth marked by you',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenIndicator,
                  ),
                ),
            ],
          ),
          _buildArrowButton(Icons.chevron_right_rounded, _goToNextMonth),
        ],
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.navyDark.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.navyDark, size: 22),
      ),
    );
  }

  Widget _buildDayOfWeekLabels() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: days.map((d) {
          return Expanded(
            child: Center(
              child: Text(
                d,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(Set<int> allEventDays, Set<int> markedDays) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday;

    final cells = <Widget>[];

    for (int i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isMarked = markedDays.contains(day);
      final hasEvent = allEventDays.contains(day);
      final isSelected =
          _selectedDay != null &&
          _selectedDay!.year == year &&
          _selectedDay!.month == month &&
          _selectedDay!.day == day;

      cells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = DateTime(year, month, day);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.navyDark
                  : isMarked
                  ? AppColors.greenLight
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.navyDark
                    : isMarked
                    ? AppColors.greenIndicator
                    : AppColors.cardBorder,
                width: isMarked || isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.navyDark.withAlpha(35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected || isMarked
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isMarked
                        ? AppColors.greenIndicator
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (isMarked)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.greenBadge
                          : AppColors.greenIndicator,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (hasEvent)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white70
                          : AppColors.purpleAccent,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 7),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.05,
        children: cells,
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.greenIndicator,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Marked on Calendar',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.purpleAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Campus Event',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayHeader() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayStr =
        '${months[_selectedDay!.month - 1]} ${_selectedDay!.day}, ${_selectedDay!.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.purpleAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Events on $dayStr',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 38,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            const Text(
              'No events on this day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Check other highlighted dates on the calendar',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: events.map((event) {
          return EventCard(
            event: event,
            onTap: () => EventDetailsScreen.show(context, event),
            onCalendarTap: () {
              context.read<EventProvider>().toggleCalendarMark(event.id);
            },
            onBookmarkTap: () {
              context.read<EventProvider>().toggleSaveEvent(event.id);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHintSection(int eventCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.purpleLight.withAlpha(120),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.purpleBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.purpleAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                color: AppColors.purpleAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$eventCount marked date${eventCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purpleDarkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap any highlighted date to inspect events',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
