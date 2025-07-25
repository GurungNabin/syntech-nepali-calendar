import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../syntech_nepali_calendar.dart';
import 'date_picker_common.dart' as common;
import 'date_utils.dart' as utils;

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _dayPickerRowHeight = 42.0;
const int _maxDayPickerRowCount = 5;
const double _maxDayPickerHeight =
    _dayPickerRowHeight * (_maxDayPickerRowCount + 1);

const int _yearPickerColumnCount = 3;
const double _yearPickerPadding = 16.0;
const double _yearPickerRowHeight = 52.0;
const double _yearPickerRowSpacing = 8.0;

const double _subHeaderHeight = 56.0;
const double _monthNavButtonsWidth = 108.0;

/// Show a Nepali date picker in a dialog.
class NepaliCalendarDatePicker extends StatefulWidget {
  /// Return a widget that shows a Nepali date picker.
  /// The [initialDate] is the initially selected date for the picker.
  /// The [firstDate] is the first allowable date in the picker.
  /// The [lastDate] is the last allowable date in the picker.
  /// The [currentDate] is the current date for the picker.
  /// The [onDateChanged] is the callback called when a new date is selected.
  /// The [onDisplayedMonthChanged] is the callback called when the month displayed in the picker changes.
  /// The [initialCalendarMode] is the initial [DatePickerMode] of the picker.
  NepaliCalendarDatePicker({
    super.key,
    required NepaliDateTime initialDate,
    required NepaliDateTime firstDate,
    required NepaliDateTime lastDate,
    NepaliDateTime? currentDate,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
    this.selectedDayDecoration,
    this.todayDecoration,
    this.dayBuilder,
  })  : initialDate = utils.dateOnly(initialDate),
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate),
        currentDate = utils.dateOnly(currentDate ?? NepaliDateTime.now()) {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      !this.initialDate.isBefore(this.firstDate),
      'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      !this.initialDate.isAfter(this.lastDate),
      'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.',
    );
    assert(
      selectableDayPredicate == null ||
          selectableDayPredicate!(this.initialDate),
      'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.',
    );
  }

  /// The initially selected date for the picker.
  final NepaliDateTime initialDate;

  /// The first allowable date in the picker.
  final NepaliDateTime firstDate;

  /// The last allowable date in the picker.
  final NepaliDateTime lastDate;

  /// The current date for the picker.
  final NepaliDateTime currentDate;

  /// The callback called when a new date is selected.
  final ValueChanged<NepaliDateTime> onDateChanged;

  /// The callback called when the month displayed in the picker changes.
  final ValueChanged<NepaliDateTime>? onDisplayedMonthChanged;

  /// The initial [DatePickerMode] of the picker.
  final DatePickerMode initialCalendarMode;

  /// Function to provide full control over the day widget.
  final Widget Function(NepaliDateTime)? dayBuilder;

  /// Decoration for the today day.
  final BoxDecoration? todayDecoration;

  /// Decoration for the selected day.
  final BoxDecoration? selectedDayDecoration;

  /// Function to provide the logic to disable the day.
  final common.SelectableDayPredicate? selectableDayPredicate;

  @override
  State<NepaliCalendarDatePicker> createState() =>
      _NepaliCalendarDatePickerState();
}

