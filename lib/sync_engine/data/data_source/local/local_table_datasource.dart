import 'package:sync_feature/core/enums/DB_Table.dart';

abstract class LocalTableDatasource {
  DBTable get table;
  Future<void> softDelete(String entityId);
  Future<List<String>> getEntitiesIdsByFornKeyBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  });
}
