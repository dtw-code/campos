import 'package:flutter/foundation.dart';
import '../models/campus_metrics.dart';
import '../models/event.dart';
import '../service/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService;

  List<Event> _events = [];
  CampusMetrics _metrics = const CampusMetrics();
  bool _isLoading = false;
  String? _errorMessage;

  EventProvider({EventService? eventService})
    : _eventService = eventService ?? EventService() {
    // Initial fetch of dashboard data
    fetchDashboardData();
  }

  // Getters
  List<Event> get events => List.unmodifiable(_events);

  /// Upcoming events sorted by date
  List<Event> get upcomingEvents {
    final list = List<Event>.from(_events);
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<Event> get savedEvents => _events.where((e) => e.isSaved).toList();

  /// Events added to calendar by the student
  List<Event> get calendarMarkedEvents =>
      _events.where((e) => e.isCalendarMarked).toList();

  /// Returns whether a specific event is marked on the calendar
  bool isEventMarkedOnCalendar(String eventId) {
    return _events.any((e) => e.id == eventId && e.isCalendarMarked);
  }

  /// Returns the day of month set for events marked on the calendar in a given year and month
  Set<int> getCalendarMarkedDays(int year, int month) {
    final days = <int>{};
    for (final event in _events) {
      if (event.isCalendarMarked &&
          event.date.year == year &&
          event.date.month == month) {
        days.add(event.date.day);
      }
    }
    return days;
  }

  CampusMetrics get metrics => _metrics;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  /// Load dashboard data: upcoming events and campus metrics
  Future<void> fetchDashboardData({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _eventService.getEvents(),
        _eventService.getMetrics(),
      ]);

      _events = results[0] as List<Event>;
      _metrics = results[1] as CampusMetrics;
      // Keep upcoming count in sync with list length if valid
      if (_events.isNotEmpty &&
          _metrics.upcomingEventsCount != _events.length) {
        _metrics = _metrics.copyWith(upcomingEventsCount: _events.length);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Could not load campus events. Please try again.';
      debugPrint('[EventProvider] Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle saved/bookmarked status of an event
  Future<void> toggleSaveEvent(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final target = _events[index];
    final updatedStatus = !target.isSaved;

    // Optimistic UI update
    _events[index] = target.copyWith(isSaved: updatedStatus);
    notifyListeners();

    try {
      await _eventService.toggleSaveEvent(eventId, updatedStatus);
    } catch (e) {
      // Rollback if failure
      _events[index] = target;
      notifyListeners();
      debugPrint('[EventProvider] Failed to toggle save: $e');
    }
  }

  /// Toggle calendar marked status of an event (instant local state update)
  bool toggleCalendarMark(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return false;

    final target = _events[index];
    final newCalendarStatus = !target.isCalendarMarked;

    _events[index] = target.copyWith(isCalendarMarked: newCalendarStatus);
    notifyListeners();
    return newCalendarStatus;
  }

  /// Add a newly created event (e.g. extracted from AI announcement inbox)
  void addEvent(Event newEvent) {
    _events.insert(0, newEvent);
    _metrics = _metrics.copyWith(
      upcomingEventsCount: _events.length,
      newAnnouncementsCount: (_metrics.newAnnouncementsCount - 1).clamp(0, 999),
    );
    notifyListeners();
    _eventService.createEventFromAnnouncement(newEvent);
  }
}
