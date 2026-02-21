import 'package:sync_feature/core/enums/DB_Table.dart';

import '../../models/standard_table_record_model.dart';

abstract class LocalTableDatasource {
  DBTable get table;
  Future<void> softDelete(String entityId);
  Future<void> softDeleteEntities(List<String> ids);
  Future<List<String>> getForeignkeyEntitiesIdsBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  });
  Future<void> updateEntity<T>(T model);
  Future<void> insertEntity<T>(T model);
  Future<StandardTableRecordModel?> getEntity(String entityId);
}
