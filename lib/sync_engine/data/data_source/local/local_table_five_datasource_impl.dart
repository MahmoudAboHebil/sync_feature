import 'package:isar/isar.dart';
import 'package:sync_feature/core/isar_service/collections/table_five_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';

import '../../../../core/enums/DB_Table.dart';
import '../../../../core/helper.dart';

class LocalTableFiveDatasource implements LocalTableDatasource {
  @override
  Future<void> softDelete(String entityId) async {
    final records = await IsarService.isar.tableFiveCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findAll();

    for (final r in records) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableFiveCollections.putAll(records);
    });
  }

  @override
  Future<List<String>> getEntitiesIdsByFornKeyBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  }) async {
    Set<String> ids = {};
    List<TableFiveCollection> collections = [];
    if (parentTable == DBTable.table3) {
      if (test) {
        collections = tableFive.where((coll) {
          final x = parentsIds.contains(coll.forKeyTableThree);
          return x;
        }).toList();
      } else {
        const batchSize = 200;

        for (final batch in Helper.chunk(parentsIds.toList(), batchSize)) {
          final result = await IsarService.isar.tableFiveCollections
              .filter()
              .anyOf(batch, (q, id) => q.forKeyTableThreeEqualTo(id))
              .findAll();
          collections = [...collections, ...result];
        }
      }
      for (final coll in collections) {
        ids.add(coll.entityId);
      }

      return ids.toList();
    } else if (parentTable == DBTable.table4) {
      if (test) {
        collections = tableFive.where((coll) {
          final x = parentsIds.contains(coll.forKeyTableFour);
          return x;
        }).toList();
      } else {
        const batchSize = 200;

        for (final batch in Helper.chunk(parentsIds.toList(), batchSize)) {
          final result = await IsarService.isar.tableFiveCollections
              .filter()
              .anyOf(batch, (q, id) => q.forKeyTableFourEqualTo(id))
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
      'there is fornkey for this table (${parentTable.name} at this tableFive table',
    );
  }

  @override
  DBTable get table => DBTable.table5;
}
