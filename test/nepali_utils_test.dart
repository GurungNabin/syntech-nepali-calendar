import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('NepaliUtils', () {
    test('should initialize with default language as English', () {
      final utils = NepaliUtils();
      expect(utils.language, Language.english);
    });

    test('should initialize with default language as Nepali', () {
      final utils = NepaliUtils();
      expect(utils.language, Language.nepali);
    });

    test('should allow setting language to Nepali', () {
      final utils = NepaliUtils(Language.nepali);
      expect(utils.language, Language.nepali);
    });

    test('should allow setting language to English', () {
      final utils = NepaliUtils(Language.english);
      expect(utils.language, Language.english);
    });

    test('should maintain singleton instance', () {
      final utils1 = NepaliUtils();
      final utils2 = NepaliUtils(Language.nepali);
      expect(utils1, utils2);
      expect(utils1.language, Language.nepali);
    });
  });
}
