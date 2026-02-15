import 'package:isar/isar.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/isar_service/collections/operation_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';
import 'package:sync_feature/sync_engine/data/data_source/models/operation_model.dart';

class LocalQueueDatasource {
  Future<void> insertToQueue(OperationModel operation) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.operationCollections.put(operation.toCollection());
    });
  }

  Future<void> updateOperationInQueue(OperationModel operation) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.operationCollections.put(operation.toCollection());
    });
  }

  Future<void> removeFromQueue(String operationId) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.operationCollections
          .filter()
          .operationIdEqualTo(operationId)
          .deleteAll();
    });
  }

  Future<OperationModel?> getOperationFromQueue(int id) async {
    final operation = await IsarService.isar.operationCollections.get(id);
    if (operation == null) return null;
    return OperationModel.fromCollection(operation);
  }

  Future<List<OperationModel>> getPendingTableOperationAscending(
    DBTable table,
  ) async {
    final collections = await IsarService.isar.operationCollections
        .filter()
        .tableEqualTo(table.name)
        .sortByCreatedAt()
        .findAll();
    return collections
        .map((coll) => OperationModel.fromCollection(coll))
        .toList();
  }

  Future<List<OperationModel>> getOperationsByEntityAscending(
    String entityId,
  ) async {
    final collections = await IsarService.isar.operationCollections
        .filter()
        .entityIdEqualTo(entityId)
        .sortByCreatedAt()
        .findAll();
    return collections
        .map((coll) => OperationModel.fromCollection(coll))
        .toList();
  }

  Future<void> removeOperationsByEntity(String entityId) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.operationCollections
          .filter()
          .entityIdEqualTo(entityId)
          .deleteAll();
    });
  }
}
