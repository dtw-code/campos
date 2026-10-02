import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/event_provider.dart';
import '../components/event_card.dart';
import '../theme/app_colors.dart';
import 'event_details_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Hackathon',
    'Tech',
    'Workshop',
    'Career',
    'Saved',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final allEvents = provider.upcomingEvents;

    final filteredEvents = allEvents.where((event) {
      final query = _searchController.text.trim().toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          event.eventName.toLowerCase().contains(query) ||
          event.venue.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedCategory == 'All') return true;
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
      ),
      body: Column(
        children: [
          // Search & Filter header container
          Container(
            color: AppColors.navyDark,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search bar
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
              child: filteredEvents.isEmpty
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
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return EventCard(
                          event: event,
                          onTap: () => EventDetailsScreen.show(context, event),
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
      ),
    );
  }
}
