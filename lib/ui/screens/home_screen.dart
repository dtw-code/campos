import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/event_provider.dart';
import '../../state/role_provider.dart';
import '../components/announcement_banner.dart';
import '../components/event_card.dart';
import '../components/metric_card.dart';
import '../theme/app_colors.dart';
import 'ai_inbox_screen.dart';
import 'event_details_screen.dart';
import 'events_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToAiInbox;
  final VoidCallback? onSeeAllEvents;

  const HomeScreen({super.key, this.onNavigateToAiInbox, this.onSeeAllEvents});

  void _handleNavigateToAi(BuildContext context) {
    if (onNavigateToAiInbox != null) {
      onNavigateToAiInbox!();
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AiInboxScreen()));
    }
  }

  void _handleSeeAll(BuildContext context) {
    if (onSeeAllEvents != null) {
      onSeeAllEvents!();
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const EventsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final metrics = eventProvider.metrics;
    final events = eventProvider.upcomingEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => eventProvider.fetchDashboardData(forceRefresh: true),
        color: AppColors.purpleAccent,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Deep Navy background
              _buildHeaderSection(context),

              // Main Body Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Metrics Grid (2x2)
                    _buildMetricsGrid(context, metrics),

                    const SizedBox(height: 20),

                    // AI Announcement Trigger Banner
                    AnnouncementBanner(
                      onTap: () => _handleNavigateToAi(context),
                    ),

                    const SizedBox(height: 24),

                    // Upcoming Events Section Header
                    _buildSectionHeader(context),

                    const SizedBox(height: 12),

                    // Upcoming Events List / States
                    _buildEventsSection(context, eventProvider, events),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Deep Navy Header Widget with greeting, role toggle, and profile avatar
  Widget _buildHeaderSection(BuildContext context) {
    final roleProvider = context.watch<RoleProvider>();
    final isCoordinator = roleProvider.isCoordinator;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Greeting Text Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hi there! 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCoordinator
                              ? 'Coordinator Dashboard'
                              : "Here's your campus overview",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circular User Profile Avatar with active status badge
                  Stack(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(50),
                            width: 2,
                          ),
                          gradient: const LinearGradient(
                            colors: [AppColors.navyAccent, Color(0xFF475569)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'CP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Green online indicator badge
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.greenBadge,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.navyDark,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Role Toggle Chip
              GestureDetector(
                onTap: () {
                  roleProvider.toggleRole();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            roleProvider.isCoordinator
                                ? Icons.admin_panel_settings_rounded
                                : Icons.school_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Switched to ${roleProvider.roleLabel} mode',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: roleProvider.isCoordinator
                          ? AppColors.purpleAccent
                          : AppColors.navySurface,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCoordinator
                        ? AppColors.purpleAccent.withAlpha(35)
                        : Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCoordinator
                          ? AppColors.purpleAccent.withAlpha(80)
                          : Colors.white.withAlpha(30),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isCoordinator
                              ? Icons.admin_panel_settings_rounded
                              : Icons.school_rounded,
                          key: ValueKey(isCoordinator),
                          color: isCoordinator
                              ? AppColors.purpleAccent
                              : AppColors.greenBadge,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          'Mode: ${roleProvider.roleLabel}',
                          key: ValueKey(roleProvider.roleLabel),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isCoordinator
                                ? AppColors.purpleAccent
                                : Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          key: ValueKey(isCoordinator),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCoordinator
                                ? AppColors.purpleAccent
                                : AppColors.greenBadge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2x2 Summary Metrics Grid displaying four distinct indicators
  Widget _buildMetricsGrid(BuildContext context, dynamic metrics) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.28,
      children: [
        // 1. Upcoming Events (green indicator)
        MetricCard(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.greenIndicator,
          iconBackgroundColor: AppColors.greenLight,
          count: metrics.upcomingEventsCount,
          label: 'Upcoming Events',
          onTap: () => _handleSeeAll(context),
        ),
        // 2. Deadlines This Week (pink/red indicator)
        MetricCard(
          icon: Icons.alarm_rounded,
          iconColor: AppColors.pinkIndicator,
          iconBackgroundColor: AppColors.pinkLight,
          count: metrics.deadlinesThisWeekCount,
          label: 'Deadlines This Week',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('3 project & assignment deadlines due this week'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        // 3. Pending Tasks (teal indicator)
        MetricCard(
          icon: Icons.assignment_turned_in_rounded,
          iconColor: AppColors.tealIndicator,
          iconBackgroundColor: AppColors.tealLight,
          count: metrics.pendingTasksCount,
          label: 'Pending Tasks',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('7 campus tasks & registrations pending'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        // 4. New Announcements (purple indicator)
        MetricCard(
          icon: Icons.campaign_rounded,
          iconColor: AppColors.purpleIndicator,
          iconBackgroundColor: AppColors.purpleLight,
          count: metrics.newAnnouncementsCount,
          label: 'New Announcements',
          onTap: () => _handleNavigateToAi(context),
        ),
      ],
    );
  }

  /// Section Header Row with "Upcoming Events" title and "See all" button
  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        TextButton(
          onPressed: () => _handleSeeAll(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.purpleAccent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            children: [
              Text(
                'See all',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  /// Events Section handling Loading, Error, Empty, and Success states
  Widget _buildEventsSection(
    BuildContext context,
    EventProvider provider,
    List<Event> events,
  ) {
    // 1. Loading State
    if (provider.isLoading && events.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.purpleAccent,
              strokeWidth: 2.5,
            ),
            SizedBox(height: 12),
            Text(
              'Loading campus events...',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // 2. Error State with Retry Button
    if (provider.hasError && events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.pinkLight),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.pinkIndicator,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Unable to connect to campus backend',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => provider.fetchDashboardData(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // 3. Empty State
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 10),
            Text(
              'No upcoming events right now',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pull down to refresh or extract new events with AI',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    // 4. Success State: List of Event Cards
    return Column(
      children: events.map((event) {
        return EventCard(
          event: event,
          onTap: () => EventDetailsScreen.show(context, event),
          onCalendarTap: () {
            final isMarked = provider.toggleCalendarMark(event.id);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isMarked
                      ? 'Marked on calendar for ${event.monthShort} ${event.day}!'
                      : 'Removed from calendar',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onBookmarkTap: () {
            provider.toggleSaveEvent(event.id);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  event.isSaved
                      ? 'Event removed from saved list'
                      : 'Event bookmarked!',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
