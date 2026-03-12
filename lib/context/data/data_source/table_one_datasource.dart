import 'package:dart_either/dart_either.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar/isar.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/operation_status.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/core/error/sync_response.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_one.dart';
import 'package:sync_feature/sync_engine/domain/repository/queue_repository.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_operation_usecase.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/netwrok_response.dart';
import '../../../core/isar_service/collections/table_one_collection.dart';
import '../../../core/isar_service/isar_service.dart';
import '../../../sync_engine/data/models/table_one_model.dart';

class TableOneDatasource {
  final AddEntityLocalUseCase _addEntityLocalUseCase;
  final AddOperationLocalUseCase _addOperationLocalUseCase;
  final PushSingleOperationUseCase _pushSingleOperationUseCase;
  final QueueRepository _queueRepository;
  final SyncRepository _syncRepository;
  final TableRepository _tableRepository;
  const TableOneDatasource(
    this._addEntityLocalUseCase,
    this._addOperationLocalUseCase,
    this._queueRepository,
    this._syncRepository,
    this._pushSingleOperationUseCase,
    this._tableRepository,
  );
  Future<Either<Failure, SyncResponse?>> create(TableOne entity) async {
    final uuid = Uuid();
    final operation = Operation(
      id: uuid.v4(),
      entityId: entity.entityId,
      centerId: entity.centerId,
      action: OperationAction.create,
      table: DBTable.table_one,
      json: entity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now().toUtc(),
      retryCount: 0,
      lastAttemptAt: DateTime.now().toUtc(),
      nextRetryAt: DateTime.now().toUtc(),
      status: OperationState.pending,
    );

    final bool hasInternet = await InternetConnection().hasInternetAccess;

    if (!hasInternet) {
      final addResult = await _addOperationLocalUseCase.call(
        AddOperationLocalUseCaseParams(operation: operation),
      );

      if (addResult.isLeft) {
        return Left(
          addResult.fold(
            ifLeft: (l) => l,
            ifRight: (_) =>
                ProcessingFailure(message: 'Please Try again Later'),
          ),
        );
      }

      final result = await _addEntityLocalUseCase.call(
        AddEntityLocalUseCaseParams(
          table: DBTable.table_one,
          jsonEntity: null,
          entity: entity,
        ),
      );
      if (result.isLeft) {
        await _queueRepository.removeOperationToQueue(operation.id);
        return Left(
          result.fold(
            ifLeft: (l) => l,
            ifRight: (_) =>
                ProcessingFailure(message: 'Please Try again Later'),
          ),
        );
      }
      return Right(null);
    } else {
      final deviceIdResult = await _syncRepository.getDeviceId();
      final deviceId = deviceIdResult.getOrThrow();
      final sendResult = await _pushSingleOperationUseCase.call(
        PushSingleOperationUseCaseParams(
          table: DBTable.table_one,
          deviceId: deviceId,
          operation: operation,
        ),
      );

      if (sendResult.isLeft) {
        return Left(
          sendResult.fold(
            ifLeft: (l) => l,
            ifRight: (_) =>
                ProcessingFailure(message: 'Please Try again Later'),
          ),
        );
      }

      final sendData = sendResult.getOrThrow();
      if (sendData.networkResponse is NetworkSuccess &&
          sendData.networkResponse is! OperationAlreadyProcessed &&
          sendData.isError != true) {
        final result = await _addEntityLocalUseCase.call(
          AddEntityLocalUseCaseParams(
            table: DBTable.table_one,
            jsonEntity: null,
            entity: entity,
          ),
        );
        if (result.isLeft) {
          return Left(
            result.fold(
              ifLeft: (l) => l,
              ifRight: (_) =>
                  ProcessingFailure(message: 'Please Try again Later'),
            ),
          );
        }
        return Right(null);
      }
      return Right(sendData);
    }
  }

