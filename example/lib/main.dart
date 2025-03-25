import 'package:flutter/material.dart';
import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';

import 'views/calendar_date_picker_widget.dart';
import 'views/calendar_date_range_picker_widget.dart';
import 'views/date_picker_widget.dart';
import 'views/date_range_picker_widget.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      title: 'Nepali Date Picker Demo',
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Nepali Calendar"),
            centerTitle: true,
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Date Picker'),
                Tab(text: 'Calendar'),
                Tab(text: 'Date Range Picker'),
                Tab(text: 'Calendar Range'),
              ],
            ),
            actions: [
              IconButton(
                icon: Text(
                  NepaliUtils().language == Language.english ? 'ने' : 'En',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.black),
                ),
                onPressed: () {
                  NepaliUtils().language =
                      NepaliUtils().language == Language.english
                          ? Language.nepali
                          : Language.english;
                  setState(() {});
                },
              ),
            ],
          ),
          body: TabBarView(
            children: [
              const DatePickerWidget(),
              CalendarDatePickerWidget(),
              const DateRangePickerWidget(),
              const CalendarDateRangePickerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
