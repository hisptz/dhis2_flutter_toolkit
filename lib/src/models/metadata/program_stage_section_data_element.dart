import 'package:objectbox/objectbox.dart';

import '../../../objectbox.dart';
import '../../repositories/metadata/program_stage_section_data_element.dart';
import 'base.dart';
import 'data_element.dart';
import 'program_stage_section.dart';

@Entity()
class D2ProgramStageSectionDataElement extends D2MetaResource {
  int id = 0;

  @Unique()
  @override
  String uid;

  int sortOrder;

  D2ProgramStageSectionDataElement(this.uid, this.sortOrder);

  final dataElement = ToOne<D2DataElement>();
  final programStageSection = ToOne<D2ProgramStageSection>();

  D2ProgramStageSectionDataElement.fromSection(
      {required D2ObjectBox db,
      required D2ProgramStageSection section,
      required D2DataElement dataElement,
      required this.sortOrder})
      : uid = "${section.uid}-${dataElement.uid}" {
    id = D2ProgramStageSectionDataElementRepository(db).getIdByUid(uid) ?? 0;
    this.dataElement.target = dataElement;
    programStageSection.target = section;
  }
}
