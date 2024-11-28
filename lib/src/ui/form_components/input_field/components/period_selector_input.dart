import 'package:flutter/material.dart';

import '../../../../utils/period_engine/models/period_filter_selection.dart';
import '../../../../utils/period_engine/models/period_type.dart';
import '../../../app_modals/utils/d2_app_modal_util.dart';
import '../../../period/period_filter.dart';
import '../models/period_selector_input_field.dart';
import 'base_input.dart';
import 'input_field_icon.dart';

class PeriodSelectorInput
    extends BaseStatelessInput<D2PeriodSelectorInputFieldConfig, List<String>> {
  PeriodSelectorInput({
    super.key,
    super.disabled,
    required super.input,
    required super.onChange,
    required super.color,
    super.value,
    required super.decoration,
  });

  final int maxLines = 1;

  void onOpenPeriodSelector(BuildContext context) {
    D2AppModalUtil.showActionSheetModal(context,
        title: input.selectorTitle ?? input.label,
        initialHeightRatio: 0.7,
        titleColor: color,
        actionSheetContainer: D2PeriodSelector(
          onUpdate: (D2PeriodSelection selection) {
            onChange(selection.selected ?? []);
            Navigator.of(context).pop();
          },
          color: color,
          onlyAllowPeriodTypes: input.onlyAllowPeriodTypes,
          excludePeriodTypes: input.excludePeriodTypes,
        ));
  }

  late final TextEditingController controller;

  String? getNames() {
    return (value ?? []).map((String periodId) {
      return D2PeriodType.getPeriodById(periodId).name;
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          controller: TextEditingController(text: getNames()),
          cursorColor: color,
          enabled: !disabled,
          showCursor: false,
          autofocus: false,
          onTap: disabled
              ? null
              : () {
                  onOpenPeriodSelector(context);
                },
          maxLines: maxLines,
          keyboardType: TextInputType.none,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              color: color,
              padding: EdgeInsets.zero,
              constraints: iconConstraints,
              onPressed: disabled
                  ? null
                  : () {
                      onOpenPeriodSelector(context);
                    },
              icon: InputFieldIcon(
                backgroundColor: color,
                iconColor: color,
                iconData: Icons.calendar_month,
              ),
            )
          ],
        )
      ],
    );
  }
}
