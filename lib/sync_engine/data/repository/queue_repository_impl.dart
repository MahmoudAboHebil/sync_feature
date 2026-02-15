import 'package:dart_either/src/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/models/operation_model.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/queue_repository.dart';

class QueueRepositoryImpl extends QueueRepository {
  final LocalQueueDatasource _localQueueDatasource;
  QueueRepositoryImpl(this._localQueueDatasource);

  @override
  Future<Either<Failure, void>> addOperationToQueue(Operation operation) async {
    try {
      final isEntityDeleted = (operation.json["is_deleted"] as bool);
      if (isEntityDeleted && operation.action == OperationAction.update) {
        return Right(null);
      }
      await _localQueueDatasource.removeOperationsByEntity(operation.entityId);
      await _localQueueDatasource.insertToQueue(
        OperationModel.fromOperation(operation),
      );
      return Right(null);
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'Failed To add operation to Queue :${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Operation>>> getOperationsByEntity(
    String entityId,
  ) async {
    try {
      final operationsModels = await _localQueueDatasource
          .getOperationsByEntityAscending(entityId);
      final operations = operationsModels
          .map((mode) => mode.toOperation())
          .toList();
      return Right(operations);
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'Failed To get operation from Queue :${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Operation>>> getPendingOperationOrdered(
    DBTable dbTable,
  ) async {
    try {
      final operationsModels = await _localQueueDatasource
          .getPendingTableOperationAscending(dbTable);
      final operations = operationsModels
          .map((mode) => mode.toOperation())
          .toList();
      return Right(operations);
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'Failed To get operation from Queue :${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeEntityOperations(String entityId) async {
    try {
      await _localQueueDatasource.removeOperationsByEntity(entityId);
      return Right(null);
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'Failed To delete operation from Queue :${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeOperationToQueue(
    String operationId,
  ) async {
    try {
      await _localQueueDatasource.removeFromQueue(operationId);
      return Right(null);
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'Failed To delete operation from Queue :${e.toString()}',
        ),
      );
    }
  }
}
