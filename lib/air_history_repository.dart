import 'dart:async';

// Simple representation of an air quality log entry
class AirDataLog {
  final DateTime timestamp;
  final String location;
  final double co2;
  final double nitrogen;
  final double voc;
  final double dust;
  final double ethylene;

  AirDataLog({
    required this.timestamp,
    required this.location,
    required this.co2,
    required this.nitrogen,
    required this.voc,
    required this.dust,
    required this.ethylene,
  });
}

// Global data hub that retains all history points generated while the app runs
class AirHistoryRepository {
  // Singleton instance pattern so every screen shares the exact same memory array
  static final AirHistoryRepository instance = AirHistoryRepository._internal();
  AirHistoryRepository._internal();

  final List<AirDataLog> _historyLogs = [];

  // Pushes a new moving sensor point onto our shared history log array
  void addLog(AirDataLog log) {
    _historyLogs.add(log);
    // Optional cap to prevent infinite loop memory bloat during testing
    if (_historyLogs.length > 500) {
      _historyLogs.removeAt(0);
    }
  }

  // Returns all logs sitting between the user's selected date parameters
  List<AirDataLog> getLogsForRange(DateTime start, DateTime end) {
    // Standardise dates to midnight boundaries for clean matching logic
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return _historyLogs.where((log) {
      return log.timestamp.isAfter(startDate) && log.timestamp.isBefore(endDate);
    }).toList();
  }
}
