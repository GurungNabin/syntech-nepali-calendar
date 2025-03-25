import 'package:flutter/material.dart';
import 'package:syntech_nepali_calendar/material/date_picker.dart';
import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({super.key});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  NepaliDateTime? _selectedDateTime = NepaliDateTime.now();
  final String _design = 'm';
  final bool _showTimerPicker = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 20.0,
            ),
            if (_selectedDateTime != null)
              Text(
                'Selected Date: ${NepaliDateFormat("EEE, MMMM d, y hh:mm aa").format(_selectedDateTime!)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                onPressed: () async {
                  if (_design == 'm') {
                    _selectedDateTime = await showMaterialDatePicker(
                      context: context,
                      initialDate: _selectedDateTime ?? NepaliDateTime.now(),
                      firstDate: NepaliDateTime(1970, 2, 5),
                      lastDate: NepaliDateTime(2250, 11, 6),
                      initialDatePickerMode: DatePickerMode.day,
                    );
                    if (_selectedDateTime != null && _showTimerPicker) {
                      var timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          _selectedDateTime!.toDateTime(),
                        ),
                      );
                      _selectedDateTime = _selectedDateTime!.mergeTime(
                        timeOfDay?.hour ?? 0,
                        timeOfDay?.minute ?? 0,
                        0,
                      );
                    }
                    setState(() {});
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'SELECT DATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
