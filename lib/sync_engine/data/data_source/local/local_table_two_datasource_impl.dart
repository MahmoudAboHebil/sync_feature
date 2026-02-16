import 'package:isar/isar.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/helper.dart';
import 'package:sync_feature/core/isar_service/collections/table_two_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/models/table_two_model.dart';

import '../../../domain/entities/standard_table_record.dart';

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
  Future<List<String>> getForeignkeyEntitiesIdsBulk(
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

  @override
  Future<void> softDeleteEntities(List<String> ids) async {
    final uniqueIds = ids.toSet();
    List<TableTwoCollection> results = [];
    const batchSize = 200;
    for (final batch in Helper.chunk(uniqueIds.toList(), batchSize)) {
      final result = await IsarService.isar.tableTwoCollections
          .filter()
          .anyOf(batch, (q, id) => q.entityIdEqualTo(id))
          .findAll();
      results = [...results, ...result];
    }

    for (final r in results) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableTwoCollections.putAll(results);
    });
  }

  @override
  Future<void> updateEntity<T>(T model) async {
    final modelTwo = model as TableTwoModel;

    final oldCollection = await IsarService.isar.tableTwoCollections
        .filter()
        .entityIdEqualTo(modelTwo.entityId)
        .findFirst();

    if (oldCollection != null) {
      final newCollection = TableTwoCollection()
        ..id = oldCollection.id
        ..entityId = modelTwo.entityId
        ..centerId = modelTwo.centerId
        ..byDevice = modelTwo.byDevice
        ..version = modelTwo.version
        ..createdAt = modelTwo.createdAt
        ..updatedAt = modelTwo.updatedAt
        ..byUser = modelTwo.byUser
        ..isDeleted = modelTwo.isDeleted
        ..message = modelTwo.message
        ..forKeyTableOne = modelTwo.forkeyTableOne;
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.tableTwoCollections.put(newCollection);
      });
    } else {
      throw Exception(
        'there is no record in db for ${modelTwo.entityId} at ${DBTable.table2.name} table',
      );
    }
  }

  @override
  Future<StandardTableRecord?> getEntity(String entityId) async {
    final record = await IsarService.isar.tableTwoCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findFirst();
    if (record == null) return null;
    return TableTwoModel.fromCollection(record);
  }

  @override
  Future<void> insertEntity<T>(T model) async {
    final tableTwoModel = model as TableTwoModel;
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableTwoCollections.put(
        tableTwoModel.toCollection(),
      );
    });
  }
}
