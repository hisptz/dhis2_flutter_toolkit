import '../../../models/metadata/entry.dart';
import '../../../services/entry.dart';
import 'base_meta_download_mixin.dart';

mixin D2RelationshipTypeDownloadMixin
    on BaseMetaDownloadServiceMixin<D2RelationshipType> {
  @override
  String label = "Relationship Types";

  @override
  String resource = "relationshipTypes";

  D2RelationshipTypeDownloadMixin setupDownload(D2ClientService client) {
    setClient(client);
    setFields(["*"]);
    return this;
  }
}
