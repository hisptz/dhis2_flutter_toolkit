import 'package:collection/collection.dart';
import 'package:dhis2_flutter_toolkit/dhis2_flutter_toolkit.dart';
import 'package:dhis2_flutter_toolkit/src/ui/form_components/state/tracker/program_rule_engine_state.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/metadata/program_rule.dart';
import '../field_state.dart';

class D2TrackerEnrollmentFormController extends D2FormController
    with ProgramRuleEngineState {
  D2Program program;
  D2ObjectBox db;
  D2Enrollment? enrollment;
  D2TrackedEntity? trackedEntity;
  String orgUnit;
  List<D2ReservedValue> reservedValues = [];
  late D2ProgramRuleEngine programRuleEngine;

  bool get editMode {
    return trackedEntity != null;
  }

  D2TrackerEnrollmentFormController({
    required this.db,
    required this.program,
    required this.orgUnit,
    this.trackedEntity,
    this.enrollment,
    super.mandatoryFields,
    super.hiddenFields,
    super.hiddenSections,
  }) {
    if (trackedEntity != null) {
      List<D2TrackedEntityAttributeValue> attributes =
          trackedEntity!.getAttributesByProgram(program);
      Map<String, dynamic> formValues = {};

      for (D2TrackedEntityAttributeValue element in attributes) {
        formValues.addAll(element.toFormValues());
      }
      //Get the enrollment from here
      if (enrollment == null) {
        D2Enrollment? derivedEnrollment = trackedEntity!.enrollments
            .firstWhereOrNull((element) =>
                element.program.targetId == program.id &&
                element.status == "ACTIVE");

        enrollment = derivedEnrollment;
        if (kDebugMode) {
          print(
              "The selected tracked entity does not have an active enrollment in this program. A new enrollment will be created instead");
        }
      } else {
        Map<String, dynamic> enrollmentFormValues = enrollment!.toFormValues();
        formValues.addAll(enrollmentFormValues);
      }
      setValues(formValues);
    }
    getMandatoryFields();
    initializeProgramRuleEngine(program, trackedEntity);
    disableAutoGeneratedFields();
    if (!editMode) {
      getAutoGeneratedValues();
    }
  }

  void initializeProgramRuleEngine(
    D2Program program,
    D2TrackedEntity? trackedEntity,
  ) {
    List<D2ProgramRule> programRules = program.programRules;
    List<D2ProgramRuleVariable> programRuleVariables =
        program.programRuleVariables;
    programRuleEngine = D2ProgramRuleEngine(
      programRules: programRules,
      programRuleVariables: programRuleVariables,
      trackedEntity: trackedEntity,
    );
    for (var section in program.programSections) {
      for (var attribute in section.programSectionTrackedEntityAttributes) {
        spawnProgramRuleEngine(
          programRuleEngine,
          attribute.trackedEntityAttribute.target?.uid ?? "",
        );
      }
    }
  }

  disableAutoGeneratedFields() {
    List<D2ProgramTrackedEntityAttribute> autogeneratedAttributes = program
        .programTrackedEntityAttributes
        .where((D2ProgramTrackedEntityAttribute pAttribute) =>
            pAttribute.trackedEntityAttribute.target!.generated ?? false)
        .toList();
    List<String> fieldsToDisable = autogeneratedAttributes
        .map((e) => e.trackedEntityAttribute.target!.uid)
        .toList();

    disableFields(fieldsToDisable);
  }

  getAutoGeneratedValues() {
    List<D2ProgramTrackedEntityAttribute> autogeneratedAttributes = program
        .programTrackedEntityAttributes
        .where((D2ProgramTrackedEntityAttribute pAttribute) =>
            pAttribute.trackedEntityAttribute.target!.generated ?? false)
        .toList();

    Map<String, dynamic> values = {};

    D2OrgUnit? orgUnit = D2OrgUnitRepository(db).getByUid(this.orgUnit);

    for (D2ProgramTrackedEntityAttribute pAttribute
        in autogeneratedAttributes) {
      String attributeId = pAttribute.trackedEntityAttribute.target!.uid;
      D2ReservedValue? reservedValue = D2ReservedValueRepository(db)
          .getReservedValue(owner: pAttribute, orgUnit: orgUnit!);
      if (reservedValue != null) {
        values.addAll({attributeId: reservedValue.value});
        reservedValues.add(reservedValue);
      } else {
        setError(attributeId,
            "Could not auto fill this field. Please make sure you have required reserved values");
      }
    }

    setValues(values);
  }

  getMandatoryFields() {
    List<String> mandatoryFields = program.programTrackedEntityAttributes
        .where((pAttribute) => pAttribute.mandatory)
        .map((pAttribute) => pAttribute.trackedEntityAttribute.target!.uid)
        .toList();
    this.mandatoryFields.addAll(mandatoryFields);
  }

  @override
  FieldState getFieldState(String key) {
    void onChange(value) {
      setValue(key, value);
      spawnProgramRuleEngine(programRuleEngine, key);
    }

    bool hidden = isFieldHidden(key);
    bool disabled = isFieldDisabled(key);
    bool mandatory = isFieldMandatory(key);
    dynamic value = getValue(key);
    String? error = getError(key);
    String? warning = getWarning(key);
    return FieldState(
        onChange: onChange,
        hidden: hidden,
        value: value,
        disabled: disabled,
        warning: warning,
        mandatory: mandatory,
        error: error);
  }

  updateReservedValues() {
    for (D2ReservedValue value in reservedValues) {
      value.setAssigned();
    }
    D2ReservedValueRepository(db).saveEntities(reservedValues);
  }

  Future<D2Enrollment> create() async {
    Map<String, dynamic> validatedFormValues = submit();
    D2OrgUnit? orgUnit = D2OrgUnitRepository(db).getByUid(this.orgUnit);
    if (orgUnit == null) {
      throw "Could not get entity's organisation unit. You either have to pass it as a parameter when initializing the controller or have a required field with key 'orgUnit'";
    }
    D2TrackedEntity trackedEntity = D2TrackedEntity.fromFormValues(
        validatedFormValues,
        db: db,
        program: program,
        orgUnit: orgUnit);
    trackedEntity.save(db);
    updateReservedValues();
    return trackedEntity.enrollments.first;
  }

  Future<D2Enrollment> update() async {
    if (trackedEntity == null) {
      throw "Invalid update call. Only call update if a default trackedEntity has been passed as a parameter when initializing the controller";
    }
    Map<String, dynamic> validatedFormValues = submit();
    D2OrgUnit? orgUnit = D2OrgUnitRepository(db).getByUid(this.orgUnit);
    trackedEntity!
        .updateFromFormValues(validatedFormValues, db: db, program: program);

    if (enrollment != null) {
      enrollment!
          .updateFromFormValues(validatedFormValues, db: db, program: program);
      enrollment!.save(db);
    } else {
      if (orgUnit == null) {
        throw "Could not get entity's organisation unit. You have to pass it as a parameter when initializing the controller.";
      }
      D2Enrollment enrollment = D2Enrollment.fromFormValues(validatedFormValues,
          db: db,
          trackedEntity: trackedEntity!,
          program: program,
          orgUnit: orgUnit);

      trackedEntity!.enrollments.add(enrollment);
      this.enrollment = enrollment;
    }
    trackedEntity!.save(db);
    return enrollment!;
  }

  ///Calls on submit and then saves the updated data. If the enrollment is new, a tracked entity is also created. It doesn't really need to be an async function
  Future<D2Enrollment> save() async {
    if (trackedEntity != null) {
      return update();
    } else {
      return create();
    }
  }
}
