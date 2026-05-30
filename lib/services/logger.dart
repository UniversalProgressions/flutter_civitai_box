import 'package:talker/talker.dart';

/// Application-wide logger backed by [Talker].
///
/// Usage:
/// ```dart
/// logger.info('Scan started');
/// logger.error('Failed to process file', Exception('...'));
/// ```
final logger = Talker();
