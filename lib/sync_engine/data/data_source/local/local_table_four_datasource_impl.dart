import 'package:isar/isar.dart';
import 'package:sync_feature/core/isar_service/collections/table_four_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';

import '../../../../core/enums/DB_Table.dart';
import '../../../../core/helper.dart';

class LocalTableFourDatasource implements LocalTableDatasource {
  @override
  Future<void> softDelete(String entityId) async {
    final records = await IsarService.isar.tableFourCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findAll();

    for (final r in records) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableFourCollections.putAll(records);
    });
  }

  @override
  Future<List<String>> getEntitiesIdsByFornKeyBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  }) async {
    Set<String> ids = {};
    List<TableFourCollection> collections = [];
    if (parentTable == DBTable.table2) {
      if (test) {
        collections = tableFour.where((coll) {
          final x = parentsIds.contains(coll.forKeyTableTwo);
          return x;
        }).toList();
      } else {
        const batchSize = 200;

        for (final batch in Helper.chunk(parentsIds.toList(), batchSize)) {
          final result = await IsarService.isar.tableFourCollections
              .filter()
              .anyOf(batch, (q, id) => q.forKeyTableTwoEqualTo(id))
              .findAll();
          collections = [...collections, ...result];
        }
      }

      for (final coll in collections) {
        ids.add(coll.entityId);
      }

      return ids.toList();
    }
    throw Exception(
      'there is fornkey for this table (${parentTable.name} at this tableFour table',
    );
  }

  @override
  DBTable get table => DBTable.table4;
}
