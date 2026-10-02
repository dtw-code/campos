import 'package:flutter/material.dart';
import '../components/app_bottom_nav.dart';
import 'ai_inbox_screen.dart';
import 'events_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _switchTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToAiInbox: () => _switchTab(1),
        onSeeAllEvents: () => _switchTab(2),
      ),
      AnnouncementInboxScreen(
        onEventCreated: () => _switchTab(2),
        onBack: () => _switchTab(0),
      ),
      const EventsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}
