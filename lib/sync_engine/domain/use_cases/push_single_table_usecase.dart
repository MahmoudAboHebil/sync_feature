import 'dart:math';

import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_status.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/core/error/sync_response.dart';
import 'package:sync_feature/core/use_cases/use_case.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/send_operation_to_server_usecase.dart';

import '../../../core/enums/operation_action.dart';
import '../../../core/error/netwrok_response.dart';
import '../repository/queue_repository.dart';

class PushSingleTableUseCaseParams {
  final DBTable table;
  final String deviceId;
  const PushSingleTableUseCaseParams({
    required this.table,
    required this.deviceId,
  });
}

class PushSingleTableUseCase
    implements
        UseCase<
          Either<Failure, List<SyncResponse>>,
          PushSingleTableUseCaseParams
        > {
  final QueueRepository _queueRepository;
  final TableRepository _tableRepository;
  final GetTableQueueUseCase _getTableQueueUseCase;
  final SendOperationToServerUseCase _sendOperationToServerUseCase;
  const PushSingleTableUseCase(
    this._queueRepository,
    this._tableRepository,
    this._getTableQueueUseCase,
    this._sendOperationToServerUseCase,
  );
  Future<void> _handlingError(Operation operation) async {
    final newRetry = operation.retryCount + 1;

    if (newRetry >= 5) {
      await _queueRepository.updateOperation(
        operationId: operation.id,
        state: OperationState.dead,
        retryCount: newRetry,
      );
    } else {
      final baseDelaySeconds = 10;
      final jitter = Random().nextInt(5);
      final delaySeconds =
          baseDelaySeconds * pow(2, operation.retryCount).toInt() + jitter;

      final nextRetry = DateTime.now().add(Duration(seconds: delaySeconds));
      await _queueRepository.updateOperation(
        operationId: operation.id,
        state: OperationState.pending,
        retryCount: newRetry,
        nextRetryAt: nextRetry,
      );
    }
  }

  @override
  Future<Either<Failure, List<SyncResponse>>> call(
    PushSingleTableUseCaseParams params,
  ) async {
    final tableQueue = await _getTableQueueUseCase.call(
      GetTableQueueUseCaseParams(table: params.table),
    );

    if (tableQueue.isLeft) {
      return Left(
        tableQueue.fold(
          ifLeft: (l) => l,
          ifRight: (_) => ProcessingFailure(message: 'Please Try again Later'),
        ),
      );
    }

    final queue = tableQueue.getOrThrow();
    if (queue.isEmpty) return const Right([]);

    const concurrency = 5;
    final List<SyncResponse> finalResults = [];

    for (int i = 0; i < queue.length; i += concurrency) {
      final batch = queue.skip(i).take(concurrency);

      final results = await Future.wait(
        batch.map((operation) => _processOperation(operation, params)),
      );

      finalResults.addAll(results);
    }

    return Right(finalResults);
  }

  Future<SyncResponse> _processOperation(
    Operation operation,
    PushSingleTableUseCaseParams params,
  ) async {
    try {
      await _queueRepository.updateOperation(
        operationId: operation.id,
        state: OperationState.processing,
        lastAttemptAt: DateTime.now(),
      );

      final response = await _sendOperationToServerUseCase.call(
        SendOperationToServerUseCaseParams(
          operation: operation,
          deviceId: params.deviceId,
        ),
      );

      if (response.isLeft) {
        await _handlingError(operation);
        return _networkError(operation);
      }

      final result = response.getOrThrow();

      if (result is NetworkSuccess) {
        await _queueRepository.removeOperationToQueue(operation.id);
        return _success(operation, result);
      }

      if (result is EntityIsDeleted) {
        return await _handleEntityDeleted(operation, params, result);
      }

      if (result is EntityIsNotFound) {
        return await _handleEntityDeleted(operation, params, result);
      }

      if (result is VersionConflict) {
        return await _handleVersionConflict(operation, params, result);
      }

      if (result is ParentIsDeleted) {
        return await _handleParentDeleted(operation, params, result);
      }

      await _handlingError(operation);
      return _networkError(operation, result);
    } catch (e, st) {
      await _handlingError(operation);
      return SyncResponse(
        networkResponse: NetworkFailure(details: st.toString()),
        operation: operation,
        deletedEntities: null,
        isError: true,
        willTry: true,
      );
    }
  }

  SyncResponse _networkError(Operation operation, [dynamic result]) {
    return SyncResponse(
      networkResponse: result ?? NetworkFailure(),
      operation: operation,
      deletedEntities: null,
      isError: true,
      willTry: true,
    );
  }

  SyncResponse _success(Operation operation, dynamic result) {
    return SyncResponse(
      networkResponse: result,
      operation: operation,
      deletedEntities: null,
      isError: false,
      willTry: false,
    );
  }

  Future<SyncResponse> _handleVersionConflict(
    Operation operation,
    PushSingleTableUseCaseParams params,
    VersionConflict result,
  ) async {
    if (result.data == null) {
      await _handlingError(operation);
      return _networkError(operation, result);
    }

    final replaceResult = await _tableRepository.replaceEntityLocalWithServer(
      params.table,
      result.data!,
    );

    if (replaceResult.isLeft) {
      await _handlingError(operation);
      return _networkError(operation, result);
    }

    await _queueRepository.removeOperationToQueue(operation.id);

    return _success(operation, result);
  }

  Future<SyncResponse> _handleEntityDeleted(
    Operation operation,
    PushSingleTableUseCaseParams params,
    NetworkFailure result,
  ) async {
    if (operation.action == OperationAction.delete) {
      await _queueRepository.removeOperationToQueue(operation.id);
      return _success(operation, result);
    }

    final deleted = await _tableRepository.deleteEntityCascadeNotNull(
      params.table,
      operation.entityId,
    );

    final deletedEntities = deleted.fold(
      ifLeft: (_) => null,
      ifRight: (d) => d,
    );

    await _queueRepository.removeOperationToQueue(operation.id);

    return SyncResponse(
      networkResponse: result,
      operation: operation,
      deletedEntities: deletedEntities,
      isError: false,
      willTry: false,
    );
  }

  Future<SyncResponse> _handleParentDeleted(
    Operation operation,
    PushSingleTableUseCaseParams params,
    ParentIsDeleted result,
  ) async {
    Map<DBTable, List<String>> list = {};

    final data = result.data ?? {};

    for (final entry in data.entries) {
      final table = DBTable.getDBTableFromString(entry.key);
      final ids = entry.value;

      if (ids is! List<String>) continue;

      for (final parentId in ids) {
        final deletedResult = await _tableRepository.deleteEntityCascadeNotNull(
          table,
          parentId,
        );

        final deletedEntities = deletedResult.fold(
          ifLeft: (_) => <DBTable, List<String>>{},
          ifRight: (d) => d,
        );

        for (final entry in deletedEntities.entries) {
          final table = entry.key;
          final newIds = entry.value;

          final existingIds = list[table] ?? [];

          list[table] = {...existingIds, ...newIds}.toList();
        }
      }
    }

    // ضيف العملية نفسها ضمن المحذوفات
    final tableIds = list[params.table] ?? [];
    list[params.table] = {...tableIds, operation.entityId}.toList();

    await _queueRepository.removeOperationToQueue(operation.id);

    return SyncResponse(
      networkResponse: result,
      operation: operation,
      deletedEntities: list,
      isError: false,
      willTry: false,
    );
  }
}
