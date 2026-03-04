/*
import 'dart:math';

import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_status.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/core/error/sync_response.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';
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
      final leftValue =
          tableQueue.fold(ifLeft: (l) => l, ifRight: (d) => null) ??
              ProcessingFailure(message: 'Please Try again Later');
      return Left(leftValue);
    }
    final List<Operation> queue = tableQueue.getOrThrow();

    final List<SyncResponse> finalResults = [];
    for (var operation in queue) {
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
          final syncResponse = SyncResponse(
            networkResponse: NetworkFailure(),
            operation: operation,
            deletedEntities: null,
            isError: true,
            willTry: true,
          );
          finalResults.add(syncResponse);
          await _handlingError(operation);
          continue;
        }
        final responseResult = response.getOrThrow();

        if (responseResult is NetworkSuccess) {
          await _queueRepository.removeOperationToQueue(operation.id);
          continue;
        } else if (responseResult is EntityIsDeleted) {
          if (operation.action == OperationAction.delete) {
            await _queueRepository.removeOperationToQueue(operation.id);
            continue;
          } else {
            await IsarService.isar.writeTxn(() async {
              final deletedResult = await _tableRepository
                  .deleteEntityCascadeNotNull(params.table, operation.entityId);
              final deletedEntities = deletedResult.fold(
                ifLeft: (d) => null,
                ifRight: (d) => d,
              );
              final syncResponse = SyncResponse(
                networkResponse: responseResult,
                operation: operation,
                deletedEntities: deletedEntities,
                willTry: false,
                isError: false,
              );
              finalResults.add(syncResponse);
              await _queueRepository.removeOperationToQueue(operation.id);
            });

            continue;
          }
        } else if (responseResult is EntityIsNotFound) {
          final syncResponse = SyncResponse(
            networkResponse: responseResult,
            operation: operation,
            deletedEntities: null,
            isError: false,
            willTry: false,
          );
          finalResults.add(syncResponse);
          await _queueRepository.removeOperationToQueue(operation.id);
          continue;
        } else if (responseResult is VersionConflict) {
          if (responseResult.data != null) {
            final replaceResult = await _tableRepository
                .replaceEntityLocalWithServer(
              params.table,
              responseResult.data!,
            );

            if (replaceResult.isLeft) {
              final syncResponse = SyncResponse(
                networkResponse: responseResult,
                operation: operation,
                deletedEntities: null,
                isError: true,
                willTry: true,
              );
              finalResults.add(syncResponse);
              await _handlingError(operation);
              continue;
            }
            final syncResponse = SyncResponse(
              networkResponse: responseResult,
              operation: operation,
              deletedEntities: null,
              isError: false,
              willTry: false,
            );
            finalResults.add(syncResponse);
          } else {
            final syncResponse = SyncResponse(
              networkResponse: responseResult,
              operation: operation,
              deletedEntities: null,
              isError: true,
              willTry: true,
            );
            finalResults.add(syncResponse);
            await _handlingError(operation);
            continue;
          }
          await _queueRepository.removeOperationToQueue(operation.id);
          continue;
        } else if (responseResult is ParentIsDeleted) {
          Map<DBTable, List<String>> list = {};
          final data = responseResult.data ?? {};
          await IsarService.isar.writeTxn(() async {
            for (var parent in data.entries) {
              final ids = parent.value;
              if (ids is! List<String>) continue;

              for (var parentId in ids) {
                final deletedResult = await _tableRepository
                    .deleteEntityCascadeNotNull(
                  DBTable.getDBTableFromString(parent.key),
                  parentId,
                );
                final deletedEntities = deletedResult.fold(
                  ifLeft: (d) => <DBTable, List<String>>{},
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
            final tableIds = list[params.table] ?? [];
            list[params.table] = {...tableIds, operation.entityId}.toList();

            final syncResponse = SyncResponse(
              networkResponse: responseResult,
              operation: operation,
              deletedEntities: list,
              isError: false,
              willTry: false,
            );
            finalResults.add(syncResponse);
            await _queueRepository.removeOperationToQueue(operation.id);
          });
          continue;
        } else {
          final syncResponse = SyncResponse(
            networkResponse: responseResult,
            operation: operation,
            deletedEntities: null,
            isError: true,
            willTry: true,
          );
          finalResults.add(syncResponse);
          await _handlingError(operation);
          continue;
        }
      } catch (e, st) {
        final syncResponse = SyncResponse(
          networkResponse: NetworkFailure(details: st.toString()),
          operation: operation,
          deletedEntities: null,
          isError: true,
          willTry: true,
        );
        finalResults.add(syncResponse);
        await _handlingError(operation);
        continue;
      }
    }
    return Right(finalResults);
  }
}

 */
