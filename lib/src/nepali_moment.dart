import 'language.dart';
import 'nepali_date_time.dart';
import 'nepali_unicode.dart';
import 'nepali_utils.dart';

/// A class to calculate the moment between two dates in Nepali or English.
class NepaliMoment {
  /// Calculates the moment between the given [date] and the [referenceDate].
  /// If [showToday] is set to `true`, the result will include 'today' or 'आज'.
  /// Returns the calculated moment as a string.
  /// - [date]: The date to calculate the moment for.
  /// - [referenceDate]: The reference date to calculate the moment from.
  /// - [showToday]: If true, includes 'today' or 'आज' in the result.
  static String fromBS(
    NepaliDateTime date, {
    NepaliDateTime? referenceDate,
    bool showToday = false,
  }) {
    return _calc(date, referenceDate ?? NepaliDateTime.now(), showToday);
  }

  /// Calculates the moment between the given [date] and the [referenceDate].
  /// If [showToday] is set to `true`, the result will include 'today' or 'आज'.
  /// Returns the calculated moment as a string.
  /// - [date]: The date to calculate the moment for.
  /// - [referenceDate]: The reference date to calculate the moment from.
  /// - [showToday]: If true, includes 'today' or 'आज' in the result.
  static String fromAD(
    DateTime date, {
    DateTime? referenceDate,
    bool showToday = false,
  }) {
    return _calc(date, referenceDate ?? DateTime.now(), showToday);
  }

  /// Calculates the moment between the given [date] and the [referenceDate].
  /// If [showToday] is set to `true`, the result will include 'today' or 'आज'.
  static String _calc(DateTime date, DateTime referenceDate, bool showToday) {
    final elapsedDuration = referenceDate.difference(date);
    final elapsed = elapsedDuration.inMilliseconds;
    final isFuture = elapsed.isNegative;
    final seconds = elapsed.abs() / 1000;
    final minutes = seconds / 60;
    final hours = minutes / 60;
    final days = hours / 24;
    final months = days / 30;
    final years = days / 365;

    final isEnglish = NepaliUtils().language == Language.english;

    String momentString;
    if (seconds < 45) {
      momentString = isEnglish ? 'few moment' : 'केही क्षण';
    } else if (seconds < 90) {
      momentString = isEnglish ? 'one minute' : 'एक मिनेट';
    } else if (minutes < 45) {
      final min = minutes.round();
      momentString = isEnglish ? '$min minute' : _nepaliMoment(min, 'मिनेट');
    } else if (minutes < 90) {
      momentString = isEnglish ? 'about an hour' : 'लगभग एक घण्टा';
    } else if (hours < 24) {
      final hr = hours.round();
      momentString = isEnglish ? '$hr hours' : _nepaliMoment(hr, 'घण्टा');
    } else if (hours < 48) {
      momentString = isEnglish ? 'one day' : 'एक दिन';
    } else if (days < 30) {
      final day = days.round();
      momentString = isEnglish ? '$day days' : _nepaliMoment(day, 'दिन');
    } else if (days < 60) {
      momentString = isEnglish ? 'about a month' : 'लगभग एक महिना';
    } else if (days < 365) {
      final month = months.round();
      momentString = isEnglish ? '$month month' : _nepaliMoment(month, 'महिना');
    } else if (years < 2) {
      momentString = isEnglish ? 'about one year' : 'लगभग एक वर्ष';
    } else {
      final year = years.round();
      momentString = isEnglish ? '$year year' : _nepaliMoment(year, 'वर्ष');
    }
    if (isFuture) return momentString += isEnglish ? ' from now' : ' पछि';
    return momentString += isEnglish ? ' ago' : ' पहिले';
  }
}

/// Returns the Nepali moment string with the given [number] and [label].
/// - [number]: The number to convert to Nepali Unicode.
/// - [label]: The label to append to the number.
String _nepaliMoment(int number, String label) {
  return '${NepaliUnicode.convert(number.toString())} $label';
}
