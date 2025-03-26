import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../syntech_nepali_calendar.dart';
import 'date_picker_common.dart' as common;
import 'date_picker_common.dart';
import 'date_utils.dart' as utils;
import 'input_date_picker_form_field.dart' as idp;
import 'nepali_calendar_date_picker.dart' as cdp;

const Size _calendarPortraitDialogSize = Size(330.0, 518.0);
const Size _calendarLandscapeDialogSize = Size(496.0, 346.0);
const Size _inputPortraitDialogSize = Size(330.0, 270.0);
const Size _inputLandscapeDialogSize = Size(496, 160.0);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);
const double _inputFormPortraitHeight = 98.0;
const double _inputFormLandscapeHeight = 108.0;

Future<NepaliDateTime?> showMaterialDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  NepaliDateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  common.SelectableDayPredicate? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
}) async {
  initialDate = utils.dateOnly(initialDate);
  firstDate = utils.dateOnly(firstDate);
  lastDate = utils.dateOnly(lastDate);
  assert(!lastDate.isBefore(firstDate),
      'lastDate $lastDate must be on or after firstDate $firstDate.');
  assert(!initialDate.isBefore(firstDate),
      'initialDate $initialDate must be on or after firstDate $firstDate.');
  assert(!initialDate.isAfter(lastDate),
      'initialDate $initialDate must be on or before lastDate $lastDate.');
  assert(selectableDayPredicate == null || selectableDayPredicate(initialDate),
      'Provided initialDate $initialDate must satisfy provided selectableDayPredicate.');
  assert(debugCheckHasMaterialLocalizations(context));

  Widget dialog = _DatePickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    selectableDayPredicate: selectableDayPredicate,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    initialCalendarMode: initialDatePickerMode,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    fieldHintText: fieldHintText,
    fieldLabelText: fieldLabelText,
  );

  if (textDirection != null) {
    dialog = Directionality(
      textDirection: textDirection,
      child: dialog,
    );
  }

  if (locale != null) {
    dialog = Localizations.override(
      context: context,
      locale: locale,
      child: dialog,
    );
  }

  return showDialog<NepaliDateTime>(
    context: context,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

class _DatePickerDialog extends StatefulWidget {
  _DatePickerDialog({
    required NepaliDateTime initialDate,
    required NepaliDateTime firstDate,
    required NepaliDateTime lastDate,
    NepaliDateTime? currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.cancelText,
    this.confirmText,
    this.helpText,
    this.initialCalendarMode = DatePickerMode.day,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
  })  : initialDate = utils.dateOnly(initialDate),
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate),
        currentDate = utils.dateOnly(currentDate ?? NepaliDateTime.now()) {
    assert(!this.lastDate.isBefore(this.firstDate),
        'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.');
    assert(!this.initialDate.isBefore(this.firstDate),
        'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.');
    assert(!this.initialDate.isAfter(this.lastDate),
        'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.');
    assert(
        selectableDayPredicate == null ||
            selectableDayPredicate!(this.initialDate),
        'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate');
  }

  final NepaliDateTime initialDate;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final NepaliDateTime currentDate;

  final DatePickerEntryMode initialEntryMode;

  final common.SelectableDayPredicate? selectableDayPredicate;

  final String? cancelText;

  final String? confirmText;

  final String? helpText;

  final DatePickerMode initialCalendarMode;

  final String? errorFormatText;

  final String? errorInvalidText;

  final String? fieldHintText;

  final String? fieldLabelText;

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late DatePickerEntryMode _entryMode;
  late NepaliDateTime _selectedDate;
  late ValueNotifier<AutovalidateMode> _autoValidateMode;
  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _entryMode = widget.initialEntryMode;
    _selectedDate = widget.initialDate;
    _autoValidateMode = ValueNotifier(AutovalidateMode.disabled);
  }

  @override
  void dispose() {
    _autoValidateMode.dispose();
    super.dispose();
  }

  void _handleOk() {
    if (_entryMode == DatePickerEntryMode.input) {
      final form = _formKey.currentState!;
      if (!form.validate()) {
        _autoValidateMode.value = AutovalidateMode.always;
        return;
      }
      form.save();
    }
    Navigator.pop(context, _selectedDate);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode) {
        case DatePickerEntryMode.calendar:
          _autoValidateMode.value = AutovalidateMode.disabled;
          _entryMode = DatePickerEntryMode.input;
          break;
        case DatePickerEntryMode.input:
        default:
          _formKey.currentState!.save();
          _entryMode = DatePickerEntryMode.calendar;
          break;
      }
    });
  }

  void _handleDateChanged(NepaliDateTime date) {
    setState(() => _selectedDate = date);
  }

  Size _dialogSize(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    switch (_entryMode) {
      case DatePickerEntryMode.calendar:
        switch (orientation) {
          case Orientation.portrait:
            return _calendarPortraitDialogSize;
          case Orientation.landscape:
            return _calendarLandscapeDialogSize;
        }
      case DatePickerEntryMode.input:
      default:
        switch (orientation) {
          case Orientation.portrait:
            return _inputPortraitDialogSize;
          case Orientation.landscape:
            return _inputLandscapeDialogSize;
        }
    }
  }

  static final Map<LogicalKeySet, Intent> _formShortcutMap =
      <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.enter): const NextFocusIntent(),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orientation = MediaQuery.of(context).orientation;
    final textTheme = theme.textTheme;
    final textScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    final dateText = NepaliDateFormat(NepaliUtils().language == Language.english
            ? 'EE, MMM d'
            : 'EE, MMMM d')
        .format(_selectedDate);

    final onPrimarySurface = colorScheme.brightness == Brightness.light
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final dateStyle = orientation == Orientation.landscape
        ? textTheme.headlineSmall?.copyWith(color: onPrimarySurface)
        : textTheme.headlineMedium?.copyWith(color: onPrimarySurface);

    final Widget actions = Container(
      decoration: const BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide())),
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            onPressed: _handleCancel,
            child: Text(
              widget.cancelText ??
                  (NepaliUtils().language == Language.english
                      ? 'CANCEL'
                      : 'रद्द गर्नुहोस'),
            ),
          ),
          TextButton(
            onPressed: _handleOk,
            child: Text(
              widget.confirmText ??
                  (NepaliUtils().language == Language.english ? 'OK' : 'ठिक छ'),
            ),
          ),
        ],
      ),
    );

    cdp.NepaliCalendarDatePicker calendarDatePicker() {
      return cdp.NepaliCalendarDatePicker(
        key: _calendarPickerKey,
        initialDate: _selectedDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        currentDate: widget.currentDate,
        onDateChanged: _handleDateChanged,
        selectableDayPredicate: widget.selectableDayPredicate,
        initialCalendarMode: widget.initialCalendarMode,
      );
    }

    Widget inputDatePicker() {
      return ValueListenableBuilder<AutovalidateMode>(
        valueListenable: _autoValidateMode,
        builder: (context, autoValidateMode, child) {
          return Form(
            key: _formKey,
            autovalidateMode: autoValidateMode,
            child: child!,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          height: orientation == Orientation.portrait
              ? _inputFormPortraitHeight
              : _inputFormLandscapeHeight,
          child: Shortcuts(
            shortcuts: _formShortcutMap,
            child: Column(
              children: [
                const Spacer(),
                idp.InputDatePickerFormField(
                  initialDate: _selectedDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateSubmitted: _handleDateChanged,
                  onDateSaved: _handleDateChanged,
                  selectableDayPredicate: widget.selectableDayPredicate,
                  errorFormatText: widget.errorFormatText,
                  errorInvalidText: widget.errorInvalidText,
                  fieldHintText: widget.fieldHintText,
                  fieldLabelText: widget.fieldLabelText,
                  autofocus: true,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    Widget picker;
    final Widget? entryModeButton;
    switch (_entryMode) {
      case DatePickerEntryMode.calendar:
        picker = calendarDatePicker();
        entryModeButton = IconButton(
          icon: const Icon(Icons.edit),
          color: onPrimarySurface,
          tooltip: 'Switch to input',
          onPressed: _handleEntryModeToggle,
        );

        break;

      case DatePickerEntryMode.input:
      default:
        picker = inputDatePicker();
        entryModeButton = IconButton(
          icon: const Icon(Icons.calendar_today),
          color: onPrimarySurface,
          tooltip: 'Switch to calendar',
          onPressed: _handleEntryModeToggle,
        );
        break;
    }

    final Widget header = DatePickerHeader(
      helpText: widget.helpText ??
          (NepaliUtils().language == Language.english
              ? 'SELECT DATE'
              : 'मिति चयन गर्नुहोस'),
      titleText: dateText,
      titleStyle: dateStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    final dialogSize = _dialogSize(context) * textScaler.scale(1.0);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: Builder(
            builder: (BuildContext context) {
              switch (orientation) {
                case Orientation.portrait:
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      header,
                      Expanded(child: picker),
                      actions,
                    ],
                  );
                case Orientation.landscape:
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      header,
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(child: picker),
                            actions,
                          ],
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

class DatePickerHeader extends StatelessWidget {
  const DatePickerHeader({
    super.key,
    required this.helpText,
    required this.titleText,
    this.titleSemanticsLabel,
    required this.titleStyle,
    required this.orientation,
    this.isShort = false,
    this.entryModeButton,
  });

  static const double _datePickerHeaderLandscapeWidth = 152.0;
  static const double _datePickerHeaderPortraitHeight = 120.0;
  static const double _headerPaddingLandscape = 16.0;

  final String helpText;

  final String titleText;

  final String? titleSemanticsLabel;

  final TextStyle? titleStyle;

  final Orientation orientation;

  final bool isShort;

  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDark = colorScheme.brightness == Brightness.dark;
    final primarySurfaceColor =
        isDark ? colorScheme.surface : colorScheme.primary;
    final onPrimarySurfaceColor =
        isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    final helpStyle = textTheme.labelSmall?.copyWith(
      color: onPrimarySurfaceColor,
    );

    final help = Text(
      helpText,
      style: helpStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final title = Text(
      titleText,
      semanticsLabel: titleSemanticsLabel ?? titleText,
      style: titleStyle,
      maxLines: (isShort || orientation == Orientation.portrait) ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );

    switch (orientation) {
      case Orientation.portrait:
        return SizedBox(
          height: _datePickerHeaderPortraitHeight,
          child: Material(
            color: primarySurfaceColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 24,
                    end: 12,
                  ),
                  child: Flexible(child: help),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 24,
                    end: 12,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: title),
                      if (entryModeButton != null) entryModeButton!,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case Orientation.landscape:
        return SizedBox(
          width: _datePickerHeaderLandscapeWidth,
          child: Material(
            color: primarySurfaceColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _headerPaddingLandscape,
                  ),
                  child: help,
                ),
                SizedBox(height: isShort ? 16 : 56),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _headerPaddingLandscape,
                    ),
                    child: title,
                  ),
                ),
                if (entryModeButton != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: entryModeButton,
                  ),
              ],
            ),
          ),
        );
    }
  }
}

Future<NepaliDateTimeRange?> showMaterialDateRangePicker({
  required BuildContext context,
  NepaliDateTimeRange? initialDateRange,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,
  NepaliDateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? saveText,
  String? errorFormatText,
  String? errorInvalidText,
  String? errorInvalidRangeText,
  String? fieldStartHintText,
  String? fieldEndHintText,
  String? fieldStartLabelText,
  String? fieldEndLabelText,
  Locale? locale,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
}) async {
  assert(
      initialDateRange == null ||
          !initialDateRange.start.isAfter(initialDateRange.end),
      'initialDateRange\'s start date must not be after it\'s end date.');
  initialDateRange =
      initialDateRange == null ? null : utils.datesOnly(initialDateRange);
  firstDate = utils.dateOnly(firstDate);
  lastDate = utils.dateOnly(lastDate);
  assert(!lastDate.isBefore(firstDate),
      'lastDate $lastDate must be on or after firstDate $firstDate.');
  assert(
      initialDateRange == null || !initialDateRange.start.isBefore(firstDate),
      'initialDateRange\'s start date must be on or after firstDate $firstDate.');
  assert(initialDateRange == null || !initialDateRange.end.isBefore(firstDate),
      'initialDateRange\'s end date must be on or after firstDate $firstDate.');
  assert(initialDateRange == null || !initialDateRange.start.isAfter(lastDate),
      'initialDateRange\'s start date must be on or before lastDate $lastDate.');
  assert(initialDateRange == null || !initialDateRange.end.isAfter(lastDate),
      'initialDateRange\'s end date must be on or before lastDate $lastDate.');
  currentDate = utils.dateOnly(currentDate ?? NepaliDateTime.now());
  assert(debugCheckHasMaterialLocalizations(context));

  Widget dialog = _DateRangePickerDialog(
    initialDateRange: initialDateRange,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    saveText: saveText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    errorInvalidRangeText: errorInvalidRangeText,
    fieldStartHintText: fieldStartHintText,
    fieldEndHintText: fieldEndHintText,
    fieldStartLabelText: fieldStartLabelText,
    fieldEndLabelText: fieldEndLabelText,
  );

  if (textDirection != null) {
    dialog = Directionality(
      textDirection: textDirection,
      child: dialog,
    );
  }

  if (locale != null) {
    dialog = Localizations.override(
      context: context,
      locale: locale,
      child: dialog,
    );
  }

  return showDialog<NepaliDateTimeRange>(
    context: context,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    useSafeArea: false,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

class _DateRangePickerDialog extends StatefulWidget {
  const _DateRangePickerDialog({
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
    this.currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.saveText,
    this.errorInvalidRangeText,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
  });

  final NepaliDateTimeRange? initialDateRange;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final NepaliDateTime? currentDate;
  final DatePickerEntryMode initialEntryMode;
  final String? cancelText;
  final String? confirmText;
  final String? saveText;
  final String? helpText;
  final String? errorInvalidRangeText;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? fieldStartHintText;
  final String? fieldEndHintText;
  final String? fieldStartLabelText;
  final String? fieldEndLabelText;

  @override
  _DateRangePickerDialogState createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  late DatePickerEntryMode _entryMode;
  NepaliDateTime? _selectedStart;
  NepaliDateTime? _selectedEnd;
  late bool _autoValidate;
  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<_InputDateRangePickerState> _inputPickerKey =
      GlobalKey<_InputDateRangePickerState>();

  @override
  void initState() {
    super.initState();
    _selectedStart = widget.initialDateRange?.start;
    _selectedEnd = widget.initialDateRange?.end;
    _entryMode = widget.initialEntryMode;
    _autoValidate = false;
  }

  void _handleOk() {
    if (_entryMode == DatePickerEntryMode.input) {
      final picker = _inputPickerKey.currentState;
      if (!picker!.validate()) {
        setState(() {
          _autoValidate = true;
        });
        return;
      }
    }
    final selectedRange = _hasSelectedDateRange
        ? NepaliDateTimeRange(start: _selectedStart!, end: _selectedEnd!)
        : null;

    Navigator.pop(context, selectedRange);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode) {
        case DatePickerEntryMode.calendar:
          _autoValidate = false;
          _entryMode = DatePickerEntryMode.input;
          break;

        case DatePickerEntryMode.input:
        default:
          if (_selectedStart != null &&
              (_selectedStart!.isBefore(widget.firstDate) ||
                  _selectedStart!.isAfter(widget.lastDate))) {
            _selectedStart = null;
            _selectedEnd = null;
          }
          if (_selectedEnd != null &&
              (_selectedEnd!.isBefore(widget.firstDate) ||
                  _selectedEnd!.isAfter(widget.lastDate))) {
            _selectedEnd = null;
          }
          if (_selectedStart != null &&
              _selectedEnd != null &&
              _selectedStart!.isAfter(_selectedEnd!)) {
            _selectedEnd = null;
          }
          _entryMode = DatePickerEntryMode.calendar;
          break;
      }
    });
  }

  void _handleStartDateChanged(NepaliDateTime? date) {
    setState(() => _selectedStart = date);
  }

  void _handleEndDateChanged(NepaliDateTime? date) {
    setState(() => _selectedEnd = date);
  }

  bool get _hasSelectedDateRange =>
      _selectedStart != null && _selectedEnd != null;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    final textScaler = mediaQuery.textScaler.clamp(maxScaleFactor: 1.3);
    final localizations = MaterialLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final onPrimarySurface =
        colors.brightness == Brightness.light ? colors.primary : colors.surface;

    Widget contents;
    Size size;
    ShapeBorder? shape;
    double elevation;
    EdgeInsets insetPadding;
    final showEntryModeButton = _entryMode == DatePickerEntryMode.calendar ||
        _entryMode == DatePickerEntryMode.input;
    switch (_entryMode) {
      case DatePickerEntryMode.calendar:
        contents = _CalendarRangePickerDialog(
          key: _calendarPickerKey,
          selectedStartDate: _selectedStart,
          selectedEndDate: _selectedEnd,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          currentDate: widget.currentDate,
          onStartDateChanged: _handleStartDateChanged,
          onEndDateChanged: _handleEndDateChanged,
          onConfirm: _hasSelectedDateRange ? _handleOk : null,
          onCancel: _handleCancel,
          entryModeButton: showEntryModeButton
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  padding: EdgeInsets.zero,
                  color: onPrimarySurface,
                  tooltip: localizations.inputDateModeButtonLabel,
                  onPressed: _handleEntryModeToggle,
                )
              : null,
          confirmText: widget.saveText ?? localizations.saveButtonLabel,
          helpText: widget.helpText ?? localizations.dateRangePickerHelpText,
        );
        size = mediaQuery.size;
        insetPadding = const EdgeInsets.all(0.0);
        shape = const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.zero));
        elevation = 0;
        break;

      case DatePickerEntryMode.input:
      default:
        contents = _InputDateRangePickerDialog(
          selectedStartDate: _selectedStart,
          selectedEndDate: _selectedEnd,
          currentDate: widget.currentDate,
          picker: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: orientation == Orientation.portrait
                ? _inputFormPortraitHeight
                : _inputFormLandscapeHeight,
            child: Column(
              children: <Widget>[
                const Spacer(),
                InputDateRangePicker(
                  key: _inputPickerKey,
                  initialStartDate: _selectedStart,
                  initialEndDate: _selectedEnd,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onStartDateChanged: _handleStartDateChanged,
                  onEndDateChanged: _handleEndDateChanged,
                  autofocus: true,
                  autovalidate: _autoValidate,
                  helpText: widget.helpText,
                  errorInvalidRangeText: widget.errorInvalidRangeText,
                  errorFormatText: widget.errorFormatText,
                  errorInvalidText: widget.errorInvalidText,
                  fieldStartHintText: widget.fieldStartHintText,
                  fieldEndHintText: widget.fieldEndHintText,
                  fieldStartLabelText: widget.fieldStartLabelText,
                  fieldEndLabelText: widget.fieldEndLabelText,
                ),
                const Spacer(),
              ],
            ),
          ),
          onConfirm: _handleOk,
          onCancel: _handleCancel,
          entryModeButton: showEntryModeButton
              ? IconButton(
                  icon: const Icon(Icons.calendar_today),
                  padding: EdgeInsets.zero,
                  color: onPrimarySurface,
                  tooltip: localizations.calendarModeButtonLabel,
                  onPressed: _handleEntryModeToggle,
                )
              : null,
          onToggleEntryMode: _handleEntryModeToggle,
          confirmText: widget.confirmText ?? localizations.okButtonLabel,
          cancelText: widget.cancelText ?? localizations.cancelButtonLabel,
          helpText: widget.helpText ?? localizations.dateRangePickerHelpText,
        );
        final dialogTheme = Theme.of(context).dialogTheme;
        size = orientation == Orientation.portrait
            ? _inputPortraitDialogSize
            : _inputLandscapeDialogSize;
        insetPadding =
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);
        shape = dialogTheme.shape;
        elevation = dialogTheme.elevation ?? 24;
        break;
    }

    return Dialog(
      insetPadding: insetPadding,
      shape: shape,
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: size.width,
        height: size.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: Builder(builder: (BuildContext context) {
            return contents;
          }),
        ),
      ),
    );
  }
}

