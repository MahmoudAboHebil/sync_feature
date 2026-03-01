import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_status.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';

abstract class QueueRepository {
  Future<Either<Failure, List<Operation>>> getPendingOperationOrdered(
    DBTable dbTable,
  );
  Future<Either<Failure, void>> addOperationToQueue(Operation operation);
  Future<Either<Failure, void>> updateOperation({
    required String operationId,
    OperationState? state,
    int? retryCount,
    DateTime? lastAttemptAt,
    DateTime? nextRetryAt,
  });
  Future<Either<Failure, void>> removeOperationToQueue(String operationId);
  Future<Either<Failure, void>> removeEntityOperations(String entityId);
  Future<Either<Failure, List<Operation>>> getOperationsByEntity(
    String entityId,
  );
}
