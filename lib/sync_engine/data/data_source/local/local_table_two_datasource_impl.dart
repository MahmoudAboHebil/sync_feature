import 'package:isar/isar.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/helper.dart';
import 'package:sync_feature/core/isar_service/collections/table_two_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';

class LocalTableTwoDatasource implements LocalTableDatasource {
  @override
  Future<void> softDelete(String entityId) async {
    final records = await IsarService.isar.tableTwoCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findAll();

    for (final r in records) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableTwoCollections.putAll(records);
    });
  }

  @override
  Future<List<String>> getEntitiesIdsByFornKeyBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  }) async {
    Set<String> ids = {};
    List<TableTwoCollection> collections = [];
    if (parentTable == DBTable.table1) {
      if (test) {
        collections = tableTwo.where((coll) {
          final x = parentsIds.contains(coll.forKeyTableOne);
          return x;
        }).toList();
      } else {
        const batchSize = 200;

        for (final batch in Helper.chunk(parentsIds.toList(), batchSize)) {
          final result = await IsarService.isar.tableTwoCollections
              .filter()
              .anyOf(batch, (q, id) => q.forKeyTableOneEqualTo(id))
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
      'there is fornkey for this table (${parentTable.name} at this tableTwo table',
    );
  }

  @override
  DBTable get table => DBTable.table2;
}
