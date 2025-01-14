import 'package:flutter/material.dart';

import '../form_section/form_section_container.dart';
import '../form_section/models/form_section.dart';
import '../input_field/input_field_container.dart';
import '../input_field/models/base_input_field.dart';
import 'models/form.dart';

typedef OnFormFieldChange<T> = void Function(String key, T);

class FormContainer extends StatelessWidget {
  final D2Form form;
  final Map<String, String?> errorState;
  final Map<String, String?> values;
  final Map<String, bool> mandatoryState;
  final Map<String, bool> hiddenState;
  final Color? color;
  final bool disabled;
  final bool collapsableSections;

  final OnFormFieldChange<String?> onFormFieldChange;

  const FormContainer(
      {super.key,
      required this.form,
      required this.errorState,
      required this.values,
      required this.mandatoryState,
      required this.hiddenState,
      required this.onFormFieldChange,
      this.collapsableSections = false,
      this.disabled = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          form.title != null
              ? Text(
                  form.title!,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                )
              : Container(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          form.subtitle != null
              ? Text(
                  form.subtitle!,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
                )
              : Container(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
          form.sections != null
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    D2FormSection section = form.sections![index];
                    bool collapsed = index != 0;

                    return FormSectionContainer(
                      disabled: disabled,
                      section: section,
                      onFieldChange: onFormFieldChange,
                      collapsed: collapsed,
                      isCollapsable: collapsableSections,
                    );
                  },
                  separatorBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                  itemCount: form.sections!.length)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    D2BaseInputFieldConfig input = form.fields![index];
                    return D2InputFieldContainer(
                      disabled: disabled,
                      color: color,
                      input: input,
                      onChange: (value) => onFormFieldChange(input.name, value),
                    );
                  },
                  separatorBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                  itemCount: form.fields!.length)
        ],
      ),
    );
  }
}
