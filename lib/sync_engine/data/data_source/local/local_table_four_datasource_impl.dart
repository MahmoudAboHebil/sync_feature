import 'package:isar/isar.dart';
import 'package:sync_feature/core/isar_service/collections/table_four_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';

import '../../../../core/enums/DB_Table.dart';
import '../../../../core/helper.dart';
import '../../models/standard_table_record_model.dart';
import '../../models/table_four_model.dart';

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
  Future<List<String>> getForeignkeyEntitiesIdsBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  }) async {
    Set<String> ids = {};
    List<TableFourCollection> collections = [];
    if (parentTable == DBTable.table_two) {
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
  DBTable get table => DBTable.table_four;
  @override
  Future<void> softDeleteEntities(List<String> ids) async {
    final uniqueIds = ids.toSet();
    List<TableFourCollection> results = [];
    const batchSize = 200;
    for (final batch in Helper.chunk(uniqueIds.toList(), batchSize)) {
      final result = await IsarService.isar.tableFourCollections
          .filter()
          .anyOf(batch, (q, id) => q.entityIdEqualTo(id))
          .findAll();
      results = [...results, ...result];
    }

    for (final r in results) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableFourCollections.putAll(results);
    });
  }

  @override
  Future<void> updateEntity<T>(T model) async {
    final modelFour = model as TableFourModel;

    final oldCollection = await IsarService.isar.tableFourCollections
        .filter()
        .entityIdEqualTo(modelFour.entityId)
        .findFirst();

    if (oldCollection != null) {
      final newCollection = TableFourCollection()
        ..id = oldCollection.id
        ..entityId = modelFour.entityId
        ..centerId = modelFour.centerId
        ..byDevice = modelFour.byDevice
        ..version = modelFour.version
        ..createdAt = modelFour.createdAt
        ..updatedAt = modelFour.updatedAt
        ..byUser = modelFour.byUser
        ..isDeleted = modelFour.isDeleted
        ..message = modelFour.message
        ..forKeyTableTwo = modelFour.forKeyTableTwo;
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.tableFourCollections.put(newCollection);
      });
    } else {
      throw Exception(
        'there is no record in db for ${model.entityId} at ${DBTable.table_four.name} table',
      );
    }
  }

  @override
  Future<StandardTableRecordModel?> getEntity(String entityId) async {
    final record = await IsarService.isar.tableFourCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findFirst();
    if (record == null) return null;
    return TableFourModel.fromCollection(record);
  }

  @override
  Future<void> insertEntity<T>(T model) async {
    final tableFourModel = model as TableFourModel;
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableFourCollections.put(
        tableFourModel.toCollection(),
      );
    });
  }
}
