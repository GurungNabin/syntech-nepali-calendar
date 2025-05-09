# Syntech Nepali Calendar

[![Pub Package](https://img.shields.io/pub/v/nepali_calendar_utils)](https://pub.dev/packages/nepali_calendar_utils)
[![Licence](https://img.shields.io/badge/Licence-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://dart.dev/guides/language/effective-dart)

A utility package for Nepali calendar operations in Flutter.  
This package provides various functionalities for handling Nepali dates, including conversions, formatting, and more.

## Features
- Fixing of Nepali (Bikram Sambat) dates.
- Adding English date with the Nepali date to know about both the dates.
- Fixing of error in the date range picker.
- Convert between Nepali (Bikram Sambat) and English (AD) dates.
- Format Nepali dates in different styles.
- Perform date arithmetic (add/subtract days, months, years).
- Support for Material and Cupertino-style date pickers.

## Installation
Add this dependency to your `pubspec.yaml`:

```yaml
dependencies:
  syntech_nepali_calendar: ^0.0.1
```

Then run:

```sh
flutter pub get
```

## Usage

#### Material Style Date Picker

```dart
import 'package:nepali_date_picker/nepali_date_picker.dart' as picker;

NepaliDateTime _selectedDateTime = await picker.showMaterialDatePicker(
    context: context,
    initialDate: NepaliDateTime.now(),
    firstDate: NepaliDateTime(2000),
    lastDate: NepaliDateTime(2090),
    initialDatePickerMode: DatePickerMode.day,
);

print(_selectedDateTime); 
```

#### Cupertino Style Date Picker
```dart
picker.showCupertinoDatePicker(
    context: context,
    initialDate: NepaliDateTime.now(),
    firstDate: NepaliDateTime(2000),
    lastDate: NepaliDateTime(2090),
    language: _language,
    dateOrder: _dateOrder,
    onDateChanged: (newDate) {
        print(_selectedDateTime);
    },
);
```

#### Adaptive Date Picker
Shows DatePicker based on Platform. 
*i.e. Cupertino DatePicker will be shown on iOS while Material on Android and Fuchsia.*
```dart
NepaliDateTime _selectedDateTime = await picker.showAdaptiveDatePicker(
    context: context,
    initialDate: NepaliDateTime.now(),
    firstDate: NepaliDateTime(2000),
    lastDate: NepaliDateTime(2090),
    language: _language,
    dateOrder: _dateOrder, 
    initialDatePickerMode: DatePickerMode.day, 
);
```

#### Calender Picker
Shows Calendar, can be used for showing events.
```dart
NepaliCalendarDatePicker(
    initialDate: NepaliDateTime.now(),
    firstDate: NepaliDateTime(2070),
    lastDate: NepaliDateTime(2090),
    onDateChanged: (date) => _selectedDate.value = date,
    dayBuilder: (dayToBuild) { 
      return Center(
                child: Text(
                    '${dayToBuild.day}',
                    style: Theme.of(context).textTheme.caption,
               ),
          ),
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
);
```


## Example Project
An example project is included in the [`example/`](https://github.com/GurungNabin/syntech-nepali-calendar/tree/main/example) directory to demonstrate the usage of this package.

## Credits
This package is inspired by and includes functionality from the following open-source projects:

- [`nepali_date_picker`](https://pub.dev/packages/nepali_date_picker) by [Sarbagya Yadab](https://github.com/sarbagyastha)  
- [`nepali_utils`](https://pub.dev/packages/nepali_utils) by [Sarbagya Yadab](https://github.com/sarbagyastha)  

A huge thanks to them for their contributions to the Flutter community!

## License
```
BSD 3-Clause License

Copyright 2025 Nabin Gurung and Ghan Bahadur Pun.

This package includes code from the nepali_date_picker and nepali_utils packages, which are licensed under the MIT License.

Full License: https://github.com/sarbagyastha/nepali_date_picker/blob/master/LICENSE
Full License: https://github.com/sarbagyastha/nepali_utils/blob/master/LICENSE
```

