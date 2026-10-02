import 'package:flutter/foundation.dart';
import '../models/campus_metrics.dart';
import '../models/event.dart';
import 'api_client.dart';

class EventService {
  final ApiClient _apiClient;

  EventService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Mock upcoming campus events matching the prompt visual analysis and specifications
  static final List<Event> _mockEvents = [
    Event(
      id: 'evt-101',
      eventName: 'HackMIT 2026: Campus Innovation Sprint',
      description:
          'Join 500+ builders, designers, and innovators for a 36-hour hackathon focused on AI agents, IoT devices, and campus productivity solutions.',
      date: DateTime(2026, 8, 28, 10, 0),
      time: '10:00 AM - 4:00 PM',
      venue: 'Student Center Hall A',
      categories: ['Hackathon', 'Tech', 'AI'],
      registrationDeadline: DateTime(2026, 8, 25, 23, 59),
      registrationUrl: 'https://hackmit.example.edu/register',
      isSaved: false,
      organizer: 'MIT Tech Club',
    ),
    Event(
      id: 'evt-102',
      eventName: 'Annual AI & Robotics Research Symposium',
      description:
          'Faculty keynotes, live autonomous drone demonstrations, and student research poster sessions showcasing breakthroughs in generative neural systems.',
      date: DateTime(2026, 9, 2, 14, 0),
      time: '02:00 PM - 6:00 PM',
      venue: 'Engineering Quad, Room 102',
      categories: ['Tech', 'AI', 'Symposium'],
      registrationDeadline: DateTime(2026, 8, 31, 18, 0),
      registrationUrl: 'https://robotics.example.edu/symposium',
      isSaved: true,
      organizer: 'Robotics Lab',
    ),
    Event(
      id: 'evt-103',
      eventName: 'Design Systems in Flutter Workshop',
      description:
          'Hands-on workshop exploring custom render objects, fluid micro-interactions, responsive widget hierarchies, and cohesive design tokens.',
      date: DateTime(2026, 9, 5, 11, 0),
      time: '11:00 AM - 1:00 PM',
      venue: 'Innovation Lab 204',
      categories: ['Workshop', 'Design', 'Mobile'],
      registrationDeadline: DateTime(2026, 9, 4, 12, 0),
      registrationUrl: 'https://gdg.example.edu/flutter-ds',
      isSaved: false,
      organizer: 'Google Developer Group On Campus',
    ),
    Event(
      id: 'evt-104',
      eventName: 'Fall Campus Tech Career & Internship Fair',
      description:
          'Connect directly with hiring engineers and alumni recruiters from 40+ premier tech organizations, startups, and research institutes.',
      date: DateTime(2026, 9, 12, 9, 30),
      time: '09:30 AM - 3:30 PM',
      venue: 'Athletics Complex Arena',
      categories: ['Career', 'Networking'],
      registrationDeadline: DateTime(2026, 9, 10, 17, 0),
      registrationUrl: 'https://careers.example.edu/fall-fair',
      isSaved: false,
      organizer: 'Career Services Office',
    ),
    Event(
      id: 'evt-105',
      eventName: 'Web3 & Decentralized Architecture Keynote',
      description:
          'A deep dive into distributed systems, cryptographic proof protocols, and practical governance in modern web infrastructure.',
      date: DateTime(2026, 9, 18, 16, 0),
      time: '04:00 PM - 7:30 PM',
      venue: 'Science Block Auditorium',
      categories: ['Tech', 'Web3', 'Keynote'],
      registrationDeadline: DateTime(2026, 9, 16, 20, 0),
      registrationUrl: 'https://blockchain.example.edu/keynote',
      isSaved: false,
      organizer: 'Computer Science Department',
    ),
  ];

  static const CampusMetrics _mockMetrics = CampusMetrics(
    upcomingEventsCount: 5,
    deadlinesThisWeekCount: 3,
    pendingTasksCount: 7,
    newAnnouncementsCount: 12,
  );

  /// Fetch events from backend API (GET /events) or fallback to realistic mock data
  Future<List<Event>> getEvents() async {
    try {
      final data = await _apiClient.get('/events');
      if (data is List) {
        return data
            .map((item) => Event.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['events'] is List) {
        return (data['events'] as List)
            .map((item) => Event.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint(
        '[EventService] Backend offline or unreachable. Using mock events: $e',
      );
    }

    // Offline fallback for seamless development & hackathon demo
    return List<Event>.from(_mockEvents);
  }

  /// Fetch campus dashboard metrics from backend API (GET /metrics) or fallback
  Future<CampusMetrics> getMetrics() async {
    try {
      final data = await _apiClient.get('/metrics');
      if (data is Map<String, dynamic>) {
        return CampusMetrics.fromJson(data);
      }
    } catch (e) {
      debugPrint(
        '[EventService] Backend offline or unreachable. Using mock metrics: $e',
      );
    }

    return _mockMetrics;
  }

  /// Toggle saved / bookmarked status of an event
  Future<bool> toggleSaveEvent(String eventId, bool newStatus) async {
    try {
      await _apiClient.post('/events/$eventId/save', {'is_saved': newStatus});
      return newStatus;
    } catch (e) {
      debugPrint(
        '[EventService] Saved state updated locally (offline mode): $e',
      );
      return newStatus;
    }
  }

  /// Save new event extracted by AI from an announcement
  Future<Event> createEventFromAnnouncement(Event event) async {
    try {
      final data = await _apiClient.post('/events', event.toJson());
      if (data is Map<String, dynamic>) {
        return Event.fromJson(data);
      }
    } catch (e) {
      debugPrint('[EventService] Event created locally (offline mode): $e');
    }
    return event;
  }
}
