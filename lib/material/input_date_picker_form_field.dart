import 'package:flutter/material.dart';

import '../syntech_nepali_calendar.dart';
import 'date_picker_common.dart' as common;
import 'date_utils.dart' as utils;

class InputDatePickerFormField extends StatefulWidget {
  InputDatePickerFormField({
    super.key,
    NepaliDateTime? initialDate,
    required NepaliDateTime firstDate,
    required NepaliDateTime lastDate,
    this.onDateSubmitted,
    this.onDateSaved,
    this.selectableDayPredicate,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.autofocus = false,
  })  : initialDate = initialDate != null ? utils.dateOnly(initialDate) : null,
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate) {
    assert(!this.lastDate.isBefore(this.firstDate),
        'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.');
    assert(initialDate == null || !this.initialDate!.isBefore(this.firstDate),
        'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.');
    assert(initialDate == null || !this.initialDate!.isAfter(this.lastDate),
        'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.');
    assert(
        selectableDayPredicate == null ||
            initialDate == null ||
            selectableDayPredicate!(this.initialDate!),
        'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.');
  }

  final NepaliDateTime? initialDate;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final ValueChanged<NepaliDateTime>? onDateSubmitted;

  final ValueChanged<NepaliDateTime>? onDateSaved;

  final common.SelectableDayPredicate? selectableDayPredicate;

  final String? errorFormatText;

  final String? errorInvalidText;

  final String? fieldHintText;

  final String? fieldLabelText;

  final bool autofocus;

  @override
  State<InputDatePickerFormField> createState() =>
      _InputDatePickerFormFieldState();
}

class _InputDatePickerFormFieldState extends State<InputDatePickerFormField> {
  final TextEditingController _controller = TextEditingController();
  NepaliDateTime? _selectedDate;
  String? _inputText;
  bool _autoSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateValueForSelectedDate();
  }

  @override
  void didUpdateWidget(InputDatePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        setState(() {
          _selectedDate = widget.initialDate;
          _updateValueForSelectedDate();
        });
      });
    }
  }

  void _updateValueForSelectedDate() {
    if (_selectedDate != null) {
      _inputText =
          NepaliDateFormat.yMd(Language.english).format(_selectedDate!);
      var textEditingValue = _controller.value.copyWith(text: _inputText);
      if (widget.autofocus && !_autoSelected) {
        textEditingValue = textEditingValue.copyWith(
            selection: TextSelection(
          baseOffset: 0,
          extentOffset: _inputText!.length,
        ));
        _autoSelected = true;
      }
      _controller.value = textEditingValue;
    } else {
      _inputText = '';
      _controller.value = _controller.value.copyWith(text: _inputText);
    }
  }

  NepaliDateTime? _parseDate(String? text) {
    if (text != null &&
        RegExp(r'^2[01]\d{2}/(0[1-9]|1[0-2])/(0[1-9]|1[0-9]|2[0-9]|3[0-2])')
            .hasMatch(text)) {
      return NepaliDateTime.parse(text.replaceAll('/', '-'));
    }
    return null;
  }

  bool _isValidAcceptableDate(NepaliDateTime? date) {
    return date != null &&
        !date.isBefore(widget.firstDate) &&
        !date.isAfter(widget.lastDate) &&
        (widget.selectableDayPredicate == null ||
            widget.selectableDayPredicate!(date));
  }

  bool _isDayInMonth(NepaliDateTime? date) {
    return date != null && date.day <= date.totalDays;
  }

  String? _validateDate(String? text) {
    final date = _parseDate(text);
    if (date == null) {
      return widget.errorFormatText ??
          MaterialLocalizations.of(context).invalidDateFormatLabel;
    } else if (!_isValidAcceptableDate(date)) {
      return widget.errorInvalidText ??
          MaterialLocalizations.of(context).dateOutOfRangeLabel;
    } else if (!_isDayInMonth(date)) {
      return 'Invalid Day.';
    }
    return null;
  }

  void _updateDate(String? text, ValueChanged<NepaliDateTime>? callback) {
    final date = _parseDate(text);
    if (_isValidAcceptableDate(date)) {
      _selectedDate = date;
      _inputText = text;
      callback?.call(_selectedDate!);
    }
  }

  void _handleSaved(String? text) {
    _updateDate(text, widget.onDateSaved);
  }

  void _handleSubmitted(String? text) {
    _updateDate(text, widget.onDateSubmitted);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final inputTheme = Theme.of(context).inputDecorationTheme;
    return TextFormField(
      decoration: InputDecoration(
        border: inputTheme.border ?? const UnderlineInputBorder(),
        filled: inputTheme.filled,
        hintText: widget.fieldHintText ?? 'yyyy/mm/dd',
        labelText: widget.fieldLabelText ?? localizations.dateInputLabel,
      ),
      validator: _validateDate,
      keyboardType: TextInputType.datetime,
      onSaved: _handleSaved,
      onFieldSubmitted: _handleSubmitted,
      autofocus: widget.autofocus,
      controller: _controller,
    );
  }
}
