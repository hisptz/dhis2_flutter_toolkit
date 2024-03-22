import 'package:dhis2_flutter_toolkit/dhis2_flutter_toolkit.dart';
import 'package:dhis2_flutter_toolkit/src/models/data/base_editable.dart';

import 'package:objectbox/objectbox.dart';

import 'upload_base.dart';

@Entity()
class D2TrackedEntityAttributeValue extends D2DataResource
    implements SyncableData, D2BaseEditable {
  @override
  int id = 0;
  @override
  DateTime createdAt;

  @Unique()
  String uid;

  @override
  DateTime updatedAt;

  String value;

  final trackedEntityAttribute = ToOne<D2TrackedEntityAttribute>();
  final trackedEntity = ToOne<D2TrackedEntity>();

  D2TrackedEntityAttributeValue(
      this.uid, this.createdAt, this.updatedAt, this.value, this.synced);

  D2TrackedEntityAttributeValue.fromMap(
      D2ObjectBox db, Map json, String trackedEntityId)
      : createdAt = DateTime.parse(json["createdAt"]),
        updatedAt = DateTime.parse(json["updatedAt"]),
        uid = "$trackedEntityId-${json["attribute"]}",
        synced = true,
        value = json["value"] {
    String uid = "$trackedEntityId-${json["attribute"]}";
    id = D2TrackedEntityAttributeValueRepository(db).getIdByUid(uid) ?? 0;

    trackedEntityAttribute.target =
        D2TrackedEntityAttributeRepository(db).getByUid(json["attribute"]);
    trackedEntity.target =
        D2TrackedEntityRepository(db).getByUid(trackedEntityId);
  }

  @override
  bool synced;

  @override
  Future<Map<String, dynamic>> toMap({D2ObjectBox? db}) async {
    return {"attribute": trackedEntityAttribute.target?.uid, "value": value};
  }

  @override
  Map<String, dynamic> toFormValues() {
    return {uid: value};
  }
}
