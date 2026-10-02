import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campos/state/event_provider.dart';
import 'package:campos/ui/screens/announcement_inbox_screen.dart';

void main() {
  group('AnnouncementInboxScreen & Review Form Tests', () {
    testWidgets(
      'renders app bar with back button, multiline text field, placeholder, character counter, and extract button',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        bool backTapped = false;

        await tester.pumpWidget(
          ChangeNotifierProvider<EventProvider>(
            create: (_) => EventProvider(),
            child: MaterialApp(
              home: AnnouncementInboxScreen(
                onBack: () {
                  backTapped = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. App bar title & back button
        expect(find.text('Announcement Inbox'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

        // 2. Multiline text field with placeholder
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is TextField &&
                w.decoration?.hintText?.contains(
                      'Paste your announcement here...',
                    ) ==
                    true,
          ),
          findsOneWidget,
        );

        // 3. Character counter (initial 0 characters)
        expect(find.text('0 characters'), findsOneWidget);

        // 4. Primary extraction button
        expect(find.text('+ Extract Event Details'), findsOneWidget);

        // Test back button
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        expect(backTapped, isTrue);
      },
    );

    testWidgets('typing or pasting text updates character counter', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<EventProvider>(
          create: (_) => EventProvider(),
          child: const MaterialApp(home: AnnouncementInboxScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final inputField = find.byType(TextField).first;
      await tester.enterText(
        inputField,
        'Join Google Developer Group hackathon this weekend!',
      );
      await tester.pumpAndSettle();

      // Expect character counter to reflect length (51 chars)
      expect(find.text('51 characters'), findsOneWidget);
    });

    testWidgets(
      'tapping extract button triggers visual loading state and reveals editable review form',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ChangeNotifierProvider<EventProvider>(
            create: (_) => EventProvider(),
            child: const MaterialApp(home: AnnouncementInboxScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Tap 'Load Sample' to populate input
        await tester.tap(find.text('Load Sample'));
        await tester.pumpAndSettle();

        // Tap '+ Extract Event Details'
        final extractButton = find.text('+ Extract Event Details');
        expect(extractButton, findsOneWidget);
        await tester.tap(extractButton);

        // Pump frame without settling to observe loading state
        await tester.pump(const Duration(milliseconds: 100));

        // Visual loading state check
        expect(find.text('Extracting Event Details...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Advance clock past the extraction simulation
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();

        // Extracted review & edit form appears
        expect(find.text('Review & Edit Event'), findsOneWidget);
        expect(find.text('AI Parsed • Editable'), findsOneWidget);

        // Form fields check: Title, Category, Event Date, Registration Deadline
        expect(find.text('Event Title'), findsOneWidget);
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Event Date'), findsOneWidget);
        expect(find.text('Registration Deadline'), findsOneWidget);

        // Pre-populated values check
        expect(find.text('ACM HackFest 2026'), findsOneWidget);
        expect(find.text('Sep 22, 2026'), findsOneWidget);
        expect(find.text('Sep 19, 2026'), findsOneWidget);

        // Save Event button is present
        expect(find.text('Save Event'), findsOneWidget);
      },
    );

    testWidgets(
      'editing fields and tapping Save Event updates local provider state with confirmation',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final provider = EventProvider();
        bool eventCreatedCallbackFired = false;

        await tester.pumpWidget(
          ChangeNotifierProvider<EventProvider>.value(
            value: provider,
            child: MaterialApp(
              home: AnnouncementInboxScreen(
                onEventCreated: () {
                  eventCreatedCallbackFired = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Load sample and extract
        await tester.tap(find.text('Load Sample'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+ Extract Event Details'));
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();

        // Modify event title in the editable form
        final titleFinder = find.widgetWithText(TextField, 'ACM HackFest 2026');
        expect(titleFinder, findsOneWidget);
        await tester.enterText(titleFinder, 'Campus Innovation Hackathon 2026');
        await tester.pumpAndSettle();

        // Select 'Tech' category
        await tester.tap(find.text('Tech'));
        await tester.pumpAndSettle();

        // Tap 'Save Event'
        await tester.tap(find.text('Save Event'));
        await tester.pumpAndSettle();

        // Confirmation SnackBar appears
        expect(
          find.text('Event saved! Added to your campus calendar & dashboard'),
          findsOneWidget,
        );

        // Callback fired
        expect(eventCreatedCallbackFired, isTrue);

        // Event is added to provider state with edits preserved
        final savedEvent = provider.events.firstWhere(
          (e) => e.eventName == 'Campus Innovation Hackathon 2026',
        );
        expect(savedEvent.categories.contains('Tech'), isTrue);
        expect(savedEvent.isCalendarMarked, isTrue);
      },
    );
  });
}
