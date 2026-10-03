import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campos/models/event.dart';
import 'package:campos/state/event_provider.dart';
import 'package:campos/ui/screens/event_details_screen.dart';
import 'package:campos/ui/screens/events_screen.dart';

void main() {
  group('Calendar Marking & Event Details Modal Tests', () {
    testWidgets(
      'displays Event Details modal with About section and the 3 action buttons',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final testEvent = Event(
          id: 'test-hackathon',
          eventName: 'Campus Innovation Hackathon',
          description:
              'A premier 24-hour hackathon for student developers and designers.',
          date: DateTime(2026, 8, 28, 10, 0),
          time: '10:00 AM - 4:00 PM',
          venue: 'Grand Ballroom',
          categories: ['Hackathon', 'Tech'],
          registrationUrl: 'https://hackathon.example.edu/register',
          minMembers: 2,
          maxMembers: 4,
        );

        final provider = EventProvider();

        await tester.pumpWidget(
          ChangeNotifierProvider<EventProvider>.value(
            value: provider,
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () =>
                          EventDetailsScreen.show(context, testEvent),
                      child: const Text('Open Modal'),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap to open modal
        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        // Verify Event Title & About Section
        expect(find.text('Campus Innovation Hackathon'), findsOneWidget);
        expect(find.text('About This Event'), findsOneWidget);
        expect(
          find.text(
            'A premier 24-hour hackathon for student developers and designers.',
          ),
          findsOneWidget,
        );

        // Verify Number of Members icon, min and max numbers
        expect(find.text('Team Size / Members'), findsOneWidget);
        expect(find.text('Min: 2 • Max: 4 members'), findsOneWidget);
        expect(find.byIcon(Icons.people_alt_rounded), findsOneWidget);

        // Verify the 3 action buttons:
        // 1. Registration button
        expect(find.text('Registration'), findsOneWidget);

        // 2. Add to Calendar button
        expect(find.text('Add to Calendar'), findsOneWidget);

        // 3. Notion button
        expect(find.text('Notion'), findsOneWidget);
      },
    );

    testWidgets('Tapping Add to Calendar marks event date dynamically', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testEvent = Event(
        id: 'evt-101',
        eventName: 'HackMIT 2026: Campus Innovation Sprint',
        description: '36-hour hackathon.',
        date: DateTime(2026, 8, 28, 10, 0),
        time: '10:00 AM - 4:00 PM',
        venue: 'Student Center Hall A',
        categories: ['Hackathon'],
      );

      final provider = EventProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<EventProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () =>
                        EventDetailsScreen.show(context, testEvent),
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap 'Add to Calendar'
      expect(find.text('Add to Calendar'), findsOneWidget);
      await tester.tap(find.text('Add to Calendar'));
      await tester.pumpAndSettle();

      // State is updated to Marked in Calendar
      expect(find.text('Marked in Calendar'), findsOneWidget);
      expect(provider.isEventMarkedOnCalendar('evt-101'), isTrue);
      expect(provider.getCalendarMarkedDays(2026, 8).contains(28), isTrue);
    });

    testWidgets('EventsScreen renders Calendar View and highlights August 28', (
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
        ChangeNotifierProvider<EventProvider>.value(
          value: provider,
          child: const MaterialApp(home: EventsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Top view switcher
      expect(find.text('Calendar View'), findsOneWidget);
      expect(find.text('All Events List'), findsOneWidget);

      // August 2026 is visible
      expect(find.text('August 2026'), findsOneWidget);

      // Date 28 is displayed in the calendar
      expect(find.text('28'), findsWidgets);

      // Legend is present
      expect(find.text('Marked by You'), findsOneWidget);
      expect(find.text('Campus Event'), findsOneWidget);
    });
  });
}