class _CalendarRangePickerDialog extends StatelessWidget {
  const _CalendarRangePickerDialog({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onConfirm,
    required this.onCancel,
    required this.confirmText,
    required this.helpText,
    this.entryModeButton,
  });

  final NepaliDateTime? selectedStartDate;
  final NepaliDateTime? selectedEndDate;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final NepaliDateTime? currentDate;
  final ValueChanged<NepaliDateTime> onStartDateChanged;
  final ValueChanged<NepaliDateTime> onEndDateChanged;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String helpText;
  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final textTheme = theme.textTheme;
    final headerForeground = colorScheme.brightness == Brightness.light
        ? colorScheme.primary
        : colorScheme.surface;
    final headerDisabledForeground = headerForeground.withValues(alpha: 0.38);
    final startDateText = utils.formatRangeStartDate(
        localizations, selectedStartDate, selectedEndDate);
    final endDateText = utils.formatRangeEndDate(localizations,
        selectedStartDate, selectedEndDate, NepaliDateTime.now());
    final headlineStyle = textTheme.headlineSmall;
    final startDateStyle = headlineStyle?.apply(
        color: selectedStartDate != null
            ? headerForeground
            : headerDisabledForeground);
    final endDateStyle = headlineStyle?.apply(
        color: selectedEndDate != null
            ? headerForeground
            : headerDisabledForeground);
    final saveButtonStyle = textTheme.labelLarge?.apply(
        color: onConfirm != null ? headerForeground : headerDisabledForeground);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(
            onPressed: onCancel,
          ),
          actions: <Widget>[
            if (orientation == Orientation.landscape && entryModeButton != null)
              entryModeButton!,
            TextButton(
              onPressed: onConfirm,
              child: Text(confirmText, style: saveButtonStyle),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 64),
            child: Row(children: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width < 360 ? 42 : 72),
              Expanded(
                child: Semantics(
                  label: '$helpText $startDateText to $endDateText',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        helpText,
                        style: textTheme.labelSmall!.apply(
                          color: headerForeground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Text(
                            startDateText,
                            style: startDateStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            ' – ',
                            style: startDateStyle,
                          ),
                          Flexible(
                            child: Text(
                              endDateText,
                              style: endDateStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (orientation == Orientation.portrait &&
                  entryModeButton != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: entryModeButton!,
                ),
            ]),
          ),
        ),
        body: CalendarDateRangePicker(
          initialStartDate: selectedStartDate,
          initialEndDate: selectedEndDate,
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: currentDate,
          onStartDateChanged: onStartDateChanged,
          onEndDateChanged: onEndDateChanged,
        ),
      ),
    );
  }
}

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _monthItemHeaderHeight = 58.0;
const double _monthItemFooterHeight = 12.0;
const double _monthItemRowHeight = 42.0;
const double _monthItemSpaceBetweenRows = 8.0;
const double _horizontalPadding = 8.0;
const double _maxCalendarWidthLandscape = 384.0;
const double _maxCalendarWidthPortrait = 480.0;

