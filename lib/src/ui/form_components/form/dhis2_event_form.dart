import 'package:dhis2_flutter_toolkit/dhis2_flutter_toolkit.dart';
import 'package:dhis2_flutter_toolkit/src/ui/form_components/utils/tracker_event_form_util.dart';
import 'package:flutter/material.dart';

class D2TrackerEventForm extends StatelessWidget {
  final D2FormController controller;
  final D2ProgramStage programStage;
  final D2TrackerFormOptions options;
  final Color? color;

  const D2TrackerEventForm(
      {super.key,
      required this.controller,
      required this.programStage,
      required this.options,
      this.color});

  @override
  Widget build(BuildContext context) {
    List<FormSection> formSections =
        TrackerEventFormUtil(programStage: programStage).formSections;

    Color formColor = color ?? Theme.of(context).primaryColor;

    return D2ControlledForm(
        form: D2Form(
            color: formColor,
            title: options.showTitle
                ? programStage.displayName ?? programStage.name
                : null,
            sections: [...options.formSections, ...formSections]),
        controller: controller);
  }
}