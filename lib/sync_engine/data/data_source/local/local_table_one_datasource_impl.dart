import 'package:isar/isar.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/isar_service/collections/table_one_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart'
    show IsarService;
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';

import '../../../../core/helper.dart';
import '../../models/standard_table_record_model.dart';
import '../../models/table_one_model.dart';

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
  Future<List<String>> getForeignkeyEntitiesIdsBulk(
    DBTable parentTable,
    List<String> parentsIds, {
    bool test = false,
  }) {
    throw Exception('there are no fornKey in tableOne table');
  }

  @override
  DBTable get table => DBTable.table_one;

  @override
  Future<void> softDeleteEntities(List<String> ids) async {
    final uniqueIds = ids.toSet();
    List<TableOneCollection> results = [];
    const batchSize = 200;
    for (final batch in Helper.chunk(uniqueIds.toList(), batchSize)) {
      final result = await IsarService.isar.tableOneCollections
          .filter()
          .anyOf(batch, (q, id) => q.entityIdEqualTo(id))
          .findAll();
      results = [...results, ...result];
    }

    for (final r in results) {
      r.isDeleted = true;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableOneCollections.putAll(results);
    });
  }

  @override
  Future<void> updateEntity<T>(T model) async {
    final modelOne = model as TableOneModel;

    final oldCollection = await IsarService.isar.tableOneCollections
        .filter()
        .entityIdEqualTo(modelOne.entityId)
        .findFirst();

    if (oldCollection != null) {
      final newCollection = TableOneCollection()
        ..id = oldCollection.id
        ..entityId = modelOne.entityId
        ..centerId = modelOne.centerId
        ..byDevice = modelOne.byDevice
        ..version = modelOne.version
        ..createdAt = modelOne.createdAt
        ..updatedAt = modelOne.updatedAt
        ..byUser = modelOne.byUser
        ..isDeleted = modelOne.isDeleted
        ..message = modelOne.message;
      await IsarService.isar.writeTxn(() async {
        final x = await IsarService.isar.tableOneCollections.put(newCollection);
        print('final update =$x');
      });
    } else {
      throw Exception(
        'there is no record in db for ${model.entityId} at ${DBTable.table_one.name} table',
      );
    }
  }

  @override
  Future<StandardTableRecordModel?> getEntity(String entityId) async {
    final record = await IsarService.isar.tableOneCollections
        .filter()
        .entityIdEqualTo(entityId)
        .findFirst();
    if (record == null) return null;
    return TableOneModel.fromCollection(record);
  }

  @override
  Future<void> insertEntity<T>(T model) async {
    final tableOneModel = model as TableOneModel;
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.tableOneCollections.put(
        tableOneModel.toCollection(),
      );
    });
  }
}
