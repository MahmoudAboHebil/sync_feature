import 'package:isar/isar.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/isar_service/collections/operation_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/operation_status.dart';
import '../../../../core/helper.dart';
import '../../models/operation_model.dart';

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

  Future<void> updateOperation({
    required String operationId,
    OperationState? state,
    int? retryCount,
    DateTime? lastAttemptAt,
    DateTime? nextRetryAt,
  }) async {
    final oldOperation = await IsarService.isar.operationCollections
        .filter()
        .operationIdEqualTo(operationId)
        .findFirst();

    if (oldOperation != null) {
      final newState = state == null ? oldOperation.status : state.name;
      final newCollection = oldOperation
        ..status = newState
        ..retryCount = (retryCount ?? oldOperation.retryCount)
        ..lastAttemptAt = (lastAttemptAt ?? oldOperation.lastAttemptAt)
        ..nextRetryAt = (nextRetryAt ?? oldOperation.nextRetryAt);

      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.operationCollections.put(newCollection);
      });
    }
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

  Future<void> _resetProcessingOperationIds(DBTable table) async {
    final oldOperation = await IsarService.isar.operationCollections
        .filter()
        .tableEqualTo(table.name)
        .and()
        .statusEqualTo(OperationState.processing.name)
        .findAll();
    if (oldOperation.isNotEmpty) {
      List<OperationCollection> newOperation = [];
      final uuid = Uuid();
      for (var oper in oldOperation) {
        newOperation.add(oper..operationId = uuid.v4());
      }

      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.operationCollections.putAll(newOperation);
      });
    }
  }

  Future<List<OperationModel>> getPendingTableOperationAscending(
    DBTable table,
  ) async {
    final now = DateTime.now();

    final allCollections = await IsarService.isar.operationCollections
        .filter()
        .tableEqualTo(table.name)
        .and()
        .group((q) => q.nextRetryAtEqualTo(now).or().nextRetryAtLessThan(now))
        .and()
        .group(
          (q) => q
              .statusEqualTo(OperationState.pending.name)
              .or()
              .statusEqualTo(OperationState.processing.name),
        )
        .sortByCreatedAt()
        .findAll();

    return allCollections
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
    print('cccsdfsdf ${collections.length}');

    final x = collections
        .map((coll) => OperationModel.fromCollection(coll))
        .toList();

    print(x);
    return x;
  }

  Future<void> removeOperationsByEntity(String entityId) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.operationCollections
          .filter()
          .entityIdEqualTo(entityId)
          .deleteAll();
    });
  }

  Future<void> removeOperationsByEntitiesIds(List<String> entitiesIds) async {
    final uniqueIds = entitiesIds.toSet();
    const batchSize = 200;
    await IsarService.isar.writeTxn(() async {
      for (final batch in Helper.chunk(uniqueIds.toList(), batchSize)) {
        await IsarService.isar.operationCollections
            .filter()
            .anyOf(batch, (q, id) => q.entityIdEqualTo(id))
            .deleteAll();
      }
    });
  }

  Future<void> removeOperationsContainsAction(
    String entityId,
    OperationAction action,
  ) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.operationCollections
          .filter()
          .entityIdEqualTo(entityId)
          .and()
          .actionEqualTo(action.name)
          .deleteAll();
    });
  }
}
