import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';

import '../models/date_range_input_field.dart';
import 'base_input.dart';
import 'input_field_icon.dart';

class DateRangeInput
    extends BaseStatelessInput<D2DateRangeInputFieldConfig, DateTimeRange> {
  DateRangeInput(
      {super.key,
      super.disabled,
      required super.input,
      required super.onChange,
      required super.color,
      super.value,
      required super.decoration});

  void onOpenDateSelection(context) async {
    DateTimeRange? selectedDateTime = await showDateRangePicker(
        initialDateRange: value,
        context: context,
        firstDate: DateTime.parse('1900-01-01 00:00:00Z'),
        lastDate: input.allowFutureDates
            ? DateTime.now().addYears(10)
            : DateTime.now());
    onChange(selectedDateTime);
  }

  late final TextEditingController controller;
  final BoxConstraints iconConstraints = const BoxConstraints(
      maxHeight: 45, minHeight: 42, maxWidth: 45, minWidth: 42);

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController(
        text: value != null
            ? '${value!.start.format("dd/MM/yyyy")} - ${value!.end.format("dd/MM/yyyy")}'
            : null);
    return TextFormField(
        enabled: !disabled,
        showCursor: false,
        controller: controller,
        keyboardType: TextInputType.none,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: IconButton(
              color: color,
              padding: EdgeInsets.zero,
              constraints: iconConstraints,
              onPressed: disabled
                  ? null
                  : () {
                      onOpenDateSelection(context);
                    },
              icon: InputFieldIcon(
                  backgroundColor: color,
                  iconColor: color,
                  iconData: Icons.date_range_sharp),
            )),
        onTap: disabled
            ? null
            : () {
                onOpenDateSelection(context);
              });
  }
}
