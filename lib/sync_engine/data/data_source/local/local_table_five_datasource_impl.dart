import 'package:isar/isar.dart';
import 'package:sync_feature/core/isar_service/collections/table_five_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';

import '../../../../core/enums/DB_Table.dart';
import '../../../../core/helper.dart';
import '../../models/standard_table_record_model.dart';
import '../../models/table_five_model.dart';

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
  Future<List<String>> getForeignkeyEntitiesIdsBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  }) async {
    Set<String> ids = {};
    List<TableFiveCollection> collections = [];
    if (parentTable == DBTable.table_three) {
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
    } else if (parentTable == DBTable.table_four) {
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
  DBTable get table => DBTable.table_five;

  @override
  Future<void> softDeleteEntities(List<String> ids) async {
    final uniqueIds = ids.toSet();
    List<TableFiveCollection> results = [];
    const batchSize = 200;
    for (final batch in Helper.chunk(uniqueIds.toList(), batchSize)) {
      final result = await IsarService.isar.tableFiveCollections
          .filter()
          .anyOf(batch, (q, id) => q.entityIdEqualTo(id))
          .findAll();
      results = [...results, ...result];
    }

    for (final r in results) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableFiveCollections.putAll(results);
    });
  }

  @override
  Future<void> updateEntity<T>(T model) async {
    final modelFive = model as TableFiveModel;

    final oldCollection = await IsarService.isar.tableFiveCollections
        .filter()
        .entityIdEqualTo(modelFive.entityId)
        .findFirst();

    if (oldCollection != null) {
      final newCollection = TableFiveCollection()
        ..id = oldCollection.id
        ..entityId = modelFive.entityId
        ..centerId = modelFive.centerId
        ..byDevice = modelFive.byDevice
        ..version = modelFive.version
        ..createdAt = modelFive.createdAt
        ..updatedAt = modelFive.updatedAt
        ..byUser = modelFive.byUser
        ..isDeleted = modelFive.isDeleted
        ..message = modelFive.message
        ..forKeyTableThree = modelFive.forKeyTableThree
        ..forKeyTableFour = modelFive.forKeyTableFour;
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.tableFiveCollections.put(newCollection);
      });
    } else {
      throw Exception(
        'there is no record in db for ${model.entityId} at ${DBTable.table_five.name} table',
      );
    }
  }

  @override
  Future<StandardTableRecordModel?> getEntity(String entityId) async {
    final record = await IsarService.isar.tableFiveCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findFirst();
    if (record == null) return null;
    return TableFiveModel.fromCollection(record);
  }

  @override
  Future<void> insertEntity<T>(T model) async {
    final tableFiveModel = model as TableFiveModel;
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableFiveCollections.put(
        tableFiveModel.toCollection(),
      );
    });
  }
}
