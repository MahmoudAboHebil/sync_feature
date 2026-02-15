import 'package:isar/isar.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/isar_service/collections/table_one_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';

class LocalTableOneDatasource implements LocalTableDatasource {
  @override
  Future<void> softDelete(String entityId) async {
    final records = await IsarService.isar.tableOneCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findAll();

    for (final r in records) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableOneCollections.putAll(records);
    });
  }

  @override
  Future<List<String>> getEntitiesIdsByFornKeyBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  }) {
    throw Exception('there are no fornKey in tableOne table');
  }

  @override
  DBTable get table => DBTable.table1;
}