  Future<void> _updateEntity(TableOneModel model) async {
    final modelOne = model;

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

      print('newCollection $newCollection');
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

  Future<Either<Failure, SyncResponse?>> update(TableOne newEntity) async {
    try {
      final uuid = Uuid();
      final deviceIdResult = await _syncRepository.getDeviceId();
      final deviceId = deviceIdResult.getOrThrow();

      TableOne entityEdited = newEntity.copyWith(
        byDevice: deviceId,
        byUser: currentUser,
        updatedAt: DateTime.now().toUtc(),
      );
      final operation = Operation(
        id: uuid.v4(),
        entityId: entityEdited.entityId,
        centerId: entityEdited.centerId,
        action: OperationAction.update,
        table: DBTable.table_one,
        json: entityEdited.toJson(),
        version: entityEdited.version,
        userRole: currentUserRole,
        createdBy: currentUser,
        createdAt: DateTime.now().toUtc(),
        retryCount: 0,
        lastAttemptAt: DateTime.now().toUtc(),
        nextRetryAt: DateTime.now().toUtc(),
        status: OperationState.pending,
      );
      final bool hasInternet = await InternetConnection().hasInternetAccess;

      if (!hasInternet) {
        final addResult = await _addOperationLocalUseCase.call(
          AddOperationLocalUseCaseParams(operation: operation),
        );

        if (addResult.isLeft) {
          return Left(
            addResult.fold(
              ifLeft: (l) => l,
              ifRight: (_) =>
                  ProcessingFailure(message: 'Please Try again Later'),
            ),
          );
        }

        await _updateEntity(TableOneModel.fromEntity(entityEdited));
        return Right(null);
      } else {
        final sendResult = await _pushSingleOperationUseCase.call(
          PushSingleOperationUseCaseParams(
            table: DBTable.table_one,
            deviceId: deviceId,
            operation: operation,
          ),
        );

        if (sendResult.isLeft) {
          return Left(
            sendResult.fold(
              ifLeft: (l) => l,
              ifRight: (_) =>
                  ProcessingFailure(message: 'Please Try again Later'),
            ),
          );
        }
        final sendData = sendResult.getOrThrow();

        if (sendData.networkResponse is NetworkSuccess &&
            sendData.networkResponse is! OperationAlreadyProcessed &&
            sendData.isError != true) {
          await _updateEntity(TableOneModel.fromEntity(entityEdited));
          return Right(null);
        }

        return Right(sendData);
      }
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'failed to update for ${newEntity.entityId} $e ',
        ),
      );
    }
  }

  Future<Either<Failure, SyncResponse?>> softDelete(TableOne entity) async {
    try {
      final uuid = Uuid();
      final deviceIdResult = await _syncRepository.getDeviceId();
      final deviceId = deviceIdResult.getOrThrow();
      TableOne entityEdited = entity.copyWith(
        isDeleted: true,
        byDevice: deviceId,
        byUser: currentUser,
        updatedAt: DateTime.now().toUtc(),
      );
      final operation = Operation(
        id: uuid.v4(),
        entityId: entityEdited.entityId,
        centerId: entityEdited.centerId,
        action: OperationAction.delete,
        table: DBTable.table_one,
        json: entityEdited.toJson(),
        version: entityEdited.version,
        userRole: currentUserRole,
        createdBy: currentUser,
        createdAt: DateTime.now().toUtc(),
        retryCount: 0,
        lastAttemptAt: DateTime.now().toUtc(),
        nextRetryAt: DateTime.now().toUtc(),
        status: OperationState.pending,
      );
      final bool hasInternet = await InternetConnection().hasInternetAccess;

      if (!hasInternet) {
        final addResult = await _addOperationLocalUseCase.call(
          AddOperationLocalUseCaseParams(operation: operation),
        );

        if (addResult.isLeft) {
          return Left(
            addResult.fold(
              ifLeft: (l) => l,
              ifRight: (_) =>
                  ProcessingFailure(message: 'Please Try again Later'),
            ),
          );
        }
        final deleteRelationResult = await _tableRepository
            .deleteEntityCascadeNotNull(DBTable.table_one, entity.entityId);
        return Right(null);
      } else {
        final sendResult = await _pushSingleOperationUseCase.call(
          PushSingleOperationUseCaseParams(
            table: DBTable.table_one,
            deviceId: deviceId,
            operation: operation,
          ),
        );

        if (sendResult.isLeft) {
          return Left(
            sendResult.fold(
              ifLeft: (l) => l,
              ifRight: (_) =>
                  ProcessingFailure(message: 'Please Try again Later'),
            ),
          );
        }
        final sendData = sendResult.getOrThrow();

        if (sendData.networkResponse is NetworkSuccess &&
            sendData.networkResponse is! OperationAlreadyProcessed &&
            sendData.isError != true) {
          final deleteRelationResult = await _tableRepository
              .deleteEntityCascadeNotNull(DBTable.table_one, entity.entityId);
          return Right(null);
        }
        return Right(sendData);
      }
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'failed to softDelete for ${entity.entityId} $e ',
        ),
      );
    }
  }
}
