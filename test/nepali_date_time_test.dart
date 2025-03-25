import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('NepaliDateTime', () {
    test('should convert DateTime to NepaliDateTime', () {
      final dateTime = DateTime(2025, 3, 24);
      final nepaliDateTime = dateTime.toNepaliDateTime();
      expect(nepaliDateTime.year, greaterThan(2000));
    });

    test('should calculate total days in a month', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      expect(nepaliDateTime.totalDays, 31);
    });

    test('should calculate weekday correctly', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 31);
      expect(nepaliDateTime.weekday, 4);
    });

    test('should calculate total days in a year', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      expect(nepaliDateTime.totalDaysInYear, 365);
    });

    test('should add duration correctly', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      final addedDate = nepaliDateTime.add(Duration(days: 30));
      expect(addedDate.month, 1);
    });

    test('should subtract duration correctly', () {
      final nepaliDateTime = NepaliDateTime(2082, 2, 1);
      final subtractedDate = nepaliDateTime.subtract(Duration(days: 30));
      expect(subtractedDate.month, 1);
    });

    test('should compare dates correctly', () {
      final date1 = NepaliDateTime(2082, 1, 1);
      final date2 = NepaliDateTime(2082, 2, 1);
      expect(date1.isBefore(date2), isTrue);
      expect(date2.isAfter(date1), isTrue);
    });

    test('should calculate difference between dates', () {
      final date1 = NepaliDateTime(2082, 1, 1);
      final date2 = NepaliDateTime(2082, 2, 1);
      final difference = date2.difference(date1);
      expect(difference.inDays, 31);
    });

    test('should parse valid NepaliDateTime string', () {
      final parsedDate = NepaliDateTime.parse('2082-01-01 00:00:00');
      expect(parsedDate.year, 2082);
      expect(parsedDate.month, 1);
      expect(parsedDate.day, 1);
    });

    test(
      'should return null for invalid NepaliDateTime string in tryParse',
      () {
        final parsedDate = NepaliDateTime.tryParse('invalid-date');
        expect(parsedDate, isNull);
      },
    );

    test('should format NepaliDateTime correctly', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1, 12, 30, 45);
      final formatted = nepaliDateTime.format('yyyy-MM-dd HH:mm:ss');
      expect(formatted, '2082-01-01 12:30:45');
    });

    test('should convert NepaliDateTime to DateTime', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      final dateTime = nepaliDateTime.toDateTime();
      expect(dateTime.year, greaterThan(1900));
    });

    test('should merge time correctly', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      final mergedDateTime = nepaliDateTime.mergeTime(10, 30, 45);
      expect(mergedDateTime.hour, 10);
      expect(mergedDateTime.minute, 30);
      expect(mergedDateTime.second, 45);
    });

    test('should handle leap year correctly', () {
      final nepaliDateTime = NepaliDateTime(2084, 12, 30);
      expect(nepaliDateTime.totalDaysInYear, 366);
    });

    test('should throw FormatException for invalid parse', () {
      expect(() => NepaliDateTime.parse('invalid-date'), throwsFormatException);
    });

    test('should calculate millisecondsSinceEpoch correctly', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      expect(nepaliDateTime.millisecondsSinceEpoch, isNotNull);
    });

    test('should calculate microsecondsSinceEpoch correctly', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      expect(nepaliDateTime.microsecondsSinceEpoch, isNotNull);
    });

    test('should compare equality of two NepaliDateTime objects', () {
      final date1 = NepaliDateTime(2082, 1, 1);
      final date2 = NepaliDateTime(2082, 1, 1);
      expect(date1.compareTo(date2), 0);
    });

    test('should return correct timeZoneOffset', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      expect(
        nepaliDateTime.timeZoneOffset,
        const Duration(hours: 5, minutes: 45),
      );
    });

    test('should return correct timeZoneName', () {
      final nepaliDateTime = NepaliDateTime(2082, 1, 1);
      expect(nepaliDateTime.timeZoneName, 'Nepal Time');
    });
  });
}
