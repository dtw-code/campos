import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campos/state/event_provider.dart';
import 'package:campos/ui/screens/home_screen.dart';

void main() {
  group('HomeScreen Comprehensive Tests', () {
    testWidgets('renders greeting, 4 metric cards, and announcement banner', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => EventProvider())],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('Hi there! 👋'), findsOneWidget);
      expect(find.text("Here's your campus overview"), findsOneWidget);
      expect(find.text('CP'), findsOneWidget);

      // 4 Metric cards verification
      expect(find.text('Upcoming Events'), findsWidgets);
      expect(find.text('Deadlines This Week'), findsOneWidget);
      expect(find.text('Pending Tasks'), findsOneWidget);
      expect(find.text('New Announcements'), findsOneWidget);

      // Verify specific metric counts from default metrics
      expect(find.text('5'), findsWidgets);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('12'), findsWidgets);

      // Announcement trigger banner verification
      expect(
        find.text('Have an announcement? Let AI extract event details'),
        findsOneWidget,
      );

      // Upcoming events section header verification
      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets(
      'triggers onNavigateToAiInbox when announcement banner is tapped',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        bool bannerTapped = false;

        await tester.pumpWidget(
          MultiProvider(
            providers: [ChangeNotifierProvider(create: (_) => EventProvider())],
            child: MaterialApp(
              home: HomeScreen(
                onNavigateToAiInbox: () {
                  bannerTapped = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final bannerFinder = find.text(
          'Have an announcement? Let AI extract event details',
        );
        await tester.ensureVisible(bannerFinder);
        await tester.tap(bannerFinder);
        await tester.pumpAndSettle();

        expect(bannerTapped, isTrue);
      },
    );

    testWidgets('triggers onSeeAllEvents when See all button is tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool seeAllTapped = false;

      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => EventProvider())],
          child: MaterialApp(
            home: HomeScreen(
              onSeeAllEvents: () {
                seeAllTapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final seeAllFinder = find.text('See all');
      await tester.ensureVisible(seeAllFinder);
      await tester.tap(seeAllFinder);
      await tester.pumpAndSettle();

      expect(seeAllTapped, isTrue);
    });

    testWidgets('tapping bookmark icon on event card toggles saved state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final provider = EventProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final bookmarkFinder = find.byTooltip('Save Event');
      expect(bookmarkFinder, findsWidgets);

      await tester.ensureVisible(bookmarkFinder.first);
      await tester.tap(bookmarkFinder.first);
      await tester.pumpAndSettle();

      expect(find.text('Event bookmarked!'), findsOneWidget);
    });

    testWidgets('tapping event card opens EventDetails modal bottom sheet', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => EventProvider())],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final eventTitleFinder = find.text(
        'HackMIT 2026: Campus Innovation Sprint',
      );
      expect(eventTitleFinder, findsOneWidget);

      await tester.ensureVisible(eventTitleFinder);
      await tester.tap(eventTitleFinder);
      await tester.pumpAndSettle();

      // Details sheet content
      expect(find.text('About This Event'), findsOneWidget);
      expect(find.text('Registration'), findsOneWidget);
      expect(find.text('Add to Calendar'), findsOneWidget);
      expect(find.text('Notion'), findsOneWidget);
    });
  });
}
