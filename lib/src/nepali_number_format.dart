import 'language.dart';
import 'nepali_unicode.dart';
import 'nepali_utils.dart';

/// A class to format numbers in Nepali style, with support for monetary values
/// and conversion to words in Nepali or English.
class NepaliNumberFormat {
  /// Creates an instance of [NepaliNumberFormat].
  ///
  /// - [inWords]: If true, formats the number in words.
  /// - [isMonetory]: If true, adds a monetary symbol to the formatted number.
  /// - [decimalDigits]: Number of decimal digits to include.
  /// - [symbol]: The monetary symbol to use (e.g., Rs, $).
  /// - [symbolOnLeft]: If true, places the symbol on the left of the number.
  /// - [delimiter]: The delimiter to use for grouping digits (default is `,`).
  /// - [spaceBetweenAmountAndSymbol]: If true, adds a space between the amount and the symbol.
  /// - [includeDecimalIfZero]: If true, includes decimal digits even if they are zero.
  /// - [language]: The language to use for formatting (default is the system language).
  NepaliNumberFormat({
    this.inWords = false,
    this.isMonetory = false,
    this.decimalDigits,
    this.symbol,
    this.symbolOnLeft = true,
    this.delimiter = ',',
    this.spaceBetweenAmountAndSymbol = true,
    this.includeDecimalIfZero = true,
    Language? language,
  }) : _lang = language ?? NepaliUtils().language;

  /// Formats the given [number] according to the specified options.
  final bool inWords;

  /// The language to use for formatting.
  final Language _lang;

  /// If true, formats the number as a monetary value.
  final bool isMonetory;

  /// Number of decimal digits to include.
  final int? decimalDigits;

  /// The monetary symbol to use.
  final String? symbol;

  /// The delimiter to use for grouping digits.
  final String delimiter;

  /// If true, places the symbol on the left of the number.
  final bool symbolOnLeft;

  /// If true, adds a space between the amount and the symbol.
  final bool spaceBetweenAmountAndSymbol;

  /// If true, includes decimal digits even if they are zero.
  final bool includeDecimalIfZero;

  /// Formats the given [number] according to the specified options.
  /// If [number] is `null`, returns an empty string.
  /// - [number]: The number to format. It can be of type `String`, `int`, or `double`.
  /// - Returns: The formatted number as a string.
  String format<T extends Object>(T? number) {
    if (number == null) return '';
    if (inWords) {
      return isMonetory
          ? _placeSymbol(_formatInWords<T>(number))
          : _formatInWords<T>(number);
    } else {
      return isMonetory
          ? _placeSymbol(_formatWithComma<T>(number))
          : _formatWithComma<T>(number);
    }
  }

  /// Places the monetary symbol on the left or right of the number.
  String _placeSymbol(String? number) {
    if (number == null) {
      return '';
    }
    if (symbol == null) {
      return number;
    } else if (symbolOnLeft) {
      return symbol! + (spaceBetweenAmountAndSymbol ? ' ' : '') + number;
    } else {
      return number + (spaceBetweenAmountAndSymbol ? ' ' : '') + symbol!;
    }
  }

  /// Formats the given [number] in words.
  String _formatInWords<T extends Object>(T number) {
    final numberInWordBuffer = StringBuffer();
    var decimal = '';
    final commaFormattedNumber = _formatWithComma<T>(number);
    final digitGroups = commaFormattedNumber.split(',');

    if (commaFormattedNumber.contains('.')) {
      decimal = digitGroups.last.split('.').last;
    }

    for (var i = 0; i < digitGroups.length - 1; i++) {
      numberInWordBuffer.write(
        _digitGroupToWord(
          digitGroups.length - i - 2,
          digitGroups[i],
        ),
      );
    }

    var digit = digitGroups.last;
    if (digit.contains('.')) {
      digit = digitGroups.last.split('.').first;
    }

    if (digit.length == 3) {
      numberInWordBuffer.write(
        '${_languageNumber(digit[0])} ${_language('hundred')} '
        '${_languageNumber(digit.substring(1))}',
      );
    } else {
      numberInWordBuffer.write(_languageNumber(digit));
    }

    final numberInWord = numberInWordBuffer.toString();

    if (isMonetory) {
      return numberInWord.trimRight() +
          (decimal.isEmpty
              ? ' ${_language('rupees')}'
              : ' ${_language('rupees')} '
                  '${_isEnglish ? decimal : NepaliUnicode.convert(decimal)} '
                  '${_language('paisa')}');
    }
    return numberInWord.trimRight();
  }

