import 'package:flutter/foundation.dart';

/// Lightweight role state provider for switching between Student and Coordinator views.
///
/// When [isCoordinator] is `true`, the UI surfaces coordinator-specific
/// capabilities such as the Announcement Inbox creation flow and
/// event management tools.
class RoleProvider extends ChangeNotifier {
  bool _isCoordinator = false;

  /// Whether the current user is acting as a Coordinator.
  bool get isCoordinator => _isCoordinator;

  /// The human-readable label for the active role.
  String get roleLabel => _isCoordinator ? 'Coordinator' : 'Student';

  /// Toggle between Student and Coordinator roles.
  void toggleRole() {
    _isCoordinator = !_isCoordinator;
    notifyListeners();
  }

  /// Explicitly set the role.
  void setRole({required bool coordinator}) {
    if (_isCoordinator == coordinator) return;
    _isCoordinator = coordinator;
    notifyListeners();
  }
}