class _NepaliCalendarDatePickerState extends State<NepaliCalendarDatePicker> {
  bool _announcedInitialDate = false;
  late DatePickerMode _mode;
  late NepaliDateTime _currentDisplayedMonthDate;
  late NepaliDateTime _selectedDate;
  final GlobalKey _monthPickerKey = GlobalKey();
  final GlobalKey _yearPickerKey = GlobalKey();
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCalendarMode;
    _currentDisplayedMonthDate = NepaliDateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );
    _selectedDate = widget.initialDate;
  }

  @override
  void didUpdateWidget(NepaliCalendarDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCalendarMode != oldWidget.initialCalendarMode) {
      _mode = widget.initialCalendarMode;
    }
    if (!DateUtils.isSameDay(widget.initialDate, oldWidget.initialDate)) {
      _currentDisplayedMonthDate = NepaliDateTime(
        widget.initialDate.year,
        widget.initialDate.month,
      );
      _selectedDate = widget.initialDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    _textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        NepaliDateFormat.yMMMMEEEEd().format(_selectedDate),
        _textDirection,
      );
    }
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_mode == DatePickerMode.day) {
        SemanticsService.announce(
          NepaliDateFormat.yMMMM().format(_selectedDate),
          _textDirection,
        );
      } else {
        SemanticsService.announce(
          NepaliDateFormat.y().format(_selectedDate),
          _textDirection,
        );
      }
    });
  }

  void _handleMonthChanged(NepaliDateTime date) {
    setState(() {
      if (_currentDisplayedMonthDate.year != date.year ||
          _currentDisplayedMonthDate.month != date.month) {
        _currentDisplayedMonthDate = NepaliDateTime(date.year, date.month);
        widget.onDisplayedMonthChanged?.call(_currentDisplayedMonthDate);
      }
    });
  }

  void _handleYearChanged(NepaliDateTime value) {
    _vibrate();

    if (value.isBefore(widget.firstDate)) {
      value = widget.firstDate;
    } else if (value.isAfter(widget.lastDate)) {
      value = widget.lastDate;
    }

    setState(() {
      _mode = DatePickerMode.day;
      _handleMonthChanged(value);
    });
  }

  void _handleDayChanged(NepaliDateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
      widget.onDateChanged(_selectedDate);
    });
  }

  Widget _buildPicker() {
    switch (_mode) {
      case DatePickerMode.day:
        return _MonthPicker(
          key: _monthPickerKey,
          initialMonth: _currentDisplayedMonthDate,
          currentDate: widget.currentDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectedDate: _selectedDate,
          onChanged: _handleDayChanged,
          onDisplayedMonthChanged: _handleMonthChanged,
          selectableDayPredicate: widget.selectableDayPredicate,
          todayDecoration: widget.todayDecoration,
          selectedDayDecoration: widget.selectedDayDecoration,
          dayBuilder: widget.dayBuilder,
        );
      case DatePickerMode.year:
        return Padding(
          padding: const EdgeInsets.only(top: _subHeaderHeight),
          child: _YearPicker(
            key: _yearPickerKey,
            currentDate: widget.currentDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialDate: _currentDisplayedMonthDate,
            selectedDate: _selectedDate,
            onChanged: _handleYearChanged,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: _subHeaderHeight + _maxDayPickerHeight,
          child: _buildPicker(),
        ),
        _DatePickerModeToggleButton(
          mode: _mode,
          title: NepaliDateFormat.yMMMM().format(_currentDisplayedMonthDate),
          onTitlePressed: () {
            _handleModeChanged(
              _mode == DatePickerMode.day
                  ? DatePickerMode.year
                  : DatePickerMode.day,
            );
          },
          currentDisplayedMonthDate: _currentDisplayedMonthDate,
        ),
      ],
    );
  }
}

class _DatePickerModeToggleButton extends StatefulWidget {
  const _DatePickerModeToggleButton({
    required this.mode,
    required this.title,
    required this.onTitlePressed,
    required this.currentDisplayedMonthDate,
  });

  final DatePickerMode mode;
  final String title;

  final VoidCallback onTitlePressed;

  final NepaliDateTime currentDisplayedMonthDate;

  @override
  _DatePickerModeToggleButtonState createState() =>
      _DatePickerModeToggleButtonState();
}