  /// Converts the given [number] to words based on the [index].
  String _digitGroupToWord(int index, String number) {
    switch (index) {
      case 0:
        return '${_languageNumber(number)} ${_language('thousand')} ';
      case 1:
        return '${_languageNumber(number)} ${_language('lakh')} ';
      case 2:
        return '${_languageNumber(number)} ${_language('crore')} ';
      case 3:
        return '${_languageNumber(number)} ${_language('arab')} ';
      case 4:
        return '${_languageNumber(number)} ${_language('kharab')} ';
      case 5:
        return '${_languageNumber(number)} ${_language('nil')} ';
      case 6:
        return '${_languageNumber(number)} ${_language('padam')} ';
      case 7:
        return '${_languageNumber(number)} ${_language('sankha')} ';
      default:
        return '';
    }
  }

  /// Converts the given [number] to the specified language.
  String _languageNumber(String number) =>
      _isEnglish ? number : NepaliUnicode.convert(number);

  bool get _isEnglish => _lang == Language.english;

  /// Converts the given [word] to the specified language.
  String _language(String word) {
    switch (word) {
      case 'rupees':
        return _isEnglish ? word : 'रुपैया';
      case 'paisa':
        return _isEnglish ? word : 'पैसा';
      case 'hundred':
        return _isEnglish ? word : 'सय';
      case 'thousand':
        return _isEnglish ? word : 'हजार';
      case 'lakh':
        return _isEnglish ? word : 'लाख';
      case 'crore':
        return _isEnglish ? word : 'करोड';
      case 'arab':
        return _isEnglish ? word : 'अर्ब';
      case 'kharab':
        return _isEnglish ? word : 'खर्ब';
      case 'nil':
        return _isEnglish ? word : 'नील';
      case 'padam':
        return _isEnglish ? word : 'पद्म';
      case 'sankha':
        return _isEnglish ? word : 'शंख';
      default:
        return '';
    }
  }

  /// Formats the given [number] with commas.
  String _formatWithComma<T extends Object>(T number) {
    var decimalDigits = this.decimalDigits;
    var number0 = '';
    var fractionalPart = '';
    if (number is String) {
      decimalDigits ??= 2;
      number0 = number;
    } else if (number is int) {
      decimalDigits ??= 0;
      number0 = '$number';
    } else if (number is double) {
      decimalDigits ??= 2;
      number0 = '$number';
    } else {
      throw ArgumentError('number should be either "String" or "num"');
    }

    final fractionMatches = RegExp(r'^(\d*)\.?(\d*)$').allMatches(number0);
    if (fractionMatches.isNotEmpty) {
      number0 = fractionMatches.first.group(1) ?? '';
      fractionalPart = fractionMatches.first.group(2) ?? '';
    } else {
      throw Exception('Unexpected input: $number');
    }

    fractionalPart =
        fractionalPart.padRight(decimalDigits, '0').substring(0, decimalDigits);

    final hideDecimal =
        !includeDecimalIfZero && RegExp(r'^0+$').hasMatch(fractionalPart);

    fractionalPart =
        _isEnglish ? fractionalPart : NepaliUnicode.convert(fractionalPart);
    if (decimalDigits > 0) {
      fractionalPart = '.$fractionalPart';
    }

    if (number0.length <= 3) {
      if (hideDecimal) {
        return _isEnglish ? number0 : NepaliUnicode.convert(number0);
      }
      return '${_isEnglish ? number0 : NepaliUnicode.convert(number0)}'
          '$fractionalPart';
    } else if (number0.length < 5) {
      final localizedNum =
          _isEnglish ? number0 : NepaliUnicode.convert(number0);
      if (hideDecimal) {
        return '${localizedNum[0]}$delimiter${localizedNum.substring(1)}';
      }
      return '${localizedNum[0]}$delimiter${localizedNum.substring(1)}'
          '$fractionalPart';
    } else {
      final paddedNumber = number0.length.isOdd ? number0 : '0$number0';
      var formattedString = '';
      final digitMatcher = RegExp(r'\d{1,2}');
      final matches = digitMatcher.allMatches(paddedNumber);
      for (var i = 0; i < matches.length; i++) {
        if (i < matches.length - 2) {
          formattedString += '${matches.elementAt(i).group(0)}$delimiter';
        } else {
          formattedString +=
              number0.substring(number0.length - 3, number0.length);
          break;
        }
      }
      formattedString = formattedString[0] == '0'
          ? formattedString.substring(1)
          : formattedString;
      formattedString =
          _isEnglish ? formattedString : NepaliUnicode.convert(formattedString);

      if (hideDecimal) return formattedString;
      return '$formattedString$fractionalPart';
    }
  }
}