class CalendarDateRangePicker extends StatefulWidget {
  CalendarDateRangePicker({
    super.key,
    NepaliDateTime? initialStartDate,
    NepaliDateTime? initialEndDate,
    required NepaliDateTime firstDate,
    required NepaliDateTime lastDate,
    NepaliDateTime? currentDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  })  : initialStartDate =
            initialStartDate != null ? utils.dateOnly(initialStartDate) : null,
        initialEndDate =
            initialEndDate != null ? utils.dateOnly(initialEndDate) : null,
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate),
        currentDate = utils.dateOnly(currentDate ?? NepaliDateTime.now()) {
    if (initialStartDate != null &&
        initialEndDate != null &&
        initialStartDate.isAfter(initialEndDate)) {
      final temp = initialStartDate;
      initialStartDate = initialEndDate;
      initialEndDate = temp;
    }

    assert(
        initialStartDate == null ||
            initialEndDate == null ||
            !initialStartDate.isAfter(initialEndDate),
        'initialStartDate must be on or before initialEndDate.');

    assert(!lastDate.isBefore(firstDate),
        'firstDate must be on or before lastDate.');
  }

  final NepaliDateTime? initialStartDate;

  final NepaliDateTime? initialEndDate;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final NepaliDateTime currentDate;

  final ValueChanged<NepaliDateTime>? onStartDateChanged;

  final ValueChanged<NepaliDateTime>? onEndDateChanged;

  @override
  State<CalendarDateRangePicker> createState() =>
      _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<CalendarDateRangePicker> {
  final GlobalKey _scrollViewKey = GlobalKey();
  NepaliDateTime? _startDate;
  NepaliDateTime? _endDate;
  int _initialMonthIndex = 0;
  late ScrollController _controller;
  late bool _showWeekBottomDivider;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;

    final initialDate = widget.initialStartDate ?? widget.currentDate;
    if (!initialDate.isBefore(widget.firstDate) &&
        !initialDate.isAfter(widget.lastDate)) {
      _initialMonthIndex = utils.monthDelta(widget.firstDate, initialDate);
    }

    _showWeekBottomDivider = _initialMonthIndex != 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.offset <= _controller.position.minScrollExtent) {
      setState(() {
        _showWeekBottomDivider = false;
      });
    } else if (!_showWeekBottomDivider) {
      setState(() {
        _showWeekBottomDivider = true;
      });
    }
  }

  int get _numberOfMonths =>
      utils.monthDelta(widget.firstDate, widget.lastDate) + 1;

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      default:
        break;
    }
  }

  void _updateSelection(NepaliDateTime date) {
    _vibrate();
    setState(() {
      if (_startDate != null && _endDate != null) {
        if (date.isAtSameMomentAs(_startDate!) ||
            date.isAtSameMomentAs(_endDate!)) {
          _startDate = date;
          widget.onStartDateChanged?.call(_startDate!);
        } else if (!date.isBefore(_startDate!)) {
          _endDate = date;
          widget.onEndDateChanged?.call(_endDate!);
        } else {
          _startDate = date;
          widget.onStartDateChanged?.call(_startDate!);
        }
      } else if (_startDate != null && _endDate == null) {
        if (!date.isBefore(_startDate!)) {
          _endDate = date;
          widget.onEndDateChanged?.call(_endDate!);
        } else {
          _startDate = date;
          widget.onStartDateChanged?.call(_startDate!);
        }
      } else {
        _startDate = date;
        widget.onStartDateChanged?.call(_startDate!);
      }
    });
  }

  Widget _buildMonthItem(
      BuildContext context, int index, bool beforeInitialMonth) {
    final monthIndex = beforeInitialMonth
        ? _initialMonthIndex - index - 1
        : _initialMonthIndex + index;
    final month = utils.addMonthsToMonthDate(widget.firstDate, monthIndex);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.all(4.0),
      child: _MonthItem(
        selectedDateStart: _startDate,
        selectedDateEnd: _endDate,
        currentDate: widget.currentDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        displayedMonth: month,
        onChanged: _updateSelection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sliverAfterKey = Key('sliverAfterKey');

    return Column(
      children: <Widget>[
        _DayHeaders(),
        if (_showWeekBottomDivider) const Divider(height: 0),
        Expanded(
          child: _CalendarKeyboardNavigator(
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialFocusedDay:
                _startDate ?? widget.initialStartDate ?? widget.currentDate,
            child: CustomScrollView(
              key: _scrollViewKey,
              controller: _controller,
              center: sliverAfterKey,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) =>
                        _buildMonthItem(context, index, true),
                    childCount: _initialMonthIndex,
                  ),
                ),
                SliverList(
                  key: sliverAfterKey,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) =>
                        _buildMonthItem(context, index, false),
                    childCount: _numberOfMonths - _initialMonthIndex,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarKeyboardNavigator extends StatefulWidget {
  const _CalendarKeyboardNavigator({
    required this.child,
    required this.firstDate,
    required this.lastDate,
    required this.initialFocusedDay,
  });

  final Widget child;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final NepaliDateTime initialFocusedDay;

  @override
  _CalendarKeyboardNavigatorState createState() =>
      _CalendarKeyboardNavigatorState();
}

class _CalendarKeyboardNavigatorState
    extends State<_CalendarKeyboardNavigator> {
  late Map<LogicalKeySet, Intent> _shortcutMap;
  late Map<Type, Action<Intent>> _actionMap;
  late FocusNode _dayGridFocus;
  TraversalDirection? _dayTraversalDirection;
  NepaliDateTime? _focusedDay;

  @override
  void initState() {
    super.initState();

    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft):
          const DirectionalFocusIntent(TraversalDirection.left),
      LogicalKeySet(LogicalKeyboardKey.arrowRight):
          const DirectionalFocusIntent(TraversalDirection.right),
      LogicalKeySet(LogicalKeyboardKey.arrowDown):
          const DirectionalFocusIntent(TraversalDirection.down),
      LogicalKeySet(LogicalKeyboardKey.arrowUp):
          const DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent:
          CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: _handleGridPreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: _handleDirectionFocus),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void dispose() {
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused) {
        _focusedDay ??= widget.initialFocusedDay;
      }
    });
  }

  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final nextDate = _nextDateInDirection(_focusedDay!, intent.direction);
      if (nextDate != null) {
        _focusedDay = nextDate;
        _dayTraversalDirection = intent.direction;
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset =
      <TraversalDirection, int>{
    TraversalDirection.up: -DateTime.daysPerWeek,
    TraversalDirection.right: 1,
    TraversalDirection.down: DateTime.daysPerWeek,
    TraversalDirection.left: -1,
  };

  int _dayDirectionOffset(
      TraversalDirection traversalDirection, TextDirection textDirection) {
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left) {
        traversalDirection = TraversalDirection.right;
      } else if (traversalDirection == TraversalDirection.right) {
        traversalDirection = TraversalDirection.left;
      }
    }
    return _directionOffset[traversalDirection]!;
  }

  NepaliDateTime? _nextDateInDirection(
      NepaliDateTime date, TraversalDirection direction) {
    final textDirection = Directionality.of(context);
    final nextDate =
        date.add(Duration(days: _dayDirectionOffset(direction, textDirection)));
    if (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      return nextDate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: _shortcutMap,
      actions: _actionMap,
      focusNode: _dayGridFocus,
      onFocusChange: _handleGridFocusChange,
      child: _FocusedDate(
        date: _dayGridFocus.hasFocus ? _focusedDay : null,
        scrollDirection: _dayGridFocus.hasFocus ? _dayTraversalDirection : null,
        child: widget.child,
      ),
    );
  }
}

