import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';
import 'package:test/test.dart';
void main() {
  group('NepaliDateFormat', () {
    test('should format date in English (yMd)', () {
      final date = NepaliDateTime(2082, 5, 12); // Example Nepali date
      final formatter = NepaliDateFormat.yMd(Language.english);
      final result = formatter.format(date);
      expect(result, '2082/05/12');
    });

    test('should format date in Nepali (yMd)', () {
      final date = NepaliDateTime(2082, 5, 12); // Example Nepali date
      final formatter = NepaliDateFormat.yMd(Language.nepali);
      final result = formatter.format(date);
      expect(result, '२०८२/०५/१२');
    });

    test('should format date with month name in English (yMMM)', () {
      final date = NepaliDateTime(2082, 5, 12);
      final formatter = NepaliDateFormat.yMMM(Language.english);
      final result = formatter.format(date);
      expect(result, 'May 2082');
    });

    test('should format date with month name in Nepali (yMMM)', () {
      final date = NepaliDateTime(2082, 5, 12);
      final formatter = NepaliDateFormat.yMMM(Language.nepali);
      final result = formatter.format(date);
      expect(result, 'जेठ २०८२');
    });

    test('should format full date in English (yMMMMd)', () {
      final date = NepaliDateTime(2082, 5, 12);
      final formatter = NepaliDateFormat.yMMMMd(Language.english);
      final result = formatter.format(date);
      expect(result, 'May 12, 2082');
    });

    test('should format full date in Nepali (yMMMMd)', () {
      final date = NepaliDateTime(2082, 5, 12);
      final formatter = NepaliDateFormat.yMMMMd(Language.nepali);
      final result = formatter.format(date);
      expect(result, 'जेठ १२, २०८२');
    });

    test('should format time in English (Hm)', () {
      final date = NepaliDateTime(2082, 5, 12, 14, 30); // 2:30 PM
      final formatter = NepaliDateFormat.Hm(Language.english);
      final result = formatter.format(date);
      expect(result, '14:30');
    });

    test('should format time in Nepali (Hm)', () {
      final date = NepaliDateTime(2082, 5, 12, 14, 30); // 2:30 PM
      final formatter = NepaliDateFormat.Hm(Language.nepali);
      final result = formatter.format(date);
      expect(result, '१४:३०');
    });

    test('should format date with weekday in English (yMMMMEEEEd)', () {
      final date = NepaliDateTime(2082, 5, 12); // Example Nepali date
      final formatter = NepaliDateFormat.yMMMMEEEEd(Language.english);
      final result = formatter.format(date);
      expect(result, 'Thursday, May 12, 2082');
    });

    test('should format date with weekday in Nepali (yMMMMEEEEd)', () {
      final date = NepaliDateTime(2082, 5, 12); // Example Nepali date
      final formatter = NepaliDateFormat.yMMMMEEEEd(Language.nepali);
      final result = formatter.format(date);
      expect(result, 'बिहिबार, जेठ १२, २०८२');
    });
  });
}
