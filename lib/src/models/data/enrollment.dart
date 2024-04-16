import 'dart:convert';

import 'package:dhis2_flutter_toolkit/dhis2_flutter_toolkit.dart';
import 'package:dhis2_flutter_toolkit/src/utils/uid.dart';
import 'package:objectbox/objectbox.dart';

import 'base.dart';
import 'base_editable.dart';
import 'upload_base.dart';

@Entity()
class D2Enrollment extends SyncDataSource
    implements SyncableData, D2BaseEditable {
  @override
  int id = 0;
  @override
  DateTime createdAt;

  @override
  DateTime updatedAt;

  @override
  @Unique()
  String uid;
  DateTime enrolledAt;
  bool deleted;
  bool followup;
  DateTime occurredAt;
  String status;
  String? notes;
  String? geometry;

  @Backlink("enrollment")
  final events = ToMany<D2Event>();

  @Backlink("fromEnrollment")
  final relationships = ToMany<D2Relationship>();

  final trackedEntity = ToOne<D2TrackedEntity>();

  final orgUnit = ToOne<D2OrgUnit>();

  final program = ToOne<D2Program>();

  get orgUnitName {
    return orgUnit.target?.name;
  }

  D2Enrollment(
      this.uid,
      this.updatedAt,
      this.createdAt,
      this.enrolledAt,
      this.followup,
      this.deleted,
      this.occurredAt,
      this.status,
      this.notes,
      this.synced,
      this.geometry);

  D2Enrollment.fromMap(D2ObjectBox db, Map json)
      : uid = json["enrollment"],
        updatedAt = DateTime.parse(json["updatedAt"]),
        createdAt = DateTime.parse(json["createdAt"]),
        enrolledAt = DateTime.parse(json["enrolledAt"]),
        followup = json["followUp"],
        deleted = json["deleted"],
        occurredAt = DateTime.parse(json["occurredAt"]),
        status = json["status"],
        synced = true,
        geometry =
            json["geometry"] != null ? jsonEncode(json["geometry"]) : null,
        notes = jsonEncode(json["notes"]) {
    id = D2EnrollmentRepository(db).getIdByUid(json["enrollment"]) ?? 0;

    trackedEntity.target =
        D2TrackedEntityRepository(db).getByUid(json["trackedEntity"]);
    orgUnit.target = D2OrgUnitRepository(db).getByUid(json["orgUnit"]);
    program.target = D2ProgramRepository(db).getByUid(json["program"]);
  }

  D2Enrollment.fromFormValues(Map<String, dynamic> values,
      {required D2ObjectBox db,
      required D2TrackedEntity trackedEntity,
      required D2Program program,
      required D2OrgUnit orgUnit})
      : uid = D2UID.generate(),
        updatedAt = DateTime.now(),
        createdAt = DateTime.now(),
        enrolledAt =
            DateTime.tryParse(values["enrolledAt"] ?? "") ?? DateTime.now(),
        followup = false,
        deleted = false,
        occurredAt =
            DateTime.tryParse(values["occurredAt"] ?? "") ?? DateTime.now(),
        status = values["status"] ?? 'ACTIVE',
        synced = false,
        notes = "{}" {
    this.trackedEntity.target = trackedEntity;
    this.orgUnit.target = orgUnit;
    this.program.target = program;

    if (values["geometry"] != null) {
      var geometryValue = values["geometry"];

      ///A form has geometry. This should be inserted as a serialized JSON
      if (geometryValue is D2GeometryValue) {
        Map<String, dynamic> geometry = geometryValue.toGeoJson();
        String geometryString = jsonEncode(geometry);
        this.geometry = geometryString;
      }
    }
  }

  @override
  bool synced;

  @override
  Future<Map<String, dynamic>> toMap({D2ObjectBox? db}) async {
    if (db == null) {
      throw "ObjectBox instance is required";
    }

    Map<String, dynamic> payload = {
      "orgUnit": orgUnit.target?.uid,
      "program": program.target?.uid,
      "trackedEntity": trackedEntity.target?.uid,
      "enrollment": uid,
      "enrolledAt": enrolledAt.toIso8601String(),
      "deleted": deleted,
      "occurredAt": occurredAt.toIso8601String(),
      "status": status,
      "notes": jsonDecode(notes ?? "[]"),
    };

    if (geometry != null) {
      payload.addAll({"geometry": jsonDecode(geometry!)});
    }

    return payload;
  }

  @override
  Map<String, dynamic> toFormValues() {
    Map<String, dynamic> data = {
      "occurredAt": occurredAt.toIso8601String(),
      "orgUnit": orgUnit.target!.uid,
      "enrolledAt": enrolledAt.toIso8601String()
    };

    if (geometry != null) {
      Map<String, dynamic> geometryObject = jsonDecode(geometry!);
      data.addAll({"geometry": D2GeometryValue.fromGeoJson(geometryObject)});
    }

    return data;
  }

  @override
  void updateFromFormValues(Map<String, dynamic> values,
      {required D2ObjectBox db, D2Program? program, D2OrgUnit? orgUnit}) {
    occurredAt = DateTime.tryParse(values["occurredAt"]) ?? occurredAt;
    enrolledAt = DateTime.tryParse(values["enrolledAt"]) ?? enrolledAt;
    if (orgUnit != null) {
      this.orgUnit.target = orgUnit;
    }
    trackedEntity.target!.updateFromFormValues(values, db: db);

    if (values["geometry"] != null) {
      var geometryValue = values["geometry"];

      ///A form has geometry. This should be inserted as a serialized JSON
      if (geometryValue is D2GeometryValue) {
        Map<String, dynamic> geometry = geometryValue.toGeoJson();
        String geometryString = jsonEncode(geometry);
        this.geometry = geometryString;
      }
    }

    synced = false;
  }

  @override
  void save(D2ObjectBox db) {
    id = D2EnrollmentRepository(db).saveEntity(this);
  }
}
