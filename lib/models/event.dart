class Event {
  final String id;
  final String eventName;
  final String description;
  final DateTime date;
  final String time;
  final String venue;
  final List<String> categories;
  final DateTime? registrationDeadline;
  final String? registrationUrl;
  final bool isSaved;
  final String organizer;

  const Event({
    required this.id,
    required this.eventName,
    required this.description,
    required this.date,
    required this.time,
    required this.venue,
    required this.categories,
    this.registrationDeadline,
    this.registrationUrl,
    this.isSaved = false,
    this.organizer = 'Campus Student Council',
  });

  /// Compatibility getter for title
  String get title => eventName;

  /// Convenience getter for the primary category
  String get category => categories.isNotEmpty ? categories.first : 'General';

  /// Convenience getter for 3-letter uppercase month (e.g. "AUG")
  String get monthShort {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final index = date.month - 1;
    if (index >= 0 && index < months.length) {
      return months[index];
    }
    return '';
  }

  /// Convenience getter for day of the month string (e.g. "28")
  String get day => date.day.toString().padLeft(2, '0');

  /// Formatted date string (e.g. "Aug 28, 2026")
  String get formattedDate {
    const monthsFull = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = monthsFull[date.month - 1];
    return '$m ${date.day}, ${date.year}';
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parse date safely
    DateTime parsedDate;
    if (json['date'] is String) {
      parsedDate = DateTime.tryParse(json['date'] as String) ?? DateTime.now();
    } else if (json['date'] is DateTime) {
      parsedDate = json['date'] as DateTime;
    } else {
      parsedDate = DateTime.now();
    }

    DateTime? deadline;
    if (json['registration_deadline'] is String) {
      deadline = DateTime.tryParse(json['registration_deadline'] as String);
    } else if (json['registrationDeadline'] is String) {
      deadline = DateTime.tryParse(json['registrationDeadline'] as String);
    }

    // Categories list parsing
    List<String> parsedCategories = [];
    if (json['categories'] is List) {
      parsedCategories = (json['categories'] as List)
          .map((item) => item.toString())
          .toList();
    } else if (json['category'] is String) {
      parsedCategories = [json['category'] as String];
    }

    return Event(
      id: json['id']?.toString() ?? '',
      eventName: json['event_name'] ?? json['eventName'] ?? json['title'] ?? '',
      description: json['description']?.toString() ?? '',
      date: parsedDate,
      time: json['time']?.toString() ?? 'TBD',
      venue: json['venue'] ?? json['location'] ?? 'Campus Campus Center',
      categories: parsedCategories.isNotEmpty ? parsedCategories : ['Campus'],
      registrationDeadline: deadline,
      registrationUrl: json['registration_url'] ?? json['registrationUrl'],
      isSaved: json['is_saved'] ?? json['isSaved'] ?? false,
      organizer: json['organizer']?.toString() ?? 'Campus Pilot Committee',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_name': eventName,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'venue': venue,
      'categories': categories,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'registration_url': registrationUrl,
      'is_saved': isSaved,
      'organizer': organizer,
    };
  }

  Event copyWith({
    String? id,
    String? eventName,
    String? description,
    DateTime? date,
    String? time,
    String? venue,
    List<String>? categories,
    DateTime? registrationDeadline,
    String? registrationUrl,
    bool? isSaved,
    String? organizer,
  }) {
    return Event(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      categories: categories ?? this.categories,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      isSaved: isSaved ?? this.isSaved,
      organizer: organizer ?? this.organizer,
    );
  }
}
