import 'package:flutter_test/flutter_test.dart';
import 'package:campos/main.dart';

void main() {
  testWidgets('CampusPilot AI Home Screen Smoke Test', (
    WidgetTester tester,
  ) async {
    // Build CampusPilotApp and trigger a frame.
    await tester.pumpWidget(const CampusPilotApp());
    await tester.pump();

    // Verify header elements
    expect(find.text('Hi there! 👋'), findsOneWidget);
    expect(find.text("Here's your campus overview"), findsOneWidget);

    // Verify 4 Metric Card labels
    expect(find.text('Upcoming Events'), findsWidgets);
    expect(find.text('Deadlines This Week'), findsOneWidget);
    expect(find.text('Pending Tasks'), findsOneWidget);
    expect(find.text('New Announcements'), findsOneWidget);

    // Verify Announcement Banner
    expect(
      find.text('Have an announcement? Let AI extract event details'),
      findsOneWidget,
    );
  });
}
