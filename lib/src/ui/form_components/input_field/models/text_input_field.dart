import 'base_input_field.dart';

class D2TextInputFieldConfig extends D2BaseInputFieldConfig {
  String? renderType;

  D2TextInputFieldConfig(
      {required super.label,
      required super.type,
      required super.name,
      required super.mandatory,
      super.fieldMask,
      super.clearable,
      super.isCalendar,
      super.icon,
      super.legends,
      super.svgIconAsset,
      this.renderType});
}
