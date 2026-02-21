import 'package:isar/isar.dart';
import 'package:sync_feature/core/isar_service/collections/table_three_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';

import '../../../../core/enums/DB_Table.dart';
import '../../../../core/helper.dart';
import '../../models/standard_table_record_model.dart';
import '../../models/table_three_model.dart';

class LocalTableThreeDatasource implements LocalTableDatasource {
  @override
  Future<void> softDelete(String entityId) async {
    final records = await IsarService.isar.tableThreeCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findAll();

    for (final r in records) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableThreeCollections.putAll(records);
    });
  }

  @override
  Future<List<String>> getForeignkeyEntitiesIdsBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  }) async {
    Set<String> ids = {};
    List<TableThreeCollection> collections = [];

    if (parentTable == DBTable.table_two) {
      if (test) {
        collections = tableThree.where((coll) {
          final x = parentsIds.contains(coll.forKeyTableTwo);
          return x;
        }).toList();
      } else {
        const batchSize = 200;

        for (final batch in Helper.chunk(parentsIds.toList(), batchSize)) {
          final result = await IsarService.isar.tableThreeCollections
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
      'there is fornkey for this table (${parentTable.name} at this tableThree table',
    );
  }

  @override
  DBTable get table => DBTable.table_three;

  @override
  Future<void> softDeleteEntities(List<String> ids) async {
    final uniqueIds = ids.toSet();
    List<TableThreeCollection> results = [];
    const batchSize = 200;
    for (final batch in Helper.chunk(uniqueIds.toList(), batchSize)) {
      final result = await IsarService.isar.tableThreeCollections
          .filter()
          .anyOf(batch, (q, id) => q.entityIdEqualTo(id))
          .findAll();
      results = [...results, ...result];
    }

    for (final r in results) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableThreeCollections.putAll(results);
    });
  }

  @override
  Future<void> updateEntity<T>(T model) async {
    final modelThree = model as TableThreeModel;

    final oldCollection = await IsarService.isar.tableThreeCollections
        .filter()
        .entityIdEqualTo(modelThree.entityId)
        .findFirst();

    if (oldCollection != null) {
      final newCollection = TableThreeCollection()
        ..id = oldCollection.id
        ..entityId = modelThree.entityId
        ..centerId = modelThree.centerId
        ..byDevice = modelThree.byDevice
        ..version = modelThree.version
        ..createdAt = modelThree.createdAt
        ..updatedAt = modelThree.updatedAt
        ..byUser = modelThree.byUser
        ..isDeleted = modelThree.isDeleted
        ..message = modelThree.message
        ..forKeyTableTwo = modelThree.forKeyTableTwo;
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.tableThreeCollections.put(newCollection);
      });
    } else {
      throw Exception(
        'there is no record in db for ${modelThree.entityId} at ${DBTable.table_three.name} table',
      );
    }
  }

  @override
  Future<StandardTableRecordModel?> getEntity(String entityId) async {
    final record = await IsarService.isar.tableThreeCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findFirst();
    if (record == null) return null;
    return TableThreeModel.fromCollection(record);
  }

  @override
  Future<void> insertEntity<T>(T model) async {
    final tableThreeModel = model as TableThreeModel;
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableThreeCollections.put(
        tableThreeModel.toCollection(),
      );
    });
  }
}
