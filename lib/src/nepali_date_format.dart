// ignore_for_file: non_constant_identifier_names

import 'language.dart';
import 'nepali_date_time.dart';
import 'nepali_unicode.dart';
import 'nepali_utils.dart';

/// A class to format dates in Nepali style.
class NepaliDateFormat {
  /// Creates an instance of [NepaliDateFormat].
  /// - [pattern]: The pattern to format the date.
  /// - [language]: The language to use for formatting (default is the system language).
  NepaliDateFormat(
    String pattern, [
    Language? language,
  ]) : _language = language ?? NepaliUtils().language {
    _pattern = pattern;
  }

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.d([Language? language]) : this('d', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.E([Language? language]) : this('EE', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.EEEE([Language? language]) : this('EEE', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.LLL([Language? language]) : this('MMM', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.LLLL([Language? language]) : this('MMMM', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.M([Language? language]) : this('M', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.Md([Language? language]) : this('M/d', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.MEd([Language? language]) : this('EE, M/d', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.MMM([Language? language]) : this('MMM', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.MMMd([Language? language]) : this('MMM d', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.MMMEd([Language? language]) : this('EEE, MMM d', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.MMMM([Language? language]) : this('MMMM', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.MMMMd([Language? language]) : this('MMMM d', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.MMMMEEEEd([Language? language])
      : this('EEE, MMMM d', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.QQQ([Language? language]) : this('QQQ', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.QQQQ([Language? language]) : this('QQQQ', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.y([Language? language]) : this('y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yM([Language? language]) : this('y/MM', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yMd([Language? language]) : this('y/MM/dd', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yMEd([Language? language]) : this('EE, y/MM/dd', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yMMM([Language? language]) : this('MMM y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yMMMd([Language? language]) : this('MMM d, y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yMMMEd([Language? language])
      : this('EE, MMM d, y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yMMMM([Language? language]) : this('MMMM y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yMMMMd([Language? language]) : this('MMMM d, y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yMMMMEEEEd([Language? language])
      : this('EEE, MMMM d, y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yQQQ([Language? language]) : this('QQQ y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.yQQQQ([Language? language]) : this('QQQQ y', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.H([Language? language]) : this('H', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.Hm([Language? language]) : this('HH:MM', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.Hms([Language? language]) : this('HH:mm:ss', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.j([Language? language])
      : this(
          language == Language.nepali ? 'aa h' : 'h aa',
          language,
        );

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.jm([Language? language])
      : this(
          language == Language.nepali ? 'aa h:mm' : 'h:mm aa',
          language,
        );

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.jms([Language? language])
      : this(
          language == Language.nepali ? 'aa h:mm:ss' : 'h:mm:ss aa',
          language,
        );

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.m([Language? language]) : this('h', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.ms([Language? language]) : this('hh:mm', language);

  /// Formats the given [date] according to the specified pattern.
  NepaliDateFormat.s([Language? language]) : this('s', language);
  final Language _language;
  late String _pattern;
  String _checkPattern = '';
  bool _firstRun = true;
  int _index = 0;

  /// Formats the given [date] according to the specified pattern.
  String format(NepaliDateTime date) {
    if (_firstRun) {
      _checkPattern = _pattern;
      _firstRun = false;
    }
    for (var i = 0; i < _matchers.length; i++) {
      final regex = _matchers[i];
      final match = regex.firstMatch(_checkPattern);

      if (_checkPattern.isEmpty) return _pattern;

      if (match != null) {
        final matchedString = match.group(0);
        if (matchedString != null) {
          _checkPattern = _checkPattern.substring(matchedString.length);
          switch (i) {
            case 0:
              _trim(matchedString);
              format(date);
              break;
            case 1:
              _format(matchedString, date);
              format(date);
              break;
            case 2:
              _index += matchedString.length;
              format(date);
              break;
          }
        }
      }
    }
    return '';
  }
  
  /// Parses the given [dateString] and formats it according to the specified pattern.
  String parseAndFormat(String dateString) {
    return format(NepaliDateTime.parse(dateString));
  }

  void _trim(String match) {
    if (match == "''") {
      _pattern = _pattern.replaceFirst("''", "'");
      --_index;
    } else {
      _pattern =
          _pattern.replaceFirst(match, match.substring(1, match.length - 1));
      _index -= 2;
      if (match.contains("''")) {
        _pattern = _pattern.replaceFirst("''", "'");
        --_index;
      }
    }
    _index += match.length;
  }

  void _format(String match, NepaliDateTime date) {
    switch (match) {
      case 'G':
        _replacer(match, _isEnglish ? 'BS' : 'बि सं');
        break;
      case 'GG':
        _replacer(match, _isEnglish ? 'B.S.' : 'बि.सं.');
        break;
      case 'GGG':
        _replacer(match, _isEnglish ? 'Bikram Sambat' : 'बिक्रम संबत');
        break;
      case 'y':
        _replacer(
          match,
          _isEnglish ? '${date.year}' : NepaliUnicode.convert('${date.year}'),
        );
        break;
      case 'yy':
        _replacer(
          match,
          _isEnglish
              ? date.year.toString().substring(2)
              : NepaliUnicode.convert(date.year.toString().substring(2)),
        );
        break;
      case 'yyyy':
        _replacer(
          match,
          _isEnglish ? '${date.year}' : NepaliUnicode.convert('${date.year}'),
        );
        break;
      case 'Q':
        _replacer(match, '${_getQuarter(date.month)}');
        break;
      case 'QQ':
        _replacer(match, '0${_getQuarter(date.month)}');
        break;
      case 'QQQ':
        _replacer(match, 'Q${_getQuarter(date.month)}');
        break;
      case 'QQQQ':
        _replacer(match, '${_getPosition(_getQuarter(date.month))} quarter');
        break;
      case 'M':
        _replacer(
          match,
          _isEnglish ? '${date.month}' : NepaliUnicode.convert('${date.month}'),
        );
        break;
      case 'MM':
        _replacer(match, _prependZero(date.month));
        break;
      case 'MMM':
        _replacer(match, _monthString(date.month, index: 2));
        break;
      case 'MMMM':
        _replacer(match, _monthString(date.month, index: 0));
        break;
      case 'MMMMM':
        _replacer(match, _monthString(date.month, index: 1));
        break;
      case 'd':
        _replacer(
          match,
          _isEnglish ? '${date.day}' : NepaliUnicode.convert('${date.day}'),
        );
        break;
      case 'dd':
        _replacer(match, _prependZero(date.day));
        break;
      case 'E':
        _replacer(match, _weekDayString(date.weekday, short: true));
        break;
      case 'EE':
        _replacer(
          match,
          _isEnglish
              ? _weekDayString(date.weekday).substring(0, 3)
              : _weekDayString(date.weekday).replaceFirst('बार', ''),
        );
        break;
      case 'EEE':
        _replacer(match, _weekDayString(date.weekday));
        break;
      case 'a':
        _replacer(
          match,
          _isEnglish
              ? date.hour >= 12
                  ? 'pm'
                  : 'am'
              : date.hour < 12
                  ? 'बिहान'
                  : date.hour == 12
                      ? 'मध्यान्न'
                      : date.hour < 16
                          ? 'दिउसो'
                          : date.hour < 20
                              ? 'साँझ'
                              : 'बेलुकी',
        );
        break;
      case 'aa':
        _replacer(
          match,
          _isEnglish
              ? date.hour >= 12
                  ? 'PM'
                  : 'AM'
              : date.hour < 12
                  ? 'बिहान'
                  : date.hour == 12
                      ? 'मध्यान्न'
                      : date.hour < 16
                          ? 'दिउसो'
                          : date.hour < 20
                              ? 'साँझ'
                              : 'बेलुकी',
        );
        break;
      case 'h':
        _replacer(match, _clockHour(date.hour));
        break;
      case 'hh':
        _replacer(match, _clockHour(date.hour, prependZero: true));
        break;
      case 'H':
        _replacer(
          match,
          _isEnglish ? '${date.hour}' : NepaliUnicode.convert('${date.hour}'),
        );
        break;
      case 'HH':
        _replacer(match, _prependZero(date.hour));
        break;
      case 'm':
        _replacer(
          match,
          _isEnglish
              ? '${date.minute}'
              : NepaliUnicode.convert('${date.minute}'),
        );
        break;
      case 'mm':
        _replacer(match, _prependZero(date.minute));
        break;
      case 's':
        _replacer(
          match,
          _isEnglish
              ? '${date.second}'
              : NepaliUnicode.convert('${date.second}'),
        );
        break;
      case 'ss':
        _replacer(match, _prependZero(date.second));
        break;
      case 'S':
        _replacer(match, _threeDigitMaker(date.millisecond).substring(0, 1));
        break;
      case 'SS':
        _replacer(match, _threeDigitMaker(date.millisecond).substring(0, 2));
        break;
      case 'SSS':
        _replacer(match, _threeDigitMaker(date.millisecond).substring(0, 3));
        break;
      case 'SSSS':
        _replacer(
          match,
          '${_threeDigitMaker(date.millisecond)}'
                  '${_threeDigitMaker(date.microsecond)}'
              .substring(0, 4),
        );
        break;
      case 'SSSSS':
        _replacer(
          match,
          '${_threeDigitMaker(date.millisecond)}'
                  '${_threeDigitMaker(date.microsecond)}'
              .substring(0, 5),
        );
        break;
      case 'SSSSSS':
        _replacer(
          match,
          '${_threeDigitMaker(date.millisecond)}'
                  '${_threeDigitMaker(date.microsecond)}'
              .substring(0, 6),
        );
        break;
    }
  }

  String _threeDigitMaker(int number) {
    final numString = number.toString();
    if (numString.length == 1) {
      return _isEnglish
          ? '00$numString'
          : '००${NepaliUnicode.convert(numString)}';
    }
    if (numString.length == 2) {
      return _isEnglish
          ? '0$numString'
          : '०${NepaliUnicode.convert(numString)}';
    }
    return _isEnglish
        ? numString.substring(0, 3)
        : NepaliUnicode.convert(numString.substring(0, 3));
  }

  String _clockHour(int hour, {bool prependZero = false}) {
    if (hour > 12) {
      return _isEnglish
          ? '${hour - 12}'
          : NepaliUnicode.convert('${hour - 12}');
    } else if (hour == 12) {
      return _isEnglish ? '12' : '१२';
    } else {
      return _isEnglish
          ? prependZero
              ? _prependZero(hour)
              : '$hour'
          : prependZero
              ? _prependZero(hour)
              : NepaliUnicode.convert('$hour');
    }
  }

  String _prependZero(int number) {
    if (number < 10) {
      return _isEnglish ? '0$number' : '०${NepaliUnicode.convert('$number')}';
    }
    return _isEnglish ? '$number' : NepaliUnicode.convert('$number');
  }

  void _replacer(String match, String replaceWith) {
    _pattern = _pattern.replaceFirst(match, replaceWith, _index);
    _index += replaceWith.length;
  }

  String _weekDayString(int day, {bool short = false}) {
    assert(day > 0 && day < 8, 'Day must be between 1 and 7');

    final weeksInEnglish = [
      _Week('Sunday', 'S'),
      _Week('Monday', 'M'),
      _Week('Tuesday', 'T'),
      _Week('Wednesday', 'W'),
      _Week('Thursday', 'T'),
      _Week('Friday', 'F'),
      _Week('Saturday', 'S'),
    ];
    final weeksInNepali = [
      _Week('आइतबार', 'आ'),
      _Week('सोमबार', 'सो'),
      _Week('मंगलबार', 'मं'),
      _Week('बुधबार', 'बु'),
      _Week('बिहिबार', 'बि'),
      _Week('शुक्रबार', 'शु'),
      _Week('शनिबार', 'श'),
    ];

    if (_isEnglish) return weeksInEnglish[day - 1].get(short: short);
    return weeksInNepali[day - 1].get(short: short);
  }

  String _monthString(int month, {required int index}) {
    assert(month > 0 && month < 13, 'Month must be between 1 and 12');
    final monthsInEnglish = [
      ['Baishakh', 'Baisak', 'Bai'],
      ['Jestha', 'Jeth', 'Jes'],
      ['Ashadh', 'Asar', 'Asar'],
      ['Shrawan', 'Saun', 'Shr'],
      ['Bhadra', 'Bhadau', 'Bha'],
      ['Ashwin', 'Asoj', 'Ash'],
      ['Kartik', 'Kartik', 'Kar'],
      ['Mangsir', 'Marga', 'Marg'],
      ['Poush', 'Pus', 'Pou'],
      ['Magh', 'Magh', 'Mag'],
      ['Falgun', 'Fagun', 'Fal'],
      ['Chaitra', 'Chait', 'Cha'],
    ];
    final monthsInNepali = [
      ['बैशाख', 'बैशाख', 'बै'],
      ['जेष्ठ', 'जेठ', 'जे'],
      ['आषाढ', 'असार', 'अ'],
      ['श्रावण', 'साउन', 'श्रा'],
      ['भाद्र', 'भदौ', 'भा'],
      ['आश्विन', 'असोज', 'आ'],
      ['कार्तिक', 'कात्तिक', 'का'],
      ['मंसिर', 'मार्ग', 'मं'],
      ['पौष', 'पुस', 'पौ'],
      ['माघ', 'माघ', 'मा'],
      ['फाल्गुण', 'फागुन', 'फा'],
      ['चैत्र', 'चैत', 'चै'],
    ];

    if (_isEnglish) return monthsInEnglish[month - 1][index];
    return monthsInNepali[month - 1][index];
  }

  bool get _isEnglish => _language == Language.english;

  int _getQuarter(int month) => (month / 3).ceil();

  String _getPosition(int position) {
    switch (position) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${position}th';
    }
  }

  final List<RegExp> _matchers = [
    RegExp("^'(?:[^']|'')*'"),
    RegExp('^(?:G+|y+|M+|k+|S+|E+|a+|h+|K+|H+|c+|L+|Q+|d+|D+|m+|s+|v+|z+|Z+)'),
    RegExp("^[^'GyMkSEahKHcLQdDmsvzZ]+"),
  ];
}

class _Week {
  _Week(this.name, this.shortName);
  final String name;
  final String shortName;

  String get({bool short = false}) => short ? shortName : name;
}