class _FocusedDate extends InheritedWidget {
  const _FocusedDate({
    required super.child,
    this.date,
    this.scrollDirection,
  });

  final NepaliDateTime? date;
  final TraversalDirection? scrollDirection;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !utils.isSameDay(date, oldWidget.date) ||
        scrollDirection != oldWidget.scrollDirection;
  }

  static _FocusedDate? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
  }
}

class _DayHeaders extends StatelessWidget {
  List<Widget> _getDayHeaders(
      TextStyle headerStyle, MaterialLocalizations localizations) {
    return (NepaliUtils().language == Language.english
            ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            : ['आ', 'सो', 'मं', 'बु', 'वि', 'शु', 'श'])
        .map<Widget>(
          (label) => ExcludeSemantics(
            child: Center(
              child: Text(label, style: headerStyle),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textStyle =
        themeData.textTheme.titleSmall!.apply(color: colorScheme.onSurface);
    final localizations = MaterialLocalizations.of(context);
    final labels = _getDayHeaders(textStyle, localizations);

    labels.insert(0, Container());
    labels.add(Container());

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).orientation == Orientation.landscape
            ? _maxCalendarWidthLandscape
            : _maxCalendarWidthPortrait,
        maxHeight: _monthItemRowHeight,
      ),
      child: GridView.custom(
        shrinkWrap: true,
        gridDelegate: _monthItemGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          labels,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class _MonthItemGridDelegate extends SliverGridDelegate {
  const _MonthItemGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final tileWidth = (constraints.crossAxisExtent - 2 * _horizontalPadding) /
        DateTime.daysPerWeek;
    return _MonthSliverGridLayout(
      crossAxisCount: DateTime.daysPerWeek + 2,
      dayChildWidth: tileWidth,
      edgeChildWidth: _horizontalPadding,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_MonthItemGridDelegate oldDelegate) => false;
}

const _MonthItemGridDelegate _monthItemGridDelegate = _MonthItemGridDelegate();

class _MonthSliverGridLayout extends SliverGridLayout {
  const _MonthSliverGridLayout({
    required this.crossAxisCount,
    required this.dayChildWidth,
    required this.edgeChildWidth,
    required this.reverseCrossAxis,
  })  : assert(crossAxisCount > 0),
        assert(dayChildWidth >= 0),
        assert(edgeChildWidth >= 0);

  final int crossAxisCount;

  final double dayChildWidth;

  final double edgeChildWidth;

  final bool reverseCrossAxis;

  double get _rowHeight {
    return _monthItemRowHeight + _monthItemSpaceBetweenRows;
  }

  double get _childHeight {
    return _monthItemRowHeight;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return crossAxisCount * (scrollOffset ~/ _rowHeight);
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final mainAxisCount = (scrollOffset / _rowHeight).ceil();
    return math.max(0, crossAxisCount * mainAxisCount - 1);
  }

  double _getCrossAxisOffset(double crossAxisStart, bool isPadding) {
    if (reverseCrossAxis) {
      return ((crossAxisCount - 2) * dayChildWidth + 2 * edgeChildWidth) -
          crossAxisStart -
          (isPadding ? edgeChildWidth : dayChildWidth);
    }
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final adjustedIndex = index % crossAxisCount;
    final isEdge = adjustedIndex == 0 || adjustedIndex == crossAxisCount - 1;
    final crossAxisStart = math
        .max(0, (adjustedIndex - 1) * dayChildWidth + edgeChildWidth)
        .toDouble();

    return SliverGridGeometry(
      scrollOffset: (index ~/ crossAxisCount) * _rowHeight,
      crossAxisOffset: _getCrossAxisOffset(crossAxisStart, isEdge),
      mainAxisExtent: _childHeight,
      crossAxisExtent: isEdge ? edgeChildWidth : dayChildWidth,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    assert(childCount >= 0);
    final mainAxisCount = ((childCount - 1) ~/ crossAxisCount) + 1;
    final mainAxisSpacing = _rowHeight - _childHeight;
    return _rowHeight * mainAxisCount - mainAxisSpacing;
  }
}

class _MonthItem extends StatefulWidget {
  _MonthItem({
    required this.selectedDateStart,
    required this.selectedDateEnd,
    required this.currentDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.displayedMonth,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDateStart == null ||
            !selectedDateStart.isBefore(firstDate)),
        assert(selectedDateEnd == null || !selectedDateEnd.isBefore(firstDate)),
        assert(
            selectedDateStart == null || !selectedDateStart.isAfter(lastDate)),
        assert(selectedDateEnd == null || !selectedDateEnd.isAfter(lastDate)),
        assert(selectedDateStart == null ||
            selectedDateEnd == null ||
            !selectedDateStart.isAfter(selectedDateEnd));

  final NepaliDateTime? selectedDateStart;

  final NepaliDateTime? selectedDateEnd;

  final NepaliDateTime currentDate;

  final ValueChanged<NepaliDateTime> onChanged;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final NepaliDateTime displayedMonth;

  @override
  _MonthItemState createState() => _MonthItemState();
}

class _MonthItemState extends State<_MonthItem> {
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final daysInMonth = utils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (index) => FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final focusedDate = _FocusedDate.of(context)?.date;
    if (focusedDate != null &&
        utils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Color _highlightColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
  }

  void _dayFocusChanged(bool focused) {
    if (focused) {
      final focusDirection = _FocusedDate.of(context)?.scrollDirection;
      if (focusDirection != null) {
        var policy = ScrollPositionAlignmentPolicy.explicit;
        switch (focusDirection) {
          case TraversalDirection.up:
          case TraversalDirection.left:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
            break;
          case TraversalDirection.right:
          case TraversalDirection.down:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
            break;
        }
        Scrollable.ensureVisible(
          primaryFocus!.context!,
          duration: _monthScrollDuration,
          alignmentPolicy: policy,
        );
      }
    }
  }

  Widget _buildDayItem(BuildContext context, NepaliDateTime dayToBuild,
      int firstDayOffset, int daysInMonth) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = MaterialLocalizations.of(context);
    final textDirection = Directionality.of(context);
    final day = dayToBuild.day;

    final highlightColor = colorScheme.primary.withValues(alpha: 0.15);

    final isDisabled = dayToBuild.isAfter(widget.lastDate) ||
        dayToBuild.isBefore(widget.firstDate);

    final isRangeSelection =
        widget.selectedDateStart != null && widget.selectedDateEnd != null;
    final isSelectedStart = widget.selectedDateStart != null &&
        dayToBuild
            .toDateTime()
            .isAtSameMomentAs(widget.selectedDateStart!.toDateTime());
    final isSelectedEnd = widget.selectedDateEnd != null &&
        dayToBuild
            .toDateTime()
            .isAtSameMomentAs(widget.selectedDateEnd!.toDateTime());
    final isInRange = isRangeSelection &&
        dayToBuild.isAfter(widget.selectedDateStart!) &&
        dayToBuild.isBefore(widget.selectedDateEnd!);
    final isCurrentDay = utils.isSameDay(widget.currentDate, dayToBuild);

    final englishDate = dayToBuild.toDateTime();

    BoxDecoration decoration;
    TextStyle? nepaliDateStyle;
    TextStyle? englishDateStyle;
    _HighlightPainter? highlightPainter;

    if (isSelectedStart || isSelectedEnd) {
      nepaliDateStyle = textTheme.bodyMedium?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      );
      englishDateStyle = textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimary.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
        fontSize: 10,
      );

      decoration = BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );

      if (isRangeSelection &&
          widget.selectedDateStart != widget.selectedDateEnd) {
        final style = isSelectedStart
            ? _HighlightPainterStyle.highlightTrailing
            : _HighlightPainterStyle.highlightLeading;
        highlightPainter = _HighlightPainter(
          color: highlightColor,
          style: style,
          textDirection: textDirection,
        );
      }
    } else if (isInRange) {
      nepaliDateStyle = textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      );
      englishDateStyle = textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
        fontSize: 10,
      );

      decoration = BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.zero,
      );

      highlightPainter = _HighlightPainter(
        color: highlightColor,
        style: _HighlightPainterStyle.highlightAll,
        textDirection: textDirection,
      );
    } else if (isDisabled) {
      nepaliDateStyle = textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.38),
        fontSize: 15,
      );
      englishDateStyle = textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.3),
        fontSize: 10,
      );

      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      );
    } else if (isCurrentDay) {
      nepaliDateStyle = textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      );
      englishDateStyle = textTheme.labelSmall?.copyWith(
        color: colorScheme.primary.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
        fontSize: 10,
      );

      decoration = BoxDecoration(
        border: Border.all(
          color: colorScheme.primary,
          width: 1.5,
        ),
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      );
    } else {
      nepaliDateStyle = textTheme.bodyMedium?.copyWith(
        fontSize: 15,
      );
      englishDateStyle = textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 10,
      );

      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      );
    }

    final nepaliDateText = NepaliUtils().language == Language.english
        ? '$day'
        : NepaliUnicode.convert('$day');

    var semanticLabel =
        '${NepaliNumberFormat().format(day)}, ${NepaliDateFormat.yMMMMEEEEd().format(dayToBuild)}';
    if (isSelectedStart) {
      semanticLabel =
          localizations.dateRangeStartDateSemanticLabel(semanticLabel);
    } else if (isSelectedEnd) {
      semanticLabel =
          localizations.dateRangeEndDateSemanticLabel(semanticLabel);
    }

    Widget dayWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: decoration,
      child: Center(
        child: Semantics(
          label: semanticLabel,
          selected: isSelectedStart || isSelectedEnd,
          enabled: !isDisabled,
          button: true,
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nepaliDateText,
                  style: nepaliDateStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                Text(
                  '${englishDate.day}',
                  style: englishDateStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (highlightPainter != null) {
      dayWidget = CustomPaint(
        painter: highlightPainter,
        child: dayWidget,
      );
    }

    if (!isDisabled) {
      dayWidget = InkWell(
        focusNode: _dayFocusNodes[day - 1],
        onTap: () => widget.onChanged(dayToBuild),
        borderRadius: BorderRadius.circular(12),
        splashColor: colorScheme.primary.withValues(alpha: 0.3),
        highlightColor: colorScheme.primary.withValues(alpha: 0.15),
        onFocusChange: _dayFocusChanged,
        child: dayWidget,
      );
    }

    return dayWidget;
  }

  Widget _buildEdgeContainer(BuildContext context, bool isHighlighted) {
    return Container(color: isHighlighted ? _highlightColor(context) : null);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    final year = widget.displayedMonth.year;
    final month = widget.displayedMonth.month;
    final daysInMonth = utils.getDaysInMonth(year, month);
    final dayOffset = utils.firstDayOffset(year, month);
    final weeks = ((daysInMonth + dayOffset) / DateTime.daysPerWeek).ceil();
    final gridHeight =
        weeks * _monthItemRowHeight + (weeks - 1) * _monthItemSpaceBetweenRows;
    final dayItems = <Widget>[];

    for (var i = 0; true; i += 1) {
      final day = i - dayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final dayToBuild = NepaliDateTime(year, month, day);
        final dayItem = _buildDayItem(
          context,
          dayToBuild,
          dayOffset,
          daysInMonth,
        );
        dayItems.add(dayItem);
      }
    }

    final paddedDayItems = <Widget>[];
    for (var i = 0; i < weeks; i++) {
      final start = i * DateTime.daysPerWeek;
      final end = math.min(
        start + DateTime.daysPerWeek,
        dayItems.length,
      );
      final weekList = dayItems.sublist(start, end);

      final dateAfterLeadingPadding =
          NepaliDateTime(year, month, start - dayOffset + 1);
      final isLeadingInRange = !(dayOffset > 0 && i == 0) &&
          widget.selectedDateStart != null &&
          widget.selectedDateEnd != null &&
          dateAfterLeadingPadding.isAfter(widget.selectedDateStart!) &&
          !dateAfterLeadingPadding.isAfter(widget.selectedDateEnd!);
      weekList.insert(0, _buildEdgeContainer(context, isLeadingInRange));

      if (end < dayItems.length ||
          (end == dayItems.length &&
              dayItems.length % DateTime.daysPerWeek == 0)) {
        final dateBeforeTrailingPadding =
            NepaliDateTime(year, month, end - dayOffset);
        final isTrailingInRange = widget.selectedDateStart != null &&
            widget.selectedDateEnd != null &&
            !dateBeforeTrailingPadding.isBefore(widget.selectedDateStart!) &&
            dateBeforeTrailingPadding.isBefore(widget.selectedDateEnd!);
        weekList.add(_buildEdgeContainer(context, isTrailingInRange));
      }

      paddedDayItems.addAll(weekList);
    }

    final englishStartDate = widget.displayedMonth.toDateTime();
    final englishEndDate = widget.displayedMonth
        .add(Duration(days: utils.getDaysInMonth(year, month) - 1))
        .toDateTime();

    final englishMonthText = englishStartDate.month == englishEndDate.month
        ? utils.formatMonth(englishStartDate)
        : '${utils.formatMonth(englishStartDate)} - ${utils.formatMonth(englishEndDate)}';

    final maxWidth = MediaQuery.of(context).orientation == Orientation.landscape
        ? _maxCalendarWidthLandscape
        : _maxCalendarWidthPortrait;
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: const Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          constraints: BoxConstraints(maxWidth: maxWidth),
          height: _monthItemHeaderHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: AlignmentDirectional.centerStart,
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NepaliDateFormat.yMMMM().format(widget.displayedMonth),
                  style: textTheme.bodyMedium!.copyWith(
                      color: themeData.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  englishMonthText,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        themeData.colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: gridHeight,
          ),
          child: GridView.custom(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: _monthItemGridDelegate,
            childrenDelegate: SliverChildListDelegate(
              paddedDayItems,
              addRepaintBoundaries: false,
            ),
          ),
        ),
        const SizedBox(height: _monthItemFooterHeight),
      ],
    );
  }
}

