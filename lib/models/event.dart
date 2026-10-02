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
  final bool isCalendarMarked;
  final String organizer;
  final int minMembers;
  final int maxMembers;
  final List<String> checklist;
  final List<bool> checkedItems;

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
    this.isCalendarMarked = false,
    this.organizer = 'Campus Student Council',
    this.minMembers = 1,
    this.maxMembers = 4,
    this.checklist = const [],
    this.checkedItems = const [],
  });

  /// Generates a default prep checklist based on the event's primary category.
  static List<String> generateDefaultChecklist(String category) {
    final lower = category.toLowerCase();
    final common = [
      'Register on event portal',
      'Download event pass / confirmation',
      'Arrange transport to venue',
      'Charge devices & pack essentials',
    ];

    switch (lower) {
      case 'hackathon':
        return [
          ...common,
          'Form your team & assign roles',
          'Set up dev environment & tools',
          'Prepare project pitch outline',
          'Pack charger, headphones & snacks',
        ];
      case 'workshop':
        return [
          ...common,
          'Bring laptop with required software',
          'Review pre-requisite materials',
          'Prepare questions for the instructor',
        ];
      case 'career':
      case 'networking':
        return [
          ...common,
          'Update your resume / portfolio',
          'Prepare elevator pitch',
          'Research attending companies',
          'Dress professionally',
        ];
      case 'tech':
      case 'ai':
        return [
          ...common,
          'Read the event agenda & speaker bios',
          'Prepare discussion questions',
          'Bring notebook for key takeaways',
        ];
      case 'symposium':
      case 'keynote':
        return [
          ...common,
          'Read speaker abstracts',
          'Prepare networking introductions',
          'Bring business cards if available',
        ];
      default:
        return common;
    }
  }

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

  /// Formatted team / member range string (e.g. "Min: 2 • Max: 4 members")
  String get membersRange {
    if (minMembers == maxMembers) {
      return '$minMembers ${minMembers == 1 ? "member" : "members"} (Min: $minMembers, Max: $maxMembers)';
    }
    return 'Min: $minMembers • Max: $maxMembers members';
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

    final minM = json['min_members'] is int
        ? json['min_members'] as int
        : (json['minMembers'] is int ? json['minMembers'] as int : 1);
    final maxM = json['max_members'] is int
        ? json['max_members'] as int
        : (json['maxMembers'] is int ? json['maxMembers'] as int : 4);

    // Parse checklist
    List<String> parsedChecklist = [];
    if (json['checklist'] is List) {
      parsedChecklist = (json['checklist'] as List)
          .map((item) => item.toString())
          .toList();
    }
    List<bool> parsedCheckedItems = [];
    if (json['checked_items'] is List) {
      parsedCheckedItems = (json['checked_items'] as List)
          .map((item) => item == true)
          .toList();
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
      isCalendarMarked:
          json['is_calendar_marked'] ?? json['isCalendarMarked'] ?? false,
      organizer: json['organizer']?.toString() ?? 'Campus Pilot Committee',
      minMembers: minM,
      maxMembers: maxM,
      checklist: parsedChecklist,
      checkedItems: parsedCheckedItems,
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
      'is_calendar_marked': isCalendarMarked,
      'organizer': organizer,
      'min_members': minMembers,
      'max_members': maxMembers,
      'checklist': checklist,
      'checked_items': checkedItems,
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
    bool? isCalendarMarked,
    String? organizer,
    int? minMembers,
    int? maxMembers,
    List<String>? checklist,
    List<bool>? checkedItems,
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
      isCalendarMarked: isCalendarMarked ?? this.isCalendarMarked,
      organizer: organizer ?? this.organizer,
      minMembers: minMembers ?? this.minMembers,
      maxMembers: maxMembers ?? this.maxMembers,
      checklist: checklist ?? this.checklist,
      checkedItems: checkedItems ?? this.checkedItems,
    );
  }
}
