import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';
import 'package:test/test.dart';
void main() {
  group('NepaliUnicode', () {
    test('should convert English charactes to Nepali Unicode', () {
      final result = NepaliUnicode.convert('a');
      expect(result, '\u0905');
    });

    test('should handle live conversion mode', () {
      final result = NepaliUnicode.convert('a', live: true);
      expect(result, '\u0905');
    });

    test('should handle empty input gracefully', () {
      final result = NepaliUnicode.convert('');
      expect(result, '');
    });

    test('should replace multiple characters correctly', () {
      final result = NepaliUnicode.convert('ai');
      expect(result, '\u0910');
    });

    test('should replace X letter to Nepali Unicode', () {
      final result = NepaliUnicode.convert('X');
      expect(result, '\u0915\u094d\u0938\u094d');
    });

    test('should replcae symbol characters correctly', () {
      final result = NepaliUnicode.convert(':');
      expect(result, '\u0903');
    });

    test('should replace English letter to Nepali Unicode', () {
      final result = NepaliUnicode.convert('9');
      expect(result, '\u096f');
    });
  });
}