enum _HighlightPainterStyle {
  none,

  highlightLeading,

  highlightTrailing,

  highlightAll,
}

class _HighlightPainter extends CustomPainter {
  _HighlightPainter({
    required this.color,
    this.style = _HighlightPainterStyle.none,
    this.textDirection,
  });

  final Color color;
  final _HighlightPainterStyle style;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (style == _HighlightPainterStyle.none) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rectLeft = Rect.fromLTWH(0, 0, size.width / 2, size.height);
    final rectRight =
        Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);

    switch (style) {
      case _HighlightPainterStyle.highlightTrailing:
        canvas.drawRect(
          textDirection == TextDirection.ltr ? rectRight : rectLeft,
          paint,
        );
        break;
      case _HighlightPainterStyle.highlightLeading:
        canvas.drawRect(
          textDirection == TextDirection.ltr ? rectLeft : rectRight,
          paint,
        );
        break;
      case _HighlightPainterStyle.highlightAll:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _InputDateRangePickerDialog extends StatelessWidget {
  const _InputDateRangePickerDialog({
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.currentDate,
    required this.picker,
    required this.onConfirm,
    required this.onCancel,
    required this.onToggleEntryMode,
    required this.confirmText,
    required this.cancelText,
    required this.helpText,
    required this.entryModeButton,
  });

  final NepaliDateTime? selectedStartDate;
  final NepaliDateTime? selectedEndDate;
  final NepaliDateTime? currentDate;
  final Widget picker;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onToggleEntryMode;
  final String? confirmText;
  final String? cancelText;
  final String? helpText;
  final Widget? entryModeButton;

  String _formatDateRange(BuildContext context, NepaliDateTime? start,
      NepaliDateTime? end, NepaliDateTime now) {
    final localizations = MaterialLocalizations.of(context);
    final startText = utils.formatRangeStartDate(localizations, start, end);
    final endText = utils.formatRangeEndDate(localizations, start, end, now);
    if (start == null || end == null) {
      return localizations.unspecifiedDateRange;
    }
    if (Directionality.of(context) == TextDirection.ltr) {
      return '$startText – $endText';
    } else {
      return '$endText – $startText';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final textTheme = theme.textTheme;

    final dateColor = colorScheme.brightness == Brightness.light
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final dateStyle = orientation == Orientation.landscape
        ? textTheme.headlineSmall?.apply(color: dateColor)
        : textTheme.headlineMedium?.apply(color: dateColor);
    final dateText = _formatDateRange(
        context, selectedStartDate, selectedEndDate, currentDate!);
    final semanticDateText = selectedStartDate != null &&
            selectedEndDate != null
        ? '${NepaliDateFormat.yMd().format(selectedStartDate!)} – ${NepaliDateFormat.yMd().format(selectedEndDate!)}'
        : '';

    final Widget header = DatePickerHeader(
      helpText: helpText ?? localizations.dateRangePickerHelpText,
      titleText: dateText,
      titleSemanticsLabel: semanticDateText,
      titleStyle: dateStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    final Widget actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            onPressed: onCancel,
            child: Text(cancelText ?? localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text(confirmText ?? localizations.okButtonLabel),
          ),
        ],
      ),
    );

    switch (orientation) {
      case Orientation.portrait:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            header,
            Expanded(child: picker),
            actions,
          ],
        );

      case Orientation.landscape:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            header,
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: picker),
                  actions,
                ],
              ),
            ),
          ],
        );
    }
  }
}

