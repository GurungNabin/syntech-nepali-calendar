import 'package:flutter/material.dart' hide CalendarDatePicker;
import 'package:syntech_nepali_calendar/material/nepali_calendar_date_picker.dart';
import 'package:syntech_nepali_calendar/syntech_nepali_calendar.dart';


class CalendarDatePickerWidget extends StatelessWidget {
  final ValueNotifier<NepaliDateTime> _selectedDate =
      ValueNotifier(NepaliDateTime.now());

  final ValueNotifier<List<Event>> _eventsNotifier =
      ValueNotifier<List<Event>>([
    Event(date: NepaliDateTime.now(), eventTitles: ['Today 1']),
    Event(
        date: NepaliDateTime.now().add(const Duration(days: 30)),
        eventTitles: ['Holiday 1']),
    Event(
        date: NepaliDateTime.now().subtract(const Duration(days: 5)),
        eventTitles: ['Event 1']),
    Event(
        date: NepaliDateTime.now().add(const Duration(days: 8)),
        eventTitles: ['Seminar 1']),
  ]);

  CalendarDatePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: NepaliCalendarDatePicker(
              initialDate: NepaliDateTime.now(),
              firstDate: NepaliDateTime(2070),
              lastDate: NepaliDateTime(2090),
              onDateChanged: (date) => _selectedDate.value = date,
              dayBuilder: (dayToBuild) {
                final isSelectedDay =
                    _selectedDate.value.toIso8601String().substring(0, 10) ==
                        dayToBuild.toIso8601String().substring(0, 10);

                return GestureDetector(
                  onLongPress: () => _showAddEventDialog(context, dayToBuild),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              NepaliUtils().language == Language.english
                                  ? '${dayToBuild.day}'
                                  : NepaliUnicode.convert('${dayToBuild.day}'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: isSelectedDay
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: Text(
                                '${dayToBuild.toDateTime().day}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isSelectedDay
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<List<Event>>(
                        valueListenable: _eventsNotifier,
                        builder: (context, events, _) {
                          if (events.any(
                              (event) => _dayEquals(event.date, dayToBuild))) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.purple),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                );
              },
              selectedDayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              todayDecoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.purple,
                  width: 1,
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<NepaliDateTime>(
              valueListenable: _selectedDate,
              builder: (context, date, _) {
                return ValueListenableBuilder<List<Event>>(
                  valueListenable: _eventsNotifier,
                  builder: (context, events, _) {
                    Event? event;
                    try {
                      event =
                          events.firstWhere((e) => _dayEquals(e.date, date));
                    } on StateError {
                      event = null;
                    }

                    if (event == null) {
                      return const Center(
                        child: Text('No Events'),
                      );
                    }

                    return ListView.separated(
                      itemCount: event.eventTitles.length,
                      itemBuilder: (context, index) => ListTile(
                          leading: TodayWidget(
                            today: date,
                          ),
                          title: Text(
                            event!.eventTitles[index],
                          ),
                          onTap: () {
                            if (event != null) {
                              _showEditDeleteEventDialog(context, event, index);
                            }
                          }),
                      separatorBuilder: (context, _) => const Divider(
                        color: Colors.red,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context, _selectedDate.value);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, NepaliDateTime selectedDate) {
    final TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Event',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Date: ${NepaliDateFormat("MMMM d, yyyy").format(selectedDate)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: eventController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'Enter event title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (eventController.text.isNotEmpty) {
                  final newEvent = Event(
                    date: selectedDate,
                    eventTitles: [eventController.text],
                  );
                  _eventsNotifier.value = [..._eventsNotifier.value, newEvent];
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDeleteEventDialog(
      BuildContext context, Event event, int eventIndex) {
    final TextEditingController eventController =
        TextEditingController(text: event.eventTitles[eventIndex]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit/Delete Event'),
          content: TextField(
            controller: eventController,
            decoration: const InputDecoration(hintText: 'Edit event title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                if (eventController.text.isNotEmpty) {
                  event.eventTitles[eventIndex] = eventController.text;
                  _eventsNotifier.value = [..._eventsNotifier.value];
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                event.eventTitles.removeAt(eventIndex);
                if (event.eventTitles.isEmpty) {
                  _eventsNotifier.value =
                      _eventsNotifier.value.where((e) => e != event).toList();
                } else {
                  _eventsNotifier.value = [..._eventsNotifier.value];
                }
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  bool _dayEquals(NepaliDateTime? a, NepaliDateTime? b) =>
      a != null &&
      b != null &&
      a.toIso8601String().substring(0, 10) ==
          b.toIso8601String().substring(0, 10);
}

class TodayWidget extends StatelessWidget {
  final NepaliDateTime today;

  const TodayWidget({
    super.key,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  NepaliDateFormat.EEEE()
                      .format(today)
                      .substring(0, 3)
                      .toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(
              flex: 2,
            ),
            Text(
              NepaliDateFormat.d().format(today),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class Event {
  final NepaliDateTime date;

  final List<String> eventTitles;

  Event({required this.date, required this.eventTitles});
}
