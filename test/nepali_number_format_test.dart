import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';
import 'package:test/test.dart';
void main() {
  group('NepaliNumberFormat', () {
    test('should format numbers in Nepali language', () {
      final formatter = NepaliNumberFormat(language: Language.nepali);
      final result = formatter.format(1234567890);
      expect(result, '१,२३,४५,६७,८९०');
    });

    test('should format numbers in English language', () {
      final formatter = NepaliNumberFormat(language: Language.english);
      final result = formatter.format(1234567890);
      expect(result, '1,23,45,67,890');
    });

    test('should format numbers as monetary values', () {
      final formatter = NepaliNumberFormat(
        language: Language.nepali,
        isMonetory: true,
        symbol: 'रु',
      );
      final result = formatter.format(1234567890);
      expect(result, 'रु १,२३,४५,६७,८९०');
    });
  });

  test('should format numbers with custom delimiter', () {
    final formatter =
        NepaliNumberFormat(language: Language.nepali, delimiter: '-');
    final result = formatter.format(1234567890);
    expect(result, '१-२३-४५-६७-८९०');
  });

  test('should format numbers with symbol on the right', () {
    final formatter = NepaliNumberFormat(
      language: Language.nepali,
      isMonetory: true,
      symbol: 'रु',
      symbolOnLeft: false,
    );
    final result = formatter.format(1234567890);
    expect(result, '१,२३,४५,६७,८९० रु');
  });

  test('should format numbers without space between amount and symbol', () {
    final formatter = NepaliNumberFormat(
      language: Language.nepali,
      isMonetory: true,
      symbol: 'रु',
      spaceBetweenAmountAndSymbol: false,
    );
    final result = formatter.format(1234567890);
    expect(result, 'रु१,२३,४५,६७,८९०');
  });

  test('should format numbers with decimals', () {
    final formatter =
        NepaliNumberFormat(language: Language.nepali, decimalDigits: 2);
    final result = formatter.format(12345.67890);
    expect(result, '१२,३४५.६७');
  });

  test('should format numbers without decimals if zero', () {
    final formatter = NepaliNumberFormat(
      language: Language.nepali,
      decimalDigits: 2,
      includeDecimalIfZero: false,
    );
    final result = formatter.format(12345.0);
    expect(result, '१२,३४५');
  });

  test('should throw error for unsupported number type', () {
    final formatter = NepaliNumberFormat(language: Language.nepali);
    expect(() => formatter.format(DateTime.now()), throwsArgumentError);
  });

  test('should format numbers in words (Nepali)', () {
    final formatter =
        NepaliNumberFormat(language: Language.nepali, inWords: true);
    final result = formatter.format(123456);
    expect(result, '१ लाख २३ हजार ४ सय ५६');
  });

  test('should format numbers in words (English)', () {
    final formatter =
        NepaliNumberFormat(language: Language.english, inWords: true);
    final result = formatter.format(123456);
    expect(result, 'One lakh twenty-three thousand four hundred fifty-six');
  });

  test('should format monetary values in words (Nepali)', () {
    final formatter = NepaliNumberFormat(
      language: Language.nepali,
      inWords: true,
      isMonetory: true,
    );
    final result = formatter.format(123456);
    expect(result, '१ लाख २३ हजार ४ सय ५६ रुपैया');
  });

  test('should handle null input gracefully', () {
    final formatter = NepaliNumberFormat(language: Language.nepali);
    final result = formatter.format('');
    expect(result, '');
  });
}