class InputDateRangePicker extends StatefulWidget {
  InputDateRangePicker({
    super.key,
    NepaliDateTime? initialStartDate,
    NepaliDateTime? initialEndDate,
    required NepaliDateTime firstDate,
    required NepaliDateTime lastDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.helpText,
    this.errorFormatText,
    this.errorInvalidText,
    this.errorInvalidRangeText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
    this.autofocus = false,
    this.autovalidate = false,
  })  : initialStartDate =
            initialStartDate == null ? null : utils.dateOnly(initialStartDate),
        initialEndDate =
            initialEndDate == null ? null : utils.dateOnly(initialEndDate),
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate);

  final NepaliDateTime? initialStartDate;

  final NepaliDateTime? initialEndDate;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final ValueChanged<NepaliDateTime?>? onStartDateChanged;

  final ValueChanged<NepaliDateTime?>? onEndDateChanged;

  final String? helpText;

  final String? errorFormatText;

  final String? errorInvalidText;

  final String? errorInvalidRangeText;

  final String? fieldStartHintText;

  final String? fieldEndHintText;

  final String? fieldStartLabelText;

  final String? fieldEndLabelText;

  final bool autofocus;

  final bool autovalidate;

  @override
  State<InputDateRangePicker> createState() => _InputDateRangePickerState();
}

