import 'package:flutter/foundation.dart';

import 'convex_http_client.dart';
import 'doha_time.dart';

class ScheduleService {
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  final ConvexHttpClient _client = ConvexHttpClient.instance;

  Future<Map<String, dynamic>?> getStopSchedule(String stopId) async {
    try {
      final result = await _client.query(
        'stops:getSchedule',
        {'stopId': stopId},
      );

      if (result == null) {
        return null;
      }

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e) {
      debugPrint('ScheduleService error: $e');
      return null;
    }
  }

  /// Parse minute-of-day values from Convex/JSON (int, double, or string).
  static int? parseMinute(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<int> parseTimeList(dynamic times) {
    if (times is! List) return [];
    return times.map(parseMinute).whereType<int>().toList()..sort();
  }

  static Map<String, dynamic>? routesMap(Map<String, dynamic>? routesData) {
    if (routesData == null) return null;
    final raw = routesData['routes'];
    if (raw is! Map) return null;
    return Map<String, dynamic>.from(raw);
  }

  Map<String, List<int>> getNextBuses(Map<String, dynamic> routesData) {
    final result = <String, List<int>>{};
    final routes = routesMap(routesData);
    if (routes == null) return result;

    final currentMinutes = DohaTime.nowMinutesOfDay();

    for (final entry in routes.entries) {
      final sortedTimes = parseTimeList(entry.value);
      if (sortedTimes.isEmpty) continue;

      final nextTimes =
          sortedTimes.where((t) => t > currentMinutes).toList();

      if (nextTimes.length >= 3) {
        result[entry.key] = nextTimes.take(3).toList();
      } else if (nextTimes.isNotEmpty) {
        final needed = 3 - nextTimes.length;
        result[entry.key] = [
          ...nextTimes,
          ...sortedTimes.take(needed),
        ];
      } else {
        // After last run today, wrap to tomorrow morning.
        result[entry.key] = sortedTimes.take(3).toList();
      }
    }

    return result;
  }

  String formatMinutes(int minutes) {
    return DohaTime.formatMinutesOfDay(minutes);
  }

  int getMinutesUntilArrival(int busTime) {
    final currentMinutes = DohaTime.nowMinutesOfDay();
    var diff = busTime - currentMinutes;
    if (diff < 0) diff += 1440;
    return diff;
  }

  /// Scheduled time already passed today — shown as the next day's run.
  bool isTomorrow(int busTimeMinutes) {
    final currentMinutes = DohaTime.nowMinutesOfDay();
    return busTimeMinutes <= currentMinutes;
  }

  /// Compact label for route-card schedule pills.
  String formatArrivalLabel(int busTimeMinutes) {
    if (isTomorrow(busTimeMinutes)) {
      return 'Tomorrow · ${formatMinutes(busTimeMinutes)}';
    }
    return '${getMinutesUntilArrival(busTimeMinutes)} min';
  }

  /// Descriptive label for stop-sheet schedule rows.
  String formatArrivalDetail(int busTimeMinutes) {
    if (isTomorrow(busTimeMinutes)) {
      return 'Next bus tomorrow at ${formatMinutes(busTimeMinutes)}';
    }
    final eta = getMinutesUntilArrival(busTimeMinutes);
    return '${formatMinutes(busTimeMinutes)} ($eta min)';
  }
}
