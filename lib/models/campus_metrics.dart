class CampusMetrics {
  final int upcomingEventsCount;
  final int deadlinesThisWeekCount;
  final int pendingTasksCount;
  final int newAnnouncementsCount;

  const CampusMetrics({
    this.upcomingEventsCount = 5,
    this.deadlinesThisWeekCount = 3,
    this.pendingTasksCount = 7,
    this.newAnnouncementsCount = 12,
  });

  factory CampusMetrics.fromJson(Map<String, dynamic> json) {
    return CampusMetrics(
      upcomingEventsCount:
          json['upcoming_events_count'] ?? json['upcomingEventsCount'] ?? 5,
      deadlinesThisWeekCount:
          json['deadlines_this_week_count'] ??
          json['deadlinesThisWeekCount'] ??
          3,
      pendingTasksCount:
          json['pending_tasks_count'] ?? json['pendingTasksCount'] ?? 7,
      newAnnouncementsCount:
          json['new_announcements_count'] ??
          json['newAnnouncementsCount'] ??
          12,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upcoming_events_count': upcomingEventsCount,
      'deadlines_this_week_count': deadlinesThisWeekCount,
      'pending_tasks_count': pendingTasksCount,
      'new_announcements_count': newAnnouncementsCount,
    };
  }

  CampusMetrics copyWith({
    int? upcomingEventsCount,
    int? deadlinesThisWeekCount,
    int? pendingTasksCount,
    int? newAnnouncementsCount,
  }) {
    return CampusMetrics(
      upcomingEventsCount: upcomingEventsCount ?? this.upcomingEventsCount,
      deadlinesThisWeekCount:
          deadlinesThisWeekCount ?? this.deadlinesThisWeekCount,
      pendingTasksCount: pendingTasksCount ?? this.pendingTasksCount,
      newAnnouncementsCount:
          newAnnouncementsCount ?? this.newAnnouncementsCount,
    );
  }
}
