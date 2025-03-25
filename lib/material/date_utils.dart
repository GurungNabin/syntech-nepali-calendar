import 'package:flutter/material.dart';

import '../syntech_nepali_calendar.dart';
import 'date_picker_common.dart';

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

NepaliDateTime dateOnly(NepaliDateTime date) {
  return NepaliDateTime(date.year, date.month, date.day);
}

DateTime dateOnlyEng(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool isSameDay(NepaliDateTime? dateA, NepaliDateTime? dateB) {
  return dateA?.year == dateB?.year &&
      dateA?.month == dateB?.month &&
      dateA?.day == dateB?.day;
}

bool isSameMonth(NepaliDateTime? dateA, NepaliDateTime? dateB) {
  return dateA?.year == dateB?.year && dateA?.month == dateB?.month;
}

int monthDelta(NepaliDateTime startDate, NepaliDateTime endDate) {
  return (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
}

NepaliDateTime addMonthsToMonthDate(NepaliDateTime monthDate, int monthsToAdd) {
  var year = monthDate.year;
  var month = monthDate.month + monthsToAdd;

  year += (month - 1) ~/ 12;
  month = month % 12;
  if (month == 0) month = 12;
  return NepaliDateTime(year, month);
}

int firstDayOffset(int year, int month) {
  return NepaliDateTime(year, month).weekday - 1;
}

int getDaysInMonth(int year, int month) {
  return NepaliDateTime(year, month).totalDays;
}

String formatRangeStartDate(MaterialLocalizations localizations,
    NepaliDateTime? startDate, NepaliDateTime? endDate) {
  return startDate == null
      ? localizations.dateRangeStartLabel
      : (endDate == null || startDate.year == endDate.year)
          ? NepaliDateFormat('MMMM d').format(startDate)
          : NepaliDateFormat.yMd().format(startDate);
}

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

NepaliDateTimeRange datesOnly(NepaliDateTimeRange range) {
  return NepaliDateTimeRange(
      start: dateOnly(range.start), end: dateOnly(range.end));
}
