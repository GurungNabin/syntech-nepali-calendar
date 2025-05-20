import 'package:flutter/material.dart' hide CalendarDatePicker;
import 'package:syntech_nepali_calendar/material/date_picker.dart';
import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';

class CalendarDateRangePickerWidget extends StatefulWidget {
  const CalendarDateRangePickerWidget({super.key});

  @override
  State<CalendarDateRangePickerWidget> createState() =>
      _CalendarDateRangePickerWidgetState();
}

class _CalendarDateRangePickerWidgetState
    extends State<CalendarDateRangePickerWidget> {
  final List<NepaliDateTime> dateRange = [
    NepaliDateTime.now(),
    NepaliDateTime.now().add(const Duration(days: 5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CalendarDateRangePicker(
              initialStartDate: NepaliDateTime.now(),
              initialEndDate: NepaliDateTime.now().add(const Duration(days: 5)),
              firstDate: NepaliDateTime(1970),
              lastDate: NepaliDateTime(2100),
              onStartDateChanged: (date) {
                dateRange.first = date;
                setState(() {});
              },
              onEndDateChanged: (date) {
                dateRange.last = date;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: Text('From: ${_format(dateRange.first)}'),
            subtitle: Text('To: ${_format(dateRange.last)}'),
            tileColor: Theme.of(context).primaryColor.withAlpha(50),
          ),
        ],
      ),
    );
  }

  String _format(NepaliDateTime? dateTime) {
    if (dateTime == null) return '';
    return NepaliDateFormat.yMMMMEEEEd().format(dateTime);
  }
}