class _InputDateRangePickerState extends State<InputDateRangePicker> {
  late String _startInputText;
  late String _endInputText;
  NepaliDateTime? _startDate;
  NepaliDateTime? _endDate;
  late TextEditingController _startController;
  late TextEditingController _endController;
  String? _startErrorText;
  String? _endErrorText;
  bool _autoSelected = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _startController = TextEditingController();
    _endDate = widget.initialEndDate;
    _endController = TextEditingController();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_startDate != null) {
      _startInputText =
          NepaliDateFormat.yMd(Language.english).format(_startDate!);
      final selectText = widget.autofocus && !_autoSelected;
      _updateController(_startController, _startInputText, selectText);
      _autoSelected = selectText;
    }

    if (_endDate != null) {
      _endInputText = NepaliDateFormat.yMd(Language.english).format(_endDate!);
      _updateController(_endController, _endInputText, false);
    }
  }

  bool validate() {
    var startError = _validateDate(_startDate);
    final endError = _validateDate(_endDate);
    if (startError == null && endError == null) {
      if (_startDate!.isAfter(_endDate!)) {
        startError = widget.errorInvalidRangeText ??
            MaterialLocalizations.of(context).invalidDateRangeLabel;
      }
    }
    setState(() {
      _startErrorText = startError;
      _endErrorText = endError;
    });
    return startError == null && endError == null;
  }

  NepaliDateTime? _parseDate(String? text) {
    if (text != null &&
        RegExp(r'^2[01]\d{2}/(0[1-9]|1[0-2])/(0[1-9]|1[1-9]|2[1-9]|3[0-2])')
            .hasMatch(text)) {
      return NepaliDateTime.parse(text.replaceAll('/', '-'));
    }
    return null;
  }

  String? _validateDate(NepaliDateTime? date) {
    if (date == null) {
      return widget.errorFormatText ??
          MaterialLocalizations.of(context).invalidDateFormatLabel;
    } else if (date.isBefore(widget.firstDate) ||
        date.isAfter(widget.lastDate)) {
      return widget.errorInvalidText ??
          MaterialLocalizations.of(context).dateOutOfRangeLabel;
    }
    return null;
  }

  void _updateController(
      TextEditingController controller, String text, bool selectText) {
    var textEditingValue = controller.value.copyWith(text: text);
    if (selectText) {
      textEditingValue = textEditingValue.copyWith(
          selection: TextSelection(
        baseOffset: 0,
        extentOffset: text.length,
      ));
    }
    controller.value = textEditingValue;
  }

  void _handleStartChanged(String text) {
    setState(() {
      _startInputText = text;
      _startDate = _parseDate(text);
      widget.onStartDateChanged?.call(_startDate);
    });
    if (widget.autovalidate) {
      validate();
    }
  }

  void _handleEndChanged(String text) {
    setState(() {
      _endInputText = text;
      _endDate = _parseDate(text);
      widget.onEndDateChanged?.call(_endDate);
    });
    if (widget.autovalidate) {
      validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final inputTheme = Theme.of(context).inputDecorationTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _startController,
            decoration: InputDecoration(
              border: inputTheme.border ?? const UnderlineInputBorder(),
              filled: inputTheme.filled,
              hintText: widget.fieldStartHintText ?? localizations.dateHelpText,
              labelText: widget.fieldStartLabelText ??
                  localizations.dateRangeStartLabel,
              errorText: _startErrorText,
            ),
            keyboardType: TextInputType.datetime,
            onChanged: _handleStartChanged,
            autofocus: widget.autofocus,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _endController,
            decoration: InputDecoration(
              border: inputTheme.border ?? const UnderlineInputBorder(),
              filled: inputTheme.filled,
              hintText: widget.fieldEndHintText ?? localizations.dateHelpText,
              labelText:
                  widget.fieldEndLabelText ?? localizations.dateRangeEndLabel,
              errorText: _endErrorText,
            ),
            keyboardType: TextInputType.datetime,
            onChanged: _handleEndChanged,
          ),
        ),
      ],
    );
  }
}