class _DatePickerModeToggleButtonState
    extends State<_DatePickerModeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.mode == DatePickerMode.year ? 0.5 : 0,
      upperBound: 0.5,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_DatePickerModeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode == widget.mode) {
      return;
    }

    if (widget.mode == DatePickerMode.year) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  String getEnglishMonthRange(NepaliDateTime nepaliDate) {
    final startEnglishDate = nepaliDate.toDateTime();
    final endEnglishDate =
        nepaliDate.add(const Duration(days: 30)).toDateTime();

    final startMonth = utils.formatMonth(startEnglishDate);
    final endMonth = utils.formatMonth(endEnglishDate);

    if (startMonth == endMonth) {
      return startMonth;
    }

    return '$startMonth - $endMonth';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controlColor = colorScheme.primary;

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      height: _subHeaderHeight,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Semantics(
              label: 'Select year',
              excludeSemantics: true,
              button: true,
              child: SizedBox(
                height: _subHeaderHeight,
                child: InkWell(
                  onTap: widget.onTitlePressed,
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  widget.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: controlColor,
                                  ),
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -4),
                                child: Text(
                                  getEnglishMonthRange(
                                    widget.currentDisplayedMonthDate,
                                  ),
                                  style: textTheme.titleSmall?.copyWith(
                                    // color: controlColor.withOpacity(0.7),
                                    color: controlColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        RotationTransition(
                          turns: _controller,
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: controlColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.mode == DatePickerMode.day)
            const SizedBox(width: _monthNavButtonsWidth),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MonthPicker extends StatefulWidget {
  _MonthPicker({
    super.key,
    required this.initialMonth,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    required this.onDisplayedMonthChanged,
    this.selectedDayDecoration,
    this.todayDecoration,
    this.dayBuilder,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate));

  final NepaliDateTime initialMonth;

  final NepaliDateTime currentDate;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final NepaliDateTime selectedDate;

  final ValueChanged<NepaliDateTime> onChanged;

  final ValueChanged<NepaliDateTime> onDisplayedMonthChanged;

  final Widget Function(NepaliDateTime)? dayBuilder;

  final BoxDecoration? todayDecoration;

  final BoxDecoration? selectedDayDecoration;

  final common.SelectableDayPredicate? selectableDayPredicate;

  @override
  State<StatefulWidget> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  final GlobalKey _pageViewKey = GlobalKey();
  late NepaliDateTime _currentMonth;
  late NepaliDateTime _nextMonthDate;
  late NepaliDateTime _previousMonthDate;
  late PageController _pageController;
  late TextDirection _textDirection;
  Map<LogicalKeySet, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  late FocusNode _dayGridFocus;
  NepaliDateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth;
    _previousMonthDate = utils.addMonthsToMonthDate(_currentMonth, -1);
    _nextMonthDate = utils.addMonthsToMonthDate(_currentMonth, 1);
    _pageController = PageController(
      initialPage: utils.monthDelta(widget.firstDate, _currentMonth),
    );
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(
        TraversalDirection.left,
      ),
      LogicalKeySet(
        LogicalKeyboardKey.arrowRight,
      ): const DirectionalFocusIntent(TraversalDirection.right),
      LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(
        TraversalDirection.down,
      ),
      LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(
        TraversalDirection.up,
      ),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent: CallbackAction<NextFocusIntent>(
        onInvoke: _handleGridNextFocus,
      ),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
        onInvoke: _handleGridPreviousFocus,
      ),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
        onInvoke: _handleDirectionFocus,
      ),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
  }

  @override
  void didUpdateWidget(_MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMonth != oldWidget.initialMonth) {
      WidgetsBinding.instance.addPostFrameCallback(
        (Duration timeStamp) => _showMonth(widget.initialMonth, jump: true),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleDateSelected(NepaliDateTime selectedDate) {
    _focusedDay = selectedDate;
    widget.onChanged(selectedDate);
  }

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      final monthDate = utils.addMonthsToMonthDate(widget.firstDate, monthPage);
      if (!utils.isSameMonth(_currentMonth, monthDate)) {
        _currentMonth = NepaliDateTime(monthDate.year, monthDate.month);
        _previousMonthDate = utils.addMonthsToMonthDate(_currentMonth, -1);
        _nextMonthDate = utils.addMonthsToMonthDate(_currentMonth, 1);
        widget.onDisplayedMonthChanged(_currentMonth);
        if (_focusedDay != null &&
            !utils.isSameMonth(_focusedDay!, _currentMonth)) {
          _focusedDay = _focusableDayForMonth(_currentMonth, _focusedDay!.day);
        }
      }
    });
  }

  NepaliDateTime? _focusableDayForMonth(
    NepaliDateTime month,
    int preferredDay,
  ) {
    final daysInMonth = utils.getDaysInMonth(month.year, month.month);

    if (preferredDay <= daysInMonth) {
      final newFocus = NepaliDateTime(month.year, month.month, preferredDay);
      if (_isSelectable(newFocus)) return newFocus;
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final newFocus = NepaliDateTime(month.year, month.month, day);
      if (_isSelectable(newFocus)) return newFocus;
    }
    return null;
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
        NepaliDateFormat.yMMMM().format(_nextMonthDate),
        _textDirection,
      );
      _pageController.nextPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
        NepaliDateFormat.yMMMM().format(_previousMonthDate),
        _textDirection,
      );
      _pageController.previousPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  void _showMonth(NepaliDateTime month, {bool jump = false}) {
    final monthPage = utils.monthDelta(widget.firstDate, month);
    if (jump) {
      _pageController.jumpToPage(monthPage);
    } else {
      _pageController.animateToPage(
        monthPage,
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  bool get _isDisplayingFirstMonth {
    return !_currentMonth.isAfter(
      NepaliDateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  bool get _isDisplayingLastMonth {
    return !_currentMonth.isBefore(
      NepaliDateTime(widget.lastDate.year, widget.lastDate.month),
    );
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused && _focusedDay == null) {
        if (utils.isSameMonth(widget.selectedDate, _currentMonth)) {
          _focusedDay = widget.selectedDate;
        } else if (utils.isSameMonth(widget.currentDate, _currentMonth)) {
          _focusedDay = _focusableDayForMonth(
            _currentMonth,
            widget.currentDate.day,
          );
        } else {
          _focusedDay = _focusableDayForMonth(_currentMonth, 1);
        }
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
        if (!utils.isSameMonth(_focusedDay!, _currentMonth)) {
          _showMonth(_focusedDay!);
        }
      }
    });
  }

  static const Map<TraversalDirection, Duration> _directionOffset =
      <TraversalDirection, Duration>{
    TraversalDirection.up: Duration(days: -DateTime.daysPerWeek),
    TraversalDirection.right: Duration(days: 1),
    TraversalDirection.down: Duration(days: DateTime.daysPerWeek),
    TraversalDirection.left: Duration(days: -1),
  };

  Duration _dayDirectionOffset(
    TraversalDirection traversalDirection,
    TextDirection textDirection,
  ) {
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
    NepaliDateTime date,
    TraversalDirection direction,
  ) {
    final textDirection = Directionality.of(context);
    var nextDate = date.add(_dayDirectionOffset(direction, textDirection));
    while (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      if (_isSelectable(nextDate)) {
        return nextDate;
      }
      nextDate = nextDate.add(_dayDirectionOffset(direction, textDirection));
    }
    return null;
  }

  bool _isSelectable(NepaliDateTime date) {
    return widget.selectableDayPredicate == null ||
        widget.selectableDayPredicate!.call(date);
  }

  Widget _buildItems(BuildContext context, int index) {
    final month = utils.addMonthsToMonthDate(widget.firstDate, index);
    return _DayPicker(
      key: ValueKey<NepaliDateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: widget.currentDate,
      onChanged: _handleDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
      dayBuilder: widget.dayBuilder,
      selectedDayDecoration: widget.selectedDayDecoration,
      todayDecoration: widget.todayDecoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final previousTooltipText =
        '${NepaliUtils().language == Language.english ? 'Previous Month' : 'अघिल्लो महिना'} ${NepaliDateFormat.yMMMM().format(_previousMonthDate)}';
    final nextTooltipText =
        '${NepaliUtils().language == Language.english ? 'Next Month' : 'अर्को महिना'} ${NepaliDateFormat.yMMMM().format(_nextMonthDate)}';
    final controlColor = Theme.of(context).colorScheme.primary;

    return Semantics(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            height: _subHeaderHeight,
            child: Row(
              children: <Widget>[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: controlColor,
                  tooltip: _isDisplayingFirstMonth ? null : previousTooltipText,
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: controlColor,
                  tooltip: _isDisplayingLastMonth ? null : nextTooltipText,
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: FocusableActionDetector(
              shortcuts: _shortcutMap,
              actions: _actionMap,
              focusNode: _dayGridFocus,
              onFocusChange: _handleGridFocusChange,
              child: _FocusedDate(
                date: _dayGridFocus.hasFocus ? _focusedDay : null,
                child: Container(
                  color: _dayGridFocus.hasFocus
                      ? Theme.of(context).focusColor
                      : null,
                  child: PageView.builder(
                    key: _pageViewKey,
                    controller: _pageController,
                    itemBuilder: _buildItems,
                    itemCount:
                        utils.monthDelta(widget.firstDate, widget.lastDate) + 1,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: _handleMonthPageChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusedDate extends InheritedWidget {
  const _FocusedDate({required super.child, this.date});

  final NepaliDateTime? date;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !DateUtils.isSameDay(date, oldWidget.date);
  }

  static NepaliDateTime? of(BuildContext context) {
    final focusedDate =
        context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
    return focusedDate?.date;
  }
}

class _DayPicker extends StatefulWidget {
  _DayPicker({
    super.key,
    required this.currentDate,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    this.todayDecoration,
    this.selectedDayDecoration,
    this.dayBuilder,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate));

  final NepaliDateTime selectedDate;

  final NepaliDateTime currentDate;

  final ValueChanged<NepaliDateTime> onChanged;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final NepaliDateTime displayedMonth;

  final Widget Function(NepaliDateTime)? dayBuilder;

  final BoxDecoration? todayDecoration;

  final BoxDecoration? selectedDayDecoration;

  final common.SelectableDayPredicate? selectableDayPredicate;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final daysInMonth = utils.getDaysInMonth(
      widget.displayedMonth.year,
      widget.displayedMonth.month,
    );
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (index) => FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final focusedDate = _FocusedDate.of(context);
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

  List<Widget> _dayHeaders(TextStyle? headerStyle) {
    return (NepaliUtils().language == Language.english
            ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            : ['आ', 'सो', 'मं', 'बु', 'वि', 'शु', 'श'])
        .map<Widget>(
          (label) => ExcludeSemantics(
            child: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    width: 0.1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Center(child: Text(label, style: headerStyle)),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final headerStyle = textTheme.titleSmall?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.87),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    final enabledDayColor = colorScheme.onSurface.withValues(alpha: 0.87);
    final disabledDayColor = colorScheme.onSurface.withValues(alpha: 0.38);
    final selectedDayColor = colorScheme.onPrimary;
    final selectedDayBackground = colorScheme.primary;
    final todayColor = colorScheme.primary;
    final weekendColor = Colors.red.shade400;
    final borderColor = colorScheme.outline.withValues(alpha: 0.2);

    final year = widget.displayedMonth.year;
    final month = widget.displayedMonth.month;

    final daysInMonth = utils.getDaysInMonth(year, month);
    final dayOffset = utils.firstDayOffset(year, month);

    final dayItems = _dayHeaders(headerStyle);
    var day = -dayOffset;

    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 0.5),
              color: colorScheme.surface,
            ),
          ),
        );
      } else {
        final dayToBuild = NepaliDateTime(year, month, day);
        final isDisabled = dayToBuild.isAfter(widget.lastDate) ||
            dayToBuild.isBefore(widget.firstDate) ||
            (widget.selectableDayPredicate != null &&
                !widget.selectableDayPredicate!(dayToBuild));
        final isSelectedDay = utils.isSameDay(widget.selectedDate, dayToBuild);
        final isToday = utils.isSameDay(widget.currentDate, dayToBuild);

        final englishDate = dayToBuild.toDateTime().day;

        final isSaturday = dayToBuild.weekday == 7;

        BoxDecoration decoration = BoxDecoration(
          border: Border.all(color: borderColor, width: 0.4),
          borderRadius: BorderRadius.circular(2),
        );

        var dayColor = enabledDayColor;

        if (isSelectedDay) {
          dayColor = selectedDayColor;
          decoration = widget.selectedDayDecoration ??
              BoxDecoration(
                color: selectedDayBackground,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: selectedDayBackground.withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              );
        } else if (isDisabled) {
          dayColor = disabledDayColor;
        } else if (isToday) {
          dayColor = isSaturday ? weekendColor : todayColor;
          decoration = widget.todayDecoration ??
              BoxDecoration(
                color: todayColor.withValues(alpha: 0.1),
                border: Border.all(color: todayColor, width: 1),
                borderRadius: BorderRadius.circular(4),
              );
        } else if (isSaturday) {
          dayColor = weekendColor;
        }

        Widget dayWidget = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: decoration,
          child: widget.dayBuilder == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            NepaliNumberFormat().format(day),
                            style: textTheme.bodyMedium?.copyWith(
                              color: isSaturday ? weekendColor : dayColor,
                              fontWeight: isSelectedDay || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 4.0,
                            bottom: 2.0,
                          ),
                          child: Text(
                            "$englishDate",
                            style: textTheme.labelSmall?.copyWith(
                              color: isSaturday
                                  ? weekendColor
                                  : isSelectedDay
                                      ? dayColor
                                      : dayColor.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : widget.dayBuilder!(dayToBuild),
        );

        if (isDisabled) {
          dayWidget = ExcludeSemantics(child: dayWidget);
        } else {
          dayWidget = InkWell(
            focusNode: _dayFocusNodes[day - 1],
            onTap: () => widget.onChanged(dayToBuild),
            splashColor: selectedDayBackground.withValues(alpha: 0.4),
            highlightColor: selectedDayBackground.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            child: Semantics(
              label:
                  '${NepaliNumberFormat().format(day)}, ${NepaliDateFormat.yMMMMEEEEd().format(dayToBuild)}',
              selected: isSelectedDay,
              excludeSemantics: true,
              child: dayWidget,
            ),
          );
        }

        dayItems.add(dayWidget);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.custom(
        padding: const EdgeInsets.all(1),
        physics: const ClampingScrollPhysics(),
        gridDelegate: _dayPickerGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          dayItems,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const columnCount = DateTime.daysPerWeek;
    final tileWidth = constraints.crossAxisExtent / columnCount;
    final tileHeight = math.min(
      _dayPickerRowHeight,
      constraints.viewportMainAxisExtent / (_maxDayPickerRowCount + 1),
    );
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _dayPickerGridDelegate = _DayPickerGridDelegate();

class _YearPicker extends StatefulWidget {
  _YearPicker({
    super.key,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    required this.selectedDate,
    required this.onChanged,
  }) : assert(!firstDate.isAfter(lastDate));

  final NepaliDateTime currentDate;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final NepaliDateTime initialDate;

  final NepaliDateTime selectedDate;

  final ValueChanged<NepaliDateTime> onChanged;

  @override
  _YearPickerState createState() => _YearPickerState();
}

class _YearPickerState extends State<_YearPicker> {
  late ScrollController scrollController;

  static const int minYears = 18;

  @override
  void initState() {
    super.initState();

    final initialYearIndex = widget.selectedDate.year - widget.firstDate.year;
    final initialYearRow = initialYearIndex ~/ _yearPickerColumnCount;
    final centeredYearRow = initialYearRow - 2;
    final scrollOffset =
        _itemCount < minYears ? 0.0 : centeredYearRow * _yearPickerRowHeight;
    scrollController = ScrollController(initialScrollOffset: scrollOffset);
  }

  Widget _buildYearItem(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final offset = _itemCount < minYears ? (minYears - _itemCount) ~/ 2 : 0;
    final year = widget.firstDate.year + index - offset;
    final isSelected = year == widget.selectedDate.year;
    final isCurrentYear = year == widget.currentDate.year;
    final isDisabled =
        year < widget.firstDate.year || year > widget.lastDate.year;
    const decorationHeight = 36.0;
    const decorationWidth = 72.0;

    Color textColor;
    if (isSelected) {
      textColor = colorScheme.onPrimary;
    } else if (isDisabled) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.38);
    } else if (isCurrentYear) {
      textColor = colorScheme.primary;
    } else {
      textColor = colorScheme.onSurface.withValues(alpha: 0.87);
    }
    final itemStyle = textTheme.bodyLarge?.apply(color: textColor);

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(decorationHeight / 2),
        shape: BoxShape.rectangle,
      );
    } else if (isCurrentYear && !isDisabled) {
      decoration = BoxDecoration(
        border: Border.all(color: colorScheme.primary, width: 1),
        borderRadius: BorderRadius.circular(decorationHeight / 2),
        shape: BoxShape.rectangle,
      );
    }

    Widget yearItem = Center(
      child: Container(
        decoration: decoration,
        height: decorationHeight,
        width: decorationWidth,
        child: Center(
          child: Semantics(
            selected: isSelected,
            child: Text(
              NepaliUtils().language == Language.english
                  ? year.toString()
                  : NepaliUnicode.convert(year.toString()),
              style: itemStyle,
            ),
          ),
        ),
      ),
    );

    if (isDisabled) {
      yearItem = ExcludeSemantics(child: yearItem);
    } else {
      yearItem = InkWell(
        key: ValueKey<int>(year),
        onTap: () {
          widget.onChanged(
            NepaliDateTime(
              year,
              widget.initialDate.month,
              widget.initialDate.day,
            ),
          );
        },
        child: yearItem,
      );
    }

    return yearItem;
  }

  int get _itemCount {
    return widget.lastDate.year - widget.firstDate.year + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            gridDelegate: _yearPickerGridDelegate,
            itemBuilder: _buildYearItem,
            itemCount: math.max(_itemCount, minYears),
            padding: const EdgeInsets.symmetric(horizontal: _yearPickerPadding),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _YearPickerGridDelegate extends SliverGridDelegate {
  const _YearPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final tileWidth = (constraints.crossAxisExtent -
            (_yearPickerColumnCount - 1) * _yearPickerRowSpacing) /
        _yearPickerColumnCount;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: _yearPickerRowHeight,
      crossAxisCount: _yearPickerColumnCount,
      crossAxisStride: tileWidth + _yearPickerRowSpacing,
      mainAxisStride: _yearPickerRowHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_YearPickerGridDelegate oldDelegate) => false;
}

const _YearPickerGridDelegate _yearPickerGridDelegate =
    _YearPickerGridDelegate();
