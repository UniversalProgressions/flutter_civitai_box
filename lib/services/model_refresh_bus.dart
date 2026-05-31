import 'package:flutter/foundation.dart';

/// Lightweight event bus for model data changes.
///
/// Any operation that changes the model database (scan, download, delete)
/// should call [notify] so that UI pages can refresh.
///
/// Usage:
/// ```dart
/// // Producer
/// ModelRefreshBus.instance.notify();
///
/// // Consumer
/// ModelRefreshBus.instance.addListener(_onDataChanged);
/// ```
class ModelRefreshBus extends ChangeNotifier {
  ModelRefreshBus._();
  static final ModelRefreshBus instance = ModelRefreshBus._();

  /// Signal that model data has changed.
  void notify() => notifyListeners();
}
