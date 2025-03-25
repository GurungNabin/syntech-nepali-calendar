import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('NepaliDateFormat', () {
    test('should format date in English (yMd)', () {
      final date = NepaliDateTime(2082, 1, 1);
      final formatter = NepaliDateFormat.yMd(Language.english);
      final result = formatter.format(date);
      expect(result, '2082/01/01');
    });

    test('should format date in Nepali (yMd)', () {
      final date = NepaliDateTime(2082, 1, 1);
      final formatter = NepaliDateFormat.yMd(Language.nepali);
      final result = formatter.format(date);
      expect(result, '२०८२/०१/०१');
    });

    test('should format date with month name in English (yMMM)', () {
      final date = NepaliDateTime(2082, 1, 1);
      final formatter = NepaliDateFormat.yMMM(Language.english);
      final result = formatter.format(date);
      expect(result, 'Bai 2082');
    });

    test('should format date with month name in Nepali (yMMM)', () {
      final date = NepaliDateTime(2082, 1, 1);
      final formatter = NepaliDateFormat.yMMM(Language.nepali);
      final result = formatter.format(date);
      expect(result, 'बै २०८२');
    });

    test('should format full date in English (yMMMMd)', () {
      final date = NepaliDateTime(2082, 1, 1);
      final formatter = NepaliDateFormat.yMMMMd(Language.english);
      final result = formatter.format(date);
      expect(result, 'Baishakh 1, 2082');
    });

    test('should format full date in Nepali (yMMMMd)', () {
      final date = NepaliDateTime(2082, 1, 1);
      final formatter = NepaliDateFormat.yMMMMd(Language.nepali);
      final result = formatter.format(date);
      expect(result, 'बैशाख १, २०८२');
    });

    test('should format time in English (Hm)', () {
      final date = NepaliDateTime(2082, 1, 1, 14, 30);
      final formatter = NepaliDateFormat.Hm(Language.english);
      final result = formatter.format(date);
      expect(result, '14:01');
    });

    test('should format time in Nepali (Hm)', () {
      final date = NepaliDateTime(2082, 1, 1, 14, 30);
      final formatter = NepaliDateFormat.Hm(Language.nepali);
      final result = formatter.format(date);
      expect(result, '१४:०१');
    });

    test('should format date with weekday in English (yMMMMEEEEd)', () {
      final date = NepaliDateTime(2082, 1, 1);
      final formatter = NepaliDateFormat.yMMMMEEEEd(Language.english);
      final result = formatter.format(date);
      expect(result, 'Monday, Baishakh 1, 2082');
    });

    test('should format date with weekday in Nepali (yMMMMEEEEd)', () {
      final date = NepaliDateTime(2082, 1, 1);
      final formatter = NepaliDateFormat.yMMMMEEEEd(Language.nepali);
      final result = formatter.format(date);
      expect(result, 'सोमबार, बैशाख १, २०८२');
    });
  });
}
