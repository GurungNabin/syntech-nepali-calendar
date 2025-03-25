import 'package:flutter/foundation.dart';
import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart' show NepaliDateTime;

typedef SelectableDayPredicate = bool Function(NepaliDateTime day);

@immutable
class NepaliDateTimeRange {
  const NepaliDateTimeRange({
    required this.start,
    required this.end,
  });

  final NepaliDateTime start;

  final NepaliDateTime end;

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
