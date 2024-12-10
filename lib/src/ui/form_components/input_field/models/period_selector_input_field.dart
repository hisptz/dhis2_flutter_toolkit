import '../../../../utils/period_engine/models/period_filter_selection.dart';
import 'base_input_field.dart';

class D2PeriodSelectorInputFieldConfig extends D2BaseInputFieldConfig {
  final bool allowFutureDates;
  final bool allowMultipleSelection;
  final String? selectorTitle;
  final bool showRelative;
  final bool showRange;
  final bool showFixed;
  final D2PeriodSelection? initialSelection;
  final List<String>? excludePeriodTypes;
  final List<String>? onlyAllowPeriodTypes;

  D2PeriodSelectorInputFieldConfig({
    required super.label,
    required super.type,
    required super.name,
    required super.mandatory,
    this.allowFutureDates = false,
    this.allowMultipleSelection = false,
    this.showRelative = true,
    this.showRange = false,
    this.showFixed = false,
    this.initialSelection,
    this.excludePeriodTypes,
    this.onlyAllowPeriodTypes,
    this.selectorTitle,
  });
}
