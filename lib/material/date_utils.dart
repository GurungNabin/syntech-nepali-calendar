import 'package:flutter/material.dart';

import '../syntech_nepali_calendar.dart';
import 'date_picker_common.dart';

/// Format a month from a given DateTime object to its full name.
/// [date] is the DateTime object to format.
/// Returns the full name of the month.
String formatMonth(DateTime date) {
  return [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ][date.month - 1];
}

/// Returns the date of a NepaliDateTime object without the time component.
/// [date] is the NepaliDateTime object to format.
/// Returns a new NepaliDateTime object with the same date as the input but with the time component set to 00:00:00.
NepaliDateTime dateOnly(NepaliDateTime date) {
  return NepaliDateTime(date.year, date.month, date.day);
}

/// Returns the date of a DateTime object without the time component.
/// [date] is the DateTime object to format.
/// Returns a new DateTime object with the same date as the input but with the time component set to 00:00:00.
DateTime dateOnlyEng(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Compare two NepaliDateTime objects to see if they are on the same day.
/// [dateA] is the first NepaliDateTime object to compare.
/// [dateB] is the second NepaliDateTime object to compare.
/// Returns true if the two dates are on the same day, false otherwise.
bool isSameDay(NepaliDateTime? dateA, NepaliDateTime? dateB) {
  return dateA?.year == dateB?.year &&
      dateA?.month == dateB?.month &&
      dateA?.day == dateB?.day;
}

/// Compare two NepaliDateTime objects to see if they are in the same month.
/// [dateA] is the first NepaliDateTime object to compare.
/// [dateB] is the second NepaliDateTime object to compare.
/// Returns true if the two dates are in the same month, false otherwise.
bool isSameMonth(NepaliDateTime? dateA, NepaliDateTime? dateB) {
  return dateA?.year == dateB?.year && dateA?.month == dateB?.month;
}

/// Compare two NepaliDateTime objects to see if they are in the same year.
/// [startDate] is the first NepaliDateTime object to compare.
/// [endDate] is the second NepaliDateTime object to compare.
/// Returns true if the two dates are in the same year, false otherwise.
int monthDelta(NepaliDateTime startDate, NepaliDateTime endDate) {
  return (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
}

/// Add a given number of months to a NepaliDateTime object.
/// [monthDate] is the NepaliDateTime object to which the months are to be added.
/// [monthsToAdd] is the number of months to add.
/// Returns a new NepaliDateTime object with the given number of months added to the input.
NepaliDateTime addMonthsToMonthDate(NepaliDateTime monthDate, int monthsToAdd) {
  var year = monthDate.year;
  var month = monthDate.month + monthsToAdd;

  year += (month - 1) ~/ 12;
  month = month % 12;
  if (month == 0) month = 12;
  return NepaliDateTime(year, month);
}

/// Return the offset of the first day of the month.
/// [year] is the year of the month.
/// [month] is the month of the year.
/// Returns the offset of the first day of the month.
int firstDayOffset(int year, int month) {
  return NepaliDateTime(year, month).weekday - 1;
}

/// Return the number of days in a month.
/// [year] is the year of the month.
/// [month] is the month of the year.
int getDaysInMonth(int year, int month) {
  return NepaliDateTime(year, month).totalDays;
}

/// Format the start date of a range.
/// [localizations] is the MaterialLocalizations object to use for the formatting.
/// [startDate] is the start date of the range.
/// [endDate] is the end date of the range.
/// Returns the formatted start date.
String formatRangeStartDate(MaterialLocalizations localizations,
    NepaliDateTime? startDate, NepaliDateTime? endDate) {
  return startDate == null
      ? localizations.dateRangeStartLabel
      : (endDate == null || startDate.year == endDate.year)
          ? NepaliDateFormat('MMMM d').format(startDate)
          : NepaliDateFormat.yMd().format(startDate);
}

/// Format the end date of a range.
/// [localizations] is the MaterialLocalizations object to use for the formatting.
/// [startDate] is the start date of the range.
/// [endDate] is the end date of the range.
/// [currentDate] is the current date.
/// Returns the formatted end date.
String formatRangeEndDate(
    MaterialLocalizations localizations,
    NepaliDateTime? startDate,
    NepaliDateTime? endDate,
    NepaliDateTime currentDate) {
  return endDate == null
      ? localizations.dateRangeEndLabel
      : (startDate != null &&
              startDate.year == endDate.year &&
              startDate.year == currentDate.year)
          ? NepaliDateFormat('MMMM d').format(endDate)
          : NepaliDateFormat.yMd().format(endDate);
}

/// Returns a NepaliDateTimeRange with the same dates as the input but with the time component set to 00:00:00.
/// [range] is the NepaliDateTimeRange object to format.
/// Returns a new NepaliDateTimeRange object with the same dates as the input but with the time component set to 00:00:00.
NepaliDateTimeRange datesOnly(NepaliDateTimeRange range) {
  return NepaliDateTimeRange(
      start: dateOnly(range.start), end: dateOnly(range.end));
}
