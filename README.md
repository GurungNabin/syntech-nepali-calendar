# Nepali Calendar Utils

[![Pub Package](https://img.shields.io/pub/v/nepali_calendar_utils)](https://pub.dev/packages/nepali_calendar_utils)
[![Licence](https://img.shields.io/badge/Licence-MIT-orange.svg)](https://github.com/yourusername/nepali_calendar_utils/blob/master/LICENSE)
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
  nepali_calendar_utils: ^0.0.1
```

Then run:

```sh
flutter pub get
```

## Usage

### Convert AD to BS
```dart
import 'package:nepali_calendar_utils/nepali_calendar_utils.dart';

void main() {
  NepaliDateTime nepaliDate = NepaliDateTime.fromDateTime(DateTime(2025, 3, 25));
  print(nepaliDate); 
}
```

### Convert BS to AD
```dart
NepaliDateTime bsDate = NepaliDateTime(2081, 12, 12);
DateTime adDate = bsDate.toDateTime();
print(adDate); 
```

### Show a Material Date Picker
```dart
import 'package:nepali_date_picker/nepali_date_picker.dart' as picker;

Future<void> pickDate(BuildContext context) async {
  NepaliDateTime selectedDate = await picker.showMaterialDatePicker(
    context: context,
    initialDate: NepaliDateTime.now(),
    firstDate: NepaliDateTime(2000),
    lastDate: NepaliDateTime(2090),
  );

  print(selectedDate);
}
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
MIT License

Copyright 2025 Nabin Gurung and Ghan Bahadur Pun.

This package includes code from the nepali_date_picker and nepali_utils packages, which are licensed under the MIT License.

Full License: https://github.com/sarbagyastha/nepali_date_picker/blob/master/LICENSE
Full License: https://github.com/sarbagyastha/nepali_utils/blob/master/LICENSE
```

