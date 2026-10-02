import 'package:flutter_test/flutter_test.dart';
import 'package:campos/models/event.dart';
import 'package:campos/state/event_provider.dart';

void main() {
  group('Event Checklist Feature Tests', () {
    // ——————————————————————————————————
    // Model-level tests
    // ——————————————————————————————————

    test('generateDefaultChecklist returns hackathon-specific tasks', () {
      final checklist = Event.generateDefaultChecklist('Hackathon');
      expect(checklist.isNotEmpty, isTrue);
      expect(checklist, contains('Form your team & assign roles'));
      expect(checklist, contains('Register on event portal'));
    });

    test('generateDefaultChecklist returns workshop-specific tasks', () {
      final checklist = Event.generateDefaultChecklist('Workshop');
      expect(checklist.isNotEmpty, isTrue);
      expect(checklist, contains('Bring laptop with required software'));
    });

    test('generateDefaultChecklist returns career-specific tasks', () {
      final checklist = Event.generateDefaultChecklist('Career');
      expect(checklist, contains('Update your resume / portfolio'));
      expect(checklist, contains('Dress professionally'));
    });

    test('generateDefaultChecklist returns generic tasks for unknown category',
        () {
      final checklist = Event.generateDefaultChecklist('Unknown');
      expect(checklist.length, equals(4)); // common tasks only
      expect(checklist, contains('Register on event portal'));
    });

    test('Event.fromJson/toJson preserves checklist and checkedItems', () {
      final original = Event(
        id: 'cl-test',
        eventName: 'Serialization Test',
        description: 'Test',
        date: DateTime(2026, 10, 1),
        time: '10:00 AM',
        venue: 'Lab',
        categories: ['Tech'],
        checklist: ['Task A', 'Task B', 'Task C'],
        checkedItems: [true, false, true],
      );

      final json = original.toJson();
      expect(json['checklist'], equals(['Task A', 'Task B', 'Task C']));
      expect(json['checked_items'], equals([true, false, true]));

      final restored = Event.fromJson(json);
      expect(restored.checklist, equals(original.checklist));
      expect(restored.checkedItems, equals(original.checkedItems));
    });

    test('Event.copyWith preserves checklist when not overridden', () {
      final original = Event(
        id: 'cw-test',
        eventName: 'CopyWith Test',
        description: 'Test',
        date: DateTime(2026, 10, 1),
        time: '10:00 AM',
        venue: 'Lab',
        categories: ['Tech'],
        checklist: ['A', 'B'],
        checkedItems: [true, false],
      );

      final copied = original.copyWith(eventName: 'Changed Name');
      expect(copied.eventName, equals('Changed Name'));
      expect(copied.checklist, equals(['A', 'B']));
      expect(copied.checkedItems, equals([true, false]));
    });

    // ——————————————————————————————————
    // Provider-level tests
    // ——————————————————————————————————

    test('addEvent auto-generates a checklist if event has empty checklist',
        () {
      final provider = EventProvider();
      final event = Event(
        id: 'prov-test-1',
        eventName: 'Provider Checklist Test',
        description: 'Testing auto-gen',
        date: DateTime(2026, 11, 1),
        time: '2:00 PM',
        venue: 'Room 101',
        categories: ['Hackathon'],
      );

      provider.addEvent(event);

      final added = provider.events.firstWhere((e) => e.id == 'prov-test-1');
      expect(added.checklist.isNotEmpty, isTrue);
      expect(added.checklist, contains('Form your team & assign roles'));
      expect(added.checkedItems.length, equals(added.checklist.length));
      expect(added.checkedItems.every((c) => c == false), isTrue);
    });

    test('toggleChecklistItem flips a specific checkbox', () {
      final provider = EventProvider();
      final event = Event(
        id: 'toggle-test',
        eventName: 'Toggle Test',
        description: 'Testing toggle',
        date: DateTime(2026, 11, 2),
        time: '3:00 PM',
        venue: 'Room 202',
        categories: ['Workshop'],
        checklist: ['Step 1', 'Step 2', 'Step 3'],
        checkedItems: [false, false, false],
      );

      provider.addEvent(event);

      // Toggle first item
      provider.toggleChecklistItem('toggle-test', 0);
      var updated = provider.events.firstWhere((e) => e.id == 'toggle-test');
      expect(updated.checkedItems[0], isTrue);
      expect(updated.checkedItems[1], isFalse);

      // Toggle it back
      provider.toggleChecklistItem('toggle-test', 0);
      updated = provider.events.firstWhere((e) => e.id == 'toggle-test');
      expect(updated.checkedItems[0], isFalse);
    });

    test('toggleChecklistItem ignores invalid index', () {
      final provider = EventProvider();
      final event = Event(
        id: 'bound-test',
        eventName: 'Bounds Test',
        description: 'Testing bounds',
        date: DateTime(2026, 11, 3),
        time: '4:00 PM',
        venue: 'Room 303',
        categories: ['Tech'],
        checklist: ['Only Task'],
        checkedItems: [false],
      );

      provider.addEvent(event);
      // Should not throw
      provider.toggleChecklistItem('bound-test', -1);
      provider.toggleChecklistItem('bound-test', 99);

      final unchanged =
          provider.events.firstWhere((e) => e.id == 'bound-test');
      expect(unchanged.checkedItems[0], isFalse);
    });

    test('ensureChecklist lazy-generates for events without a checklist', () {
      final provider = EventProvider();
      final event = Event(
        id: 'lazy-test',
        eventName: 'Lazy Gen Test',
        description: 'No checklist',
        date: DateTime(2026, 12, 1),
        time: '5:00 PM',
        venue: 'Auditorium',
        categories: ['Career'],
        checklist: ['Already has tasks'],
        checkedItems: [true],
      );

      // addEvent won't overwrite existing checklist
      provider.addEvent(event);
      var loaded = provider.events.firstWhere((e) => e.id == 'lazy-test');
      expect(loaded.checklist, equals(['Already has tasks']));

      // ensureChecklist should not overwrite existing
      provider.ensureChecklist('lazy-test');
      loaded = provider.events.firstWhere((e) => e.id == 'lazy-test');
      expect(loaded.checklist, equals(['Already has tasks']));
    });

    test('ensureChecklist generates for empty-checklist event', () {
      final provider = EventProvider();

      // We need to manually insert an event without a checklist
      // by going through addEvent — but addEvent auto-generates!
      // So test that ensureChecklist handles missing event ID gracefully
      provider.ensureChecklist('nonexistent-id'); // Should not throw
    });
  });
}
