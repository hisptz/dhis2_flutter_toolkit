import 'dart:async';

import '../../../models/metadata/base.dart';
import '../../../services/client/client.dart';
import '../../../utils/download_status.dart';
import '../base.dart';

mixin BaseSingleMetaDownloadServiceMixin<T extends D2MetaResource>
    on BaseMetaRepository<T> {
  D2ClientService? client;
  abstract String resource;
  abstract String label;
  List<String> fields = [];
  List<String> filters = [];
  T? entity;

  StreamController<DownloadStatus> downloadController =
      StreamController<DownloadStatus>();

  BaseSingleMetaDownloadServiceMixin<T> setClient(D2ClientService client) {
    this.client = client;
    return this;
  }

  BaseSingleMetaDownloadServiceMixin<T> setFields(List<String> fields) {
    this.fields.addAll(fields);
    return this;
  }

  get url {
    return resource;
  }

  Stream<DownloadStatus> get downloadStream {
    return downloadController.stream;
  }

  get queryParams {
    Map<String, String> params = {};
    if (fields.isNotEmpty) {
      params["fields"] = fields.join(",");
    }
    if (filters.isNotEmpty) {
      params["filters"] = filters.join(",");
    }

    return params;
  }

  //Currently just checks if there is any data on the specific data model
  bool isSynced() {
    T? entity = box.query().build().findFirst();
    return entity != null;
  }

  Future<D?> getData<D>() async {
    return await client!.httpGet<D>(url, queryParameters: queryParams);
  }

  void download() async {
    DownloadStatus status = DownloadStatus(
        synced: 0, total: 1, status: Status.initialized, label: label);
    downloadController.add(status);
    Map<String, dynamic>? data = await getData<Map<String, dynamic>>();
    if (data == null) {
      downloadController.addError("Could not get $label");
      return;
    }
    T entity = mapper(data);
    box.put(entity);
    status.increment();
    downloadController.add(status.complete());
    downloadController.close();
  }
}
