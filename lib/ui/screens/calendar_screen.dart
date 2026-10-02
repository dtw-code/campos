import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/event_provider.dart';
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
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
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

  /// Check if a day has events
  List<Event> _eventsForDay(List<Event> allEvents, DateTime day) {
    return allEvents.where((e) {
      return e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day;
    }).toList();
  }

  /// Collect all distinct event dates in the focused month for marker dots
  Set<int> _eventDaysInMonth(List<Event> allEvents) {
    final days = <int>{};
    for (final event in allEvents) {
      if (event.date.year == _focusedMonth.year &&
          event.date.month == _focusedMonth.month) {
        days.add(event.date.day);
      }
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final allEvents = provider.events;
    final eventDays = _eventDaysInMonth(allEvents);

    final selectedDayEvents = _selectedDay != null
        ? _eventsForDay(allEvents, _selectedDay!)
        : <Event>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Calendar Grid
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Month Navigation
                  _buildMonthNavigator(),

                  // Day of Week Labels
                  _buildDayOfWeekLabels(),

                  // Calendar Day Grid
                  _buildCalendarGrid(eventDays),

                  // Selected Day Events Section
                  if (_selectedDay != null) ...[
                    const SizedBox(height: 8),
                    _buildSelectedDayHeader(),
                    if (selectedDayEvents.isEmpty)
                      _buildNoEventsPlaceholder()
                    else
                      _buildEventsList(selectedDayEvents),
                  ] else ...[
                    const SizedBox(height: 24),
                    _buildHintSection(eventDays.length),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navySurface],
        ),
      ),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus Calendar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tap dates to see events',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Today shortcut
          GestureDetector(
            onTap: () {
              setState(() {
                final now = DateTime.now();
                _focusedMonth = DateTime(now.year, now.month);
                _selectedDay = DateTime(now.year, now.month, now.day);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greenBadge.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.greenBadge.withAlpha(60)),
              ),
              child: const Text(
                'Today',
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

  Widget _buildMonthNavigator() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final monthName = months[_focusedMonth.month - 1];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildArrowButton(Icons.chevron_left_rounded, _goToPreviousMonth),
          Text(
            '$monthName ${_focusedMonth.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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

  Widget _buildCalendarGrid(Set<int> eventDays) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon

    final now = DateTime.now();
    final isCurrentMonth = now.year == year && now.month == month;

    // Build grid cells
    final cells = <Widget>[];

    // Leading empty cells
    for (int i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final hasEvent = eventDays.contains(day);
      final isToday = isCurrentMonth && now.day == day;
      final isSelected = _selectedDay != null &&
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
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.navyDark
                  : isToday
                      ? AppColors.purpleLight
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.purpleAccent, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? AppColors.purpleAccent
                            : AppColors.textPrimary,
                  ),
                ),
                if (hasEvent)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.greenBadge
                          : AppColors.purpleAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.0,
        children: cells,
      ),
    );
  }

  Widget _buildSelectedDayHeader() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final dayStr = '${months[_selectedDay!.month - 1]} ${_selectedDay!.day}, ${_selectedDay!.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
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
          return _buildCalendarEventCard(event);
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarEventCard(Event event) {
    return GestureDetector(
      onTap: () => EventDetailsScreen.show(context, event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.navyDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    event.monthShort,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greenBadge,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    event.day,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Event info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: event.categories.take(2).map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.purpleLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purpleDarkText,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintSection(int eventCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purpleLight.withAlpha(180),
              AppColors.purpleLight.withAlpha(80),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.purpleBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.purpleAccent.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                color: AppColors.purpleAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$eventCount event${eventCount == 1 ? '' : 's'} this month',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purpleDarkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Tap on highlighted dates to see details',
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
