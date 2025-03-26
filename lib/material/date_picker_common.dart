import 'package:flutter/foundation.dart';
import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart'
    show NepaliDateTime;

/// Signature for a function that creates a widget for a given date.
typedef SelectableDayPredicate = bool Function(NepaliDateTime day);

/// A range of Nepali dates.
@immutable
class NepaliDateTimeRange {
  /// Creates a range of Nepali dates.
  const NepaliDateTimeRange({
    required this.start,
    required this.end,
  });

  /// The first date in the range.
  final NepaliDateTime start;

  /// The last date in the range.
  final NepaliDateTime end;

  /// The number of days between the [start] and [end] dates.
  Duration get duration => end.difference(start);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is NepaliDateTimeRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start - $end';
}
