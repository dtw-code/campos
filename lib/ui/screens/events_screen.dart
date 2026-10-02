import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/event_provider.dart';
import '../components/event_card.dart';
import '../theme/app_colors.dart';
import 'event_details_screen.dart';

enum EventViewMode { calendar, list }

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventViewMode _viewMode = EventViewMode.calendar;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Calendar navigation state (defaulting to Aug 2026 to showcase the Aug 28 Hackathon)
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  final List<String> _categories = [
    'All',
    'Marked',
    'Hackathon',
    'Tech',
    'Workshop',
    'Career',
    'Saved',
  ];

  @override
  void initState() {
    super.initState();
    // Default to August 2026 so August 28 HackMIT hackathon is immediately visible
    _focusedMonth = DateTime(2026, 8);
    _selectedDay = DateTime(2026, 8, 28);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final allEvents = provider.upcomingEvents;

    // Filter events by query and category
    final filteredEvents = allEvents.where((event) {
      final query = _searchController.text.trim().toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          event.eventName.toLowerCase().contains(query) ||
          event.venue.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Marked') return event.isCalendarMarked;
      if (_selectedCategory == 'Saved') return event.isSaved;

      return event.categories.any(
        (c) => c.toLowerCase() == _selectedCategory.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyDark,
        elevation: 0,
        title: const Text(
          'Campus Events & Calendar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          // Quick view mode switcher icon in app bar
          IconButton(
            icon: Icon(
              _viewMode == EventViewMode.calendar
                  ? Icons.view_agenda_outlined
                  : Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            tooltip: _viewMode == EventViewMode.calendar
                ? 'Switch to List View'
                : 'Switch to Calendar View',
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == EventViewMode.calendar
                    ? EventViewMode.list
                    : EventViewMode.calendar;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with View Mode Switcher
          _buildTopControls(),

          // Main Content: Calendar View or List View
          Expanded(
            child: _viewMode == EventViewMode.calendar
                ? _buildCalendarView(provider, allEvents)
                : _buildListView(provider, filteredEvents),
          ),
        ],
      ),
    );
  }

  /// Top controls with View Mode segmented toggle and quick hint
  Widget _buildTopControls() {
    return Container(
      color: AppColors.navyDark,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Segmented Button Toggle: Calendar View vs List View
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.navySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _viewMode = EventViewMode.calendar;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _viewMode == EventViewMode.calendar
                            ? AppColors.purpleAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: _viewMode == EventViewMode.calendar
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Calendar View',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _viewMode == EventViewMode.calendar
                                  ? Colors.white
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _viewMode = EventViewMode.list;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _viewMode == EventViewMode.list
                            ? AppColors.purpleAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_agenda_rounded,
                            size: 16,
                            color: _viewMode == EventViewMode.list
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'All Events List',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _viewMode == EventViewMode.list
                                  ? Colors.white
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// CALENDAR VIEW: Shows monthly grid, marked dates (e.g. Aug 28), and events on the selected date
  Widget _buildCalendarView(EventProvider provider, List<Event> allEvents) {
    // Collect day numbers in focused month that have calendar-marked events
    final markedDays = provider.getCalendarMarkedDays(
      _focusedMonth.year,
      _focusedMonth.month,
    );

    // Also collect all event days for regular indicators
    final allEventDaysInMonth = <int>{};
    for (final e in allEvents) {
      if (e.date.year == _focusedMonth.year &&
          e.date.month == _focusedMonth.month) {
        allEventDaysInMonth.add(e.date.day);
      }
    }

    // Events matching the currently selected day
    final selectedDayEvents = _selectedDay != null
        ? allEvents.where((e) {
            return e.date.year == _selectedDay!.year &&
                e.date.month == _selectedDay!.month &&
                e.date.day == _selectedDay!.day;
          }).toList()
        : <Event>[];

    const monthNames = [
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
    final currentMonthName = monthNames[_focusedMonth.month - 1];

    return RefreshIndicator(
      onRefresh: () => provider.fetchDashboardData(forceRefresh: true),
      color: AppColors.purpleAccent,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Month navigation header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.navyDark,
                    ),
                    onPressed: _goToPreviousMonth,
                  ),
                  Column(
                    children: [
                      Text(
                        '$currentMonthName ${_focusedMonth.year}',
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (markedDays.isNotEmpty)
                        Text(
                          '${markedDays.length} date${markedDays.length == 1 ? '' : 's'} marked by you',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenIndicator,
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.navyDark,
                    ),
                    onPressed: _goToNextMonth,
                  ),
                ],
              ),
            ),
          ),

          // Day of week labels
          _buildCalendarWeekHeader(),

          // Monthly Calendar Grid
          _buildMonthGrid(allEventDaysInMonth, markedDays),

          // Legend indicator bar
          _buildCalendarLegend(markedDays.length),

          const SizedBox(height: 10),

          // Selected Day Event Header & List
          _buildSelectedDayEventsSection(selectedDayEvents, allEvents),
        ],
      ),
    );
  }

  Widget _buildCalendarWeekHeader() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: days.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
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

  Widget _buildMonthGrid(Set<int> allEventDays, Set<int> markedDays) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday; // 1 = Monday

    final cells = <Widget>[];

    // Padding empty cells before the 1st of month
    for (int i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Days 1..daysInMonth
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
                        color: AppColors.navyDark.withAlpha(40),
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
                // Indicator dots
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

  Widget _buildCalendarLegend(int markedCount) {
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
                'Marked by You',
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

  Widget _buildSelectedDayEventsSection(
    List<Event> dayEvents,
    List<Event> allEvents,
  ) {
    const monthNames = [
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

    final dateStr = _selectedDay != null
        ? '${monthNames[_selectedDay!.month - 1]} ${_selectedDay!.day}, ${_selectedDay!.year}'
        : 'Select a Date';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with selected date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Events on $dateStr',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_selectedDay != null && dayEvents.isNotEmpty)
                Text(
                  '${dayEvents.length} event${dayEvents.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (dayEvents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_note_rounded,
                    size: 36,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No events scheduled on this day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap highlighted dates on the calendar or browse all events',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ...dayEvents.map((event) {
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
            }),
        ],
      ),
    );
  }

  /// LIST VIEW: Shows search bar, filter chips, and all events
  Widget _buildListView(EventProvider provider, List<Event> events) {
    return Column(
      children: [
        // Search and Filters Header
        Container(
          color: AppColors.navyDark,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // Search input
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search events, topics, or venues...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.navySurface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Category Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        backgroundColor: AppColors.navySurface,
                        selectedColor: AppColors.purpleAccent,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.purpleAccent
                                : Colors.white12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Events list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.fetchDashboardData(forceRefresh: true),
            color: AppColors.purpleAccent,
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No matching events found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try adjusting your search filters',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        onTap: () => EventDetailsScreen.show(context, event),
                        onCalendarTap: () {
                          context.read<EventProvider>().toggleCalendarMark(
                            event.id,
                          );
                        },
                        onBookmarkTap: () {
                          context.read<EventProvider>().toggleSaveEvent(
                            event.id,
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
